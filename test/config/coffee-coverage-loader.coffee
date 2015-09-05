path = require 'path'
coffeeCoverage = require 'coffee-coverage'
projectRoot = path.resolve(__dirname, '..', '..')
coverageVar = coffeeCoverage.findIstanbulVariable()
# Only write a coverage report if we're not running inside of Istanbul.
if coverageVar is null
  writeOnExit = path.join(projectRoot,'/coverage/coverage-coffee.json')

exclude = [
  '/example'
  '/node_modules'
  '/.git'
  '/test'
  '/webpack.config.coffee'
]

coffeeCoverage.register
    instrumentor: 'istanbul'
    basePath: projectRoot
    exclude: exclude
    coverageVar: coverageVar
    writeOnExit: writeOnExit
    initAll: true
