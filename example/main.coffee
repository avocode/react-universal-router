React = require 'react'
Router = require '../src/'

{div} = React.DOM

Test = React.createClass

  _transition: null

  componentDidMount: ->
    @_transition = (location) ->
      return 'Are you really wanna leave?'
    @props.router.registerTransitionHook @_transition

  componentWillUnmount: ->
    @props.router.unregisterTransitionHook @_transition

  render: ->
    div null,
      '1. Hey'

Test2 = React.createClass
  render: ->
    div null,
      '2. Hello' + Math.random()
      @props.children

Test3 = React.createClass
  render: ->
    console.log @props
    div null,
      '3. Aloha'

NiceComponent = React.createClass
  render: ->
    div null,
      'Nice component :)'
      @props.children

App = React.createClass
  getInitialState: ->
    activeComponent: @props.router.getCurrentComponent()

  componentDidMount: ->
    @props.router.listen =>
      @setState(activeComponent: @props.router.getCurrentComponent())
  render: ->
    div null,
      @state.activeComponent


routes =
  component: Test
  states: {
    'list': {
      list: 22
    }
    'detail': {
      detail: 44
    }
  }

routes2 =
  component: Test2
  states:
    'index':
      ahoj: 12
    'about':
      children: React.createElement(NiceComponent)
    'users':
      children: React.createElement(NiceComponent)
    'user':
      children:
        React.createElement(NiceComponent, null, React.createElement(Test3))

routes3 = {
  component: Test3
  states: {
    'notFoundComponent':
      notFound: true
  }
}

routeMap =
  '/projects': 'project-manager/list'
  '/projects/:id': 'project-manager/detail'
  '/project/:id':
    redirectTo: '/projects/:id'
  404: 'notFoundComponent'
  '/': 'index'
  '/about': 'about'
  '/users': 'users'
  '/user/:id': 'user'


router = new Router(history: 'hash')
router.addRoutes(routeMap)
router.addTarget(routes, 'project-manager')
router.addTarget(routes2)
router.addTarget(routes3)

window.router = router

mountElement = document.getElementById('app')

# You can use it like this
#
# router.listen (component) ->
#   React.render(component, mountElement)
#
# or
# You can use router inside some route and render active component there
#
# React.render(React.createElement(App, router: router), mountElement)

React.render(React.createElement(App, router: router), mountElement)
