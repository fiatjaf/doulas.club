var webpack = require('webpack')

module.exports = {
  module: {
    loaders: [
      { test: /\.coffee$/, loader: "coffee" }
    ]
  },
  resolve: {
    extensions: ["", ".web.coffee", ".web.js", ".coffee", ".js"]
  },
  plugins: [
    new webpack.IgnorePlugin(/^is-crawler$/)
  ]
}
