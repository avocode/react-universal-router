React = require 'react'
Router = require '../lib/'

{div} = React.DOM

Test = React.createClass
  render: ->
    div null,
      'Test'

Test2 = React.createClass
  render: ->
    div null,
      'Test 2'

Test3 = React.createClass
  render: ->
    div null,
      'Test 3'

App = React.createClass
  getInitialState: ->
    activeComponent: @props.router.getCurrentComponent()

  componentDidMount: ->
    @props.router.addListener =>
      @setState(activeComponent: @props.router.getCurrentComponent())
  render: ->
    div null,
      @state.activeComponent


routes = [
  component: Test
  states: {
    'list': {
      list: 22
    }
    'detail': {
      detail: 44
    }
  }
]

routes2 = [
  component: Test2
  states: {
    'index': {}
  }
]

routes3 = [
  component: Test3
  states: {
    'notFoundComponent': {}
  }
]

routeMap =
  '/projects': 'project-manager/list'
  '/projects/:id': 'project-manager/detail'
  '/project/:id':
    redirectTo: '/projects/:id'
  404: 'notFoundComponent'
  '/': 'index'


router = new Router()
router.addRoutes(routeMap)
router.addTarget(routes, 'project-manager')
router.addTarget(routes2)
router.addTarget(routes3)


mountElement = document.getElementById('app')

# You can use it like this
#
# router.addListener (component) ->
#   React.render(component, mountElement)
#
# or
# You can use router inside some route and render active component there
#
# React.render(React.createElement(App, router: router), mountElement)

React.render(React.createElement(App, router: router), mountElement)
