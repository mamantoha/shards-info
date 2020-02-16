const path = require('path');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

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
    new MiniCssExtractPlugin({
      filename: 'application.css',
    }),
  ],
  module: {
    rules: [
      {
        test: require.resolve('jquery'),
        use: [{
          loader: 'expose-loader',
          options: 'jQuery'
        },{
          loader: 'expose-loader',
          options: '$'
        }]
      },
      {
        test: /\.(sa|sc|c)ss$/i,
        use: [MiniCssExtractPlugin.loader, 'css-loader','sass-loader']
      },
      {
        test: /\.(woff2?|svg)$/,
        use: [{loader: 'url-loader?limit=10000'}]
      },
      {
        test: /\.(ttf|eot)$/,
        use: [{loader: 'file-loader'}]
      },
    ]
  },
};
