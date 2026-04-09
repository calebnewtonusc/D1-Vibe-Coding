# Claude Code Internals

How Claude Code works under the hood. This document is based on source code analysis of Claude Code v2.1.x. Understanding these internals helps you write better CLAUDE.md files, hooks, commands, and rules.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [CLAUDE.md Loading](#claudemd-loading)
- [Rules System](#rules-system)
- [Slash Commands](#slash-commands)
- [Hook System](#hook-system)
- [Tool System](#tool-system)
- [Agent / Sub-Agent System](#agent--sub-agent-system)
- [Context Compression](#context-compression)
- [Skills System](#skills-system)
- [Permission System](#permission-system)

---

## Architecture Overview

Claude Code is a TypeScript application built with Ink (React for terminals). The core loop:

1. **User submits a prompt** (text, slash command, or file mention)
2. **Hooks fire**: `UserPromptSubmit` hooks run, can inject `additionalContext`
3. **System prompt assembled**: CLAUDE.md + rules + tool definitions + context
4. **API call**: message sent to Claude API with tools available
5. **Tool use loop**: Claude calls tools, each goes through `PreToolUse` hooks, permission checks, execution, then `PostToolUse` hooks
6. **Response rendered**: output displayed in terminal UI
7. **Stop hooks fire**: `Stop` hooks run at session end

Key source files:

- `src/main.tsx`: entry point, Ink app mount
- `src/query.ts`: core API query loop
- `src/Tool.ts`: tool definition interface (783+ lines defining every tool capability)
- `src/context.ts`: context/state management
- `src/utils/hooks.ts`: hook execution engine

---

## CLAUDE.md Loading

Claude Code loads CLAUDE.md files from multiple locations, merged in order of specificity:

### Loading hierarchy (most general to most specific)

1. `~/.claude/CLAUDE.md` (user-global, applies to all projects)
2. `{project-root}/CLAUDE.md` (project-level, checked into repo)
3. `{project-root}/CLAUDE.local.md` (project-level, gitignored, personal overrides)
4. `.claude/rules/*.md` (conditional rules, loaded based on `paths` frontmatter)

### How it works internally

The `settingsSync` service manages CLAUDE.md as a synced file type (`USER_MEMORY: '~/.claude/CLAUDE.md'`). On each session:

1. `getUserContext()` is called (memoized)
2. It reads all CLAUDE.md files from the hierarchy
3. Content is injected into the system prompt as a `# claudeMd` section inside `<system-reminder>` tags
4. After compaction (context compression), CLAUDE.md is re-loaded via `postCompactCleanup.ts` to ensure it survives compression

### Key insight for CLAUDE.md authors

- Content at the top of CLAUDE.md has the highest visibility to the model (serial position effect applies)
- `IMPORTANT:` prefix in rules causes the model to weight them more heavily
- The entire CLAUDE.md hierarchy is injected on every turn, so keep it focused. A 700-line CLAUDE.md uses ~2K tokens every single API call
- After compression, CLAUDE.md is re-injected fresh, so your rules survive long conversations

---

## Rules System

Rules files (`.claude/rules/*.md`) are conditionally loaded based on what files Claude is working with.

### Frontmatter format

```yaml
---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---
```

The `paths` field uses glob patterns. When Claude reads or writes a file matching the pattern, the rule's content is injected into context.

### How rules load internally

1. `loadSkillsDir.ts` (line 156) parses paths frontmatter using the same parser as CLAUDE.md rules
2. On each turn, active file paths are matched against rule globs
3. Matching rules are appended to the system context
4. Rules with `paths: ["**/*"]` always load (equivalent to putting content in CLAUDE.md)

### Best practice

- Use specific paths globs to keep context lean. A rule that only applies to `.sql` files shouldn't load when editing `.tsx`
- Put universal rules in CLAUDE.md, file-specific rules in `.claude/rules/`

---

## Slash Commands

Slash commands are markdown files in `.claude/commands/` that define multi-step workflows.

### Frontmatter options

```yaml
---
description: Human-readable description shown in command picker
allowed-tools: Bash(git:*), Read, Edit
argument-hint: "<task name or description>"
---
```

- `description`: shown when typing `/` in the input
- `allowed-tools`: restricts which tools the command can use (security boundary)
- `argument-hint`: placeholder text shown after the command name

### How commands execute internally

1. User types `/command-name` (or selects from autocomplete)
2. `useMergedCommands.ts` loads commands from: `.claude/commands/`, `~/.claude/commands/`, and built-in commands
3. The markdown content becomes the user message (with `$ARGUMENTS` replaced by any text after the command name)
4. `allowed-tools` creates a tool whitelist for that turn
5. The model executes the command content as a structured prompt

### Variable substitution

- `$ARGUMENTS`: everything the user typed after the command name
- Bash code blocks in the command are executed by Claude as tool calls, not automatically

---

## Hook System

Hooks are shell commands that run at specific lifecycle events. They're the most powerful extension point.

### Hook events

| Event              | When It Fires          | Can Modify                                                |
| ------------------ | ---------------------- | --------------------------------------------------------- |
| `SessionStart`     | New session begins     | Inject `additionalContext`, set `watchPaths`              |
| `UserPromptSubmit` | User sends a message   | Inject `additionalContext`, block with `continue: false`  |
| `PreToolUse`       | Before a tool executes | Approve/block tool, modify `updatedInput`, inject context |
| `PostToolUse`      | After a tool executes  | Inject context, run side effects (format, sync)           |
| `Stop`             | Session ends           | Inject reminders                                          |
| `Notification`     | Task completes         | Side effects (sound, alert)                               |
| `SubagentStart`    | Sub-agent spawns       | Inject context                                            |
| `Setup`            | First-time setup       | Inject context                                            |

### Hook JSON output schema

Hooks communicate back to Claude Code via JSON on stdout. The schema (from `types/hooks.ts`):

```typescript
{
  // Shared fields (all hook types)
  continue?: boolean,        // false = stop execution
  stopReason?: string,       // message when continue is false
  suppressOutput?: boolean,  // hide hook stdout from transcript
  decision?: "approve" | "block",  // for PreToolUse
  reason?: string,           // explanation
  systemMessage?: string,    // warning shown to user

  // Event-specific output
  hookSpecificOutput?: {
    hookEventName: "PreToolUse" | "UserPromptSubmit" | "SessionStart" | ...,
    additionalContext?: string,     // injected into model context
    permissionDecision?: string,    // for PreToolUse
    updatedInput?: Record<string, unknown>,  // modify tool input
    initialUserMessage?: string,    // for SessionStart
    watchPaths?: string[],          // file paths to watch
  }
}
```

### How hooks execute internally

1. Hook configs are read from `settings.json` (both deprecated flat format and new source-based format)
2. `matcher` field (e.g., `"Write|Edit"`) is matched against tool names using regex
3. Hook command is spawned as a child process via `spawn()`
4. The tool input is piped to the hook's stdin as JSON
5. Hook's stdout is parsed as JSON using `hookJSONOutputSchema`
6. `async: true` hooks run without blocking; sync hooks block until complete
7. Hook environment includes: session ID, project root, transcript path, agent type

### Hook input (what your hook receives on stdin)

```json
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.ts",
    "content": "..."
  },
  "session_id": "uuid",
  "project_root": "/path/to/project"
}
```

### Security: managed hooks

Claude Code distinguishes between:

- **User hooks**: defined in settings.json, full trust
- **Managed hooks**: from plugins/marketplace, restricted permissions
- `shouldAllowManagedHooksOnly()` and `shouldDisableAllHooksIncludingManaged()` control this

---

## Tool System

Every tool in Claude Code implements the `BuiltTool` interface from `Tool.ts`.

### Tool interface (key methods)

```typescript
interface BuiltTool {
  name: string;
  prompt(): string; // Description sent to the model
  checkPermissions(): PermissionResult; // User approval logic
  validateInput(): ValidationResult; // Input validation
  isReadOnly(): boolean; // Safe for auto-approve?
  isDestructive?(): boolean; // Warns user before running
  isConcurrencySafe(): boolean; // Can run in parallel?
  maxResultSizeChars: number; // Large results get persisted to disk
  shouldDefer?: boolean; // Hidden until ToolSearch finds it
  alwaysLoad?: boolean; // Never deferred, always visible
}
```

### Tool deferral (ToolSearch)

To reduce initial prompt size, Claude Code defers tools it doesn't expect to need on turn 1:

- Deferred tools have `shouldDefer: true`
- They're listed by name only in the system prompt
- The model uses `ToolSearch` to fetch their full schema when needed
- MCP tools can set `_meta['anthropic/alwaysLoad']` to skip deferral

### Large result handling

When a tool result exceeds `maxResultSizeChars`, Claude Code:

1. Saves the full result to a temp file
2. Sends a preview + file path to the model
3. The model can `Read` the file for full content
4. Exception: `Read` tool has `maxResultSizeChars: Infinity` (prevents circular Read loops)

### Built-in tools

Read, Write, Edit, Bash, Glob, Grep, Agent, TodoWrite, WebSearch, WebFetch, NotebookEdit, ToolSearch, and several more.

---

## Agent / Sub-Agent System

The Agent tool spawns sub-agents: isolated Claude instances with their own context window.

### Built-in agent types

| Type                | File                      | Tools Available                       | Use Case                   |
| ------------------- | ------------------------- | ------------------------------------- | -------------------------- |
| `general-purpose`   | `generalPurposeAgent.ts`  | All tools                             | Complex multi-step tasks   |
| `Explore`           | `exploreAgent.ts`         | Read-only tools (no Edit/Write/Agent) | Fast codebase exploration  |
| `Plan`              | `planAgent.ts`            | Read-only tools (no Edit/Write/Agent) | Implementation planning    |
| `claude-code-guide` | `claudeCodeGuideAgent.ts` | Glob, Grep, Read, WebFetch, WebSearch | Claude Code help questions |
| `statusline-setup`  | `statuslineSetup.ts`      | Read, Edit                            | Configure status line      |
| `verification`      | `verificationAgent.ts`    | All tools                             | Verify implementations     |

### How sub-agents work

1. Parent agent calls the `Agent` tool with a prompt and optional `subagent_type`
2. `runAgent.ts` creates a new Claude API conversation
3. **Key optimization**: Explore agents do NOT receive the full CLAUDE.md hierarchy (saves ~5-15 Gtok/week across 34M+ spawns). The parent has full context and interprets results.
4. Sub-agents can run in foreground (blocking) or background (`run_in_background: true`)
5. `isolation: "worktree"` creates a git worktree for truly isolated file changes
6. Sub-agent results return to the parent as a single message

### Worktree isolation

When `isolation: "worktree"` is set:

1. A temporary git worktree is created
2. The sub-agent works on an isolated copy of the repo
3. If changes were made, the worktree path and branch are returned
4. If no changes, the worktree is auto-cleaned

---

## Context Compression

When a conversation approaches the context window limit, Claude Code compresses prior messages.

### Compression types

| Type                       | File                      | When                                  |
| -------------------------- | ------------------------- | ------------------------------------- |
| **Auto-compact**           | `autoCompact.ts`          | Automatically when approaching limits |
| **Manual compact**         | `compact.ts`              | User runs `/compact`                  |
| **Micro-compact**          | `microCompact.ts`         | Lightweight, preserves more detail    |
| **Session memory compact** | `sessionMemoryCompact.ts` | Extracts key facts before discarding  |
| **API micro-compact**      | `apiMicrocompact.ts`      | Server-side compression               |

### How auto-compact works

1. `compactWarningHook.ts` monitors token usage
2. When approaching the limit, `autoCompact.ts` triggers
3. Older messages are summarized: tool results are condensed, conversation flow is preserved
4. **Critical**: after compression, `postCompactCleanup.ts` runs:
   - Re-injects CLAUDE.md (so your instructions survive)
   - Re-runs SessionStart hooks
   - Clears memoized context caches
5. The conversation continues with compressed history + fresh context

### What survives compression

- CLAUDE.md content (re-injected post-compact)
- Recent messages (not compressed)
- Tool results from recent turns
- Todo list state

### What gets compressed

- Older conversation turns (summarized)
- Large tool results from earlier turns
- Repetitive back-and-forth

---

## Skills System

Skills (`.claude/skills/` or bundled) are enhanced commands with richer capabilities.

### Skill vs Command

| Feature           | Command (`.claude/commands/`) | Skill (`.claude/skills/`)           |
| ----------------- | ----------------------------- | ----------------------------------- |
| Format            | Plain markdown                | Markdown with rich frontmatter      |
| Invocation        | `/command-name`               | `/skill-name` or auto-triggered     |
| Path matching     | No                            | Yes (like rules, can auto-activate) |
| Tool restrictions | `allowed-tools`               | Full tool control                   |
| Arguments         | `$ARGUMENTS` substitution     | Structured argument parsing         |

### Bundled skills

Claude Code ships with built-in skills like `remember` (memory management), various office document handlers (`docx`, `xlsx`, `pptx`, `pdf`), and development skills (`commit`, `review-pr`).

---

## Permission System

Claude Code has a layered permission system that controls which tools can run without user approval.

### Permission layers (checked in order)

1. **Hook-level**: `PreToolUse` hooks can approve/block with `decision: "approve"` or `"block"`
2. **Settings-level**: `permissions.allow` patterns in settings.json (e.g., `"Bash(git:*)"`)
3. **Tool-level**: each tool's `checkPermissions()` method
4. **User-level**: interactive approval prompt if nothing auto-approves

### Permission patterns

```json
{
  "permissions": {
    "allow": [
      "Bash(git:*)", // All git commands
      "Bash(npm:*)", // All npm commands
      "Read(**)", // All file reads
      "Edit(**/*.ts)" // Edit any TypeScript file
    ]
  }
}
```

### Auto-approve logic

The `yoloClassifier.ts` handles bypass mode (`defaultMode: "bypassPermissions"`):

- Reads CLAUDE.md to understand project context
- Classifies tool calls as safe/unsafe
- Some operations (like `rm -rf /`) are never auto-approved regardless of mode

---

## Key Takeaways for Configuration Authors

1. **CLAUDE.md is re-injected after compression.** Your rules persist in long conversations.
2. **Rules with specific `paths` globs save context tokens.** Don't make everything `**/*`.
3. **Hooks receive tool input on stdin as JSON.** Parse with `jq` for filtering.
4. **Sub-agents don't get your CLAUDE.md.** Design prompts to the Agent tool that are self-contained.
5. **`additionalContext` from hooks is the primary way to inject dynamic information.** Use it for session-start context, not static rules (those belong in CLAUDE.md).
6. **Tool deferral reduces first-turn prompt size.** MCP tools are deferred by default unless they set `alwaysLoad`.
7. **Large tool results get persisted to disk.** The model sees a preview, not the full output.
8. **Permission patterns use glob syntax.** `Bash(git:*)` matches any git command.
