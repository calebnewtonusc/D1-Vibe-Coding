import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: "class",
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      // ─── Colors ───────────────────────────────────────────────────────
      colors: {
        // Override with brand colors as needed
        // accent: { DEFAULT: "#6366f1", ... }
      },

      // ─── Typography ───────────────────────────────────────────────────
      fontFamily: {
        sans: ["var(--font-inter)", "system-ui", "sans-serif"],
        mono: ["var(--font-geist-mono)", "monospace"],
      },
      fontSize: {
        "display-xl": ["4.5rem", { lineHeight: "1.1", fontWeight: "700" }],
        "display-lg": ["3.75rem", { lineHeight: "1.1", fontWeight: "700" }],
        "display-md": ["3rem", { lineHeight: "1.15", fontWeight: "600" }],
      },
      letterSpacing: {
        tighter: "-0.04em",
        tight: "-0.02em",
      },

      // ─── Spacing ──────────────────────────────────────────────────────
      maxWidth: {
        "8xl": "88rem",
        "9xl": "96rem",
      },

      // ─── Animations ───────────────────────────────────────────────────
      animation: {
        "fade-up": "fade-up 0.5s ease-out both",
        "fade-in": "fade-in 0.4s ease-out both",
        shimmer: "shimmer 2s linear infinite",
      },
      keyframes: {
        "fade-up": {
          from: { opacity: "0", transform: "translateY(16px)" },
          to: { opacity: "1", transform: "translateY(0)" },
        },
        "fade-in": {
          from: { opacity: "0" },
          to: { opacity: "1" },
        },
        shimmer: {
          from: { backgroundPosition: "-200% 0" },
          to: { backgroundPosition: "200% 0" },
        },
      },

      // ─── Backgrounds ──────────────────────────────────────────────────
      backgroundImage: {
        "radial-faded":
          "radial-gradient(ellipse at top, var(--tw-gradient-stops))",
        "conic-gradient":
          "conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))",
      },

      // ─── Border radius ────────────────────────────────────────────────
      borderRadius: {
        "4xl": "2rem",
        "5xl": "2.5rem",
      },

      // ─── Box shadows ──────────────────────────────────────────────────
      boxShadow: {
        glow: "0 0 40px -10px var(--tw-shadow-color)",
        "glow-sm": "0 0 20px -5px var(--tw-shadow-color)",
      },
    },
  },
  plugins: [
    // require("@tailwindcss/typography"),
    // require("@tailwindcss/forms"),
  ],
};

export default config;
