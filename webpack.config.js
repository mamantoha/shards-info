const path = require('path');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const { CleanWebpackPlugin } = require('clean-webpack-plugin');

module.exports = {
  mode: 'production',
  entry: [
    './assets/main.js',
    './assets/main.scss'
  ],
  output: {
    filename: 'application.js',
    path: path.resolve(__dirname, 'public/dist'),
  },
  plugins: [
    new CleanWebpackPlugin(),
    new MiniCssExtractPlugin({
      filename: 'application.css',
    }),
  ],
  module: {
    rules: [
      {
        test: require.resolve('jquery'),
        use: [
          {
            loader: 'expose-loader',
            options: 'jQuery'
          },
          {
            loader: 'expose-loader',
            options: '$'
          }
        ]
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
        test: /\.(woff2?|svg)$/,
        type: 'asset/inline',
      },
      {
        test: /\.(ttf|eot)$/,
        type: 'asset/resource',
      },
    ]
  },
};
