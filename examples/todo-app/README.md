# Todo App: Cloudflare Worker + D1 Example

A working REST API built with Cloudflare Workers and D1. Deploy in 60 seconds.

## What this demonstrates

- D1 prepared statements (SQL injection safe)
- CORS middleware
- Typed TypeScript bindings
- CRUD with pagination and filtering
- Error handling
- Migration workflow

## Setup

```bash
# Install dependencies
npm install

# Create the D1 database
npm run db:create
# Copy the database_id from the output into wrangler.toml

# Run migrations locally
npm run db:migrate

# Start dev server
npm run dev
```

Open http://localhost:8787 to see the API info.

## API Endpoints

| Method | Path                         | Body                      | Description                 |
| ------ | ---------------------------- | ------------------------- | --------------------------- |
| GET    | `/health`                    |                           | Health check with DB status |
| GET    | `/api/todos`                 |                           | List todos (paginated)      |
| GET    | `/api/todos?completed=true`  |                           | Filter by completion status |
| GET    | `/api/todos?page=2&limit=10` |                           | Pagination                  |
| POST   | `/api/todos`                 | `{ "title": "Buy milk" }` | Create a todo               |
| GET    | `/api/todos/:id`             |                           | Get one todo                |
| PATCH  | `/api/todos/:id`             | `{ "completed": true }`   | Update a todo               |
| DELETE | `/api/todos/:id`             |                           | Delete a todo               |

## Deploy to production

```bash
# Run migrations on remote D1
npm run db:migrate:prod

# Deploy
npm run deploy
```

Your API will be live at `https://todo-app.YOUR_SUBDOMAIN.workers.dev`.

## Try it

```bash
# Create a todo
curl -X POST http://localhost:8787/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "Ship the feature"}'

# List all todos
curl http://localhost:8787/api/todos

# Mark it done
curl -X PATCH http://localhost:8787/api/todos/1 \
  -H "Content-Type: application/json" \
  -d '{"completed": true}'

# Delete it
curl -X DELETE http://localhost:8787/api/todos/1
```
