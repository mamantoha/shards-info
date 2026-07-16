import { defineConfig } from "vite";

export default defineConfig({
  base: "/dist/",
  publicDir: false,
  css: {
    preprocessorOptions: {
      scss: {
        silenceDeprecations: ["color-functions", "global-builtin", "if-function", "import"],
      },
    },
  },
  build: {
    outDir: "public/dist",
    emptyOutDir: true,
    cssCodeSplit: false,
    rollupOptions: {
      checks: {
        pluginTimings: false,
      },
      input: "assets/main.js",
      output: {
        entryFileNames: "application.js",
        chunkFileNames: "assets/[name].js",
        assetFileNames: (assetInfo) => {
          if (assetInfo.name && assetInfo.name.endsWith(".css")) {
            return "application.css";
          }

          return "assets/[name][extname]";
        },
      },
    },
  },
});
