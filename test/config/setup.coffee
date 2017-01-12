require './coffee-coverage-loader'
require './global'
Mocha = require 'mocha'
fs = require 'fs'
_ = require 'lodash'
path = require 'path'

mocha = new Mocha()
testPath = path.join(__dirname, '..')

fs.readdirSync(testPath).filter (file) ->
  _.includes(file, '.coffee')
.forEach (file) ->
  mocha.addFile path.join(testPath, file)

mocha.run (failures) ->
  process.on 'exit', -> process.exit(failures)
