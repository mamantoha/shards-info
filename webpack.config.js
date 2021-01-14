const path = require('path');

const ThemesGeneratorPlugin = require('themes-switch/ThemesGeneratorPlugin');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

module.exports = {
  mode: 'production',
  entry: [
    './assets/main.js',
    './assets/main.scss'
  ],
  output: {
    filename: '[name].js',
    chunkFilename: '[name].js',
    path: path.resolve(__dirname, 'public/dist'),
    publicPath: ''
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: 'application.css',
    }),
    new ThemesGeneratorPlugin({
      srcDir: 'assets',
      themesDir: 'assets/styles/themes',
      outputDir: 'css',
      defaultStyleName: 'default.scss',
      useStaticThemeName: true
    })
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
          options:
          {
            publicPath: '/dist/'
          }
        }, 'css-loader', 'sass-loader']
      },
      {
        test: /\.(woff2?|svg|ttf|eot)$/,
        type: 'asset/resource',
      },
    ]
  },
};
