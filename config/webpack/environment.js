const { environment } = require('@rails/webpacker')
const vue =  require('./loaders/vue')
const webpack = require('webpack')

environment.loaders.append('vue', vue)

environment.plugins.prepend('Provide', new webpack.ProvidePlugin({$: 'jquery',jquery: 'jquery', 
'window.jQuery': 'jquery', jQuery: 'jquery'}))

const config = environment.toWebpackConfig()

config.resolve.alias = {
  jquery: "jquery/src/jquery",
}

module.exports = environment