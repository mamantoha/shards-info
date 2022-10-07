const path = require("path");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

module.exports = {
  mode: "production",
  entry: ["./assets/main.js", "./assets/main.scss"],
  output: {
    filename: "application.js",
    path: path.resolve(__dirname, "public/dist"),
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: "application.css",
    }),
  ],
  module: {
    rules: [
      {
        test: require.resolve("jquery"),
        loader: "expose-loader",
        options: {
          exposes: ["$", "jQuery"],
        },
      },
      {
        test: /\.(sa|sc|c)ss$/i,
        use: [
          {
            loader: MiniCssExtractPlugin.loader,
            options: {
              publicPath: "/dist/",
            },
          },
          "css-loader",
          "sass-loader",
        ],
      },
      {
        test: /\.(woff2?|svg|ttf|eot)$/,
        type: "asset/resource",
      },
    ],
  },
};
