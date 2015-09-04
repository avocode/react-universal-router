webpack = require 'webpack'

# Note: Config below is for DEVELOPMENT ONLY
module.exports =
  entry: [
      'webpack-dev-server/client?http://localhost:3000'
      'webpack/hot/only-dev-server'
      "#{__dirname}/example/main.coffee"
  ]
  devtool: 'inline-source-map'
  debug: true
  output:
    filename: 'index.js'
  resolve:
    extensions: ['', '.coffee', '.js']
  resolveLoader:
    modulesDirectories: ['node_modules']
  plugins: [
    new webpack.NoErrorsPlugin()
  ]
  module:
    preLoaders: [
      {
        test: /\.coffee$/
        exclude: [/node_modules/, /spec/, /playground/]
        loader: 'coffee-lint-loader'
      }
    ]
    loaders: [
      {
        test: /\.coffee$/
        loader: 'react-hot!coffee'
      }
      {
        test: /\.less$/
        loader: "style-loader!css-loader!less-loader"
      }
    ]
    noParse: /\.min\.js/
  coffeelint:
    configFile: './.coffeelint'
