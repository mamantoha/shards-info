import { defineConfig } from "vite";

export default defineConfig({
  publicDir: false,
  build: {
    outDir: "public/dist",
    emptyOutDir: true,
    cssCodeSplit: false,
    rollupOptions: {
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
