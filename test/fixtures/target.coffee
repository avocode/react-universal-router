{componentA, componentB} = require './component'

targetA =
  component: componentA
  states:
    'list':
      list: 22
    'detail':
      detail: 44

targetB =
  component: componentB
  states:
    'index':
      indexProp: 666
    'notFoundComponent': null


module.exports = {
  targetA
  targetB
}
