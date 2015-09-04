_ = require 'lodash'
pathToRegexp = require 'path-to-regexp'
invariant = require 'invariant'
Ruta3 = require 'ruta3'
history  = require 'history'
React = require 'react'

class Router

  constructor: (obj = {}) ->
    invariant _.isEmpty(obj),
      'Router constructor: you have to provide memoryType.'
    @_activeComponent = null
    @_targets = []
    @_delimiter = obj.delimiter or '/'
    @_router = new Ruta3()

    @_setupHistory(obj.memoryType or 'hash')

  _setupHistory: (memoryType) ->
    switch memoryType
      when 'hash' then historyFactory = history.createHashHistory
      when 'push' then historyFactory = history.createHistory
      when 'memory' then historyFactory = histroy.createMemoryHistory

    @_history = history.useQueries(historyFactory)()

  _handleRoute: (route) ->
    unless route
      route = @_router.match('404')

    if _.isString(route.action)
      matchTarget = @_matchTarget(route.action)
      invariant matchTarget,
        'No route matched: You probably missed to specify a React component.'
      component = matchTarget.component
      routeProps =
        route: matchTarget.route
        router: @_routerProps()
      props = _.assign({}, routeProps, matchTarget.props or {})
      return React.createElement(component, props)

    if _.isPlainObject(route.action)
      redirectTo = route.action.redirectTo
      invariant redirectTo,
        'Routes config: redirectTo key is misspelled or missing.'
      path = pathToRegexp.compile(redirectTo)
      @_history.replaceState(null, path(route.params))
      return null

  _routerProps: ->
    {go, goBack, goForward, pushState, replaceState} = @_history

    go: go
    goBack: goBack
    goForward: goForward
    pushState: pushState
    replaceState: replaceState
    getCurrentComponent: @getCurrentComponent
    transitionTo: (name, state = {}, params = {}) =>
      pathname = @_getRouteByName(name)
      pushState(state, pathname, params)

  _getRouteByName: (name) ->
    return _.findKey @_config, (item) -> item is name

  _matchTarget: (namespace) ->
    route = []
    for item in @_targets
      prefix = item.namespace or ''
      _descriptor = _.partial(@_namespaceDescriptor, _, _, prefix, namespace)
      if _.some item.states, _descriptor
        route.push
          route:
            name: _.findKey item.states, _descriptor
          props: _.findLast item.states, _descriptor
          component: item.component
    return _.first(route)

  _namespaceDescriptor: (item, key, prefix, namespace) ->
    return namespace is (prefix + key)

  addRoutes: (config) ->
    invariant(config, 'addRoutes: config must be provided.')
    @_config = config
    _.forEach @_config, (item, key) => @_router.addRoute(key, item)

  addTarget: (target, namespace) ->
    invariant(target, 'addTarget: target must be provided.')
    if namespace
      targetObj = _.first(target)
      targetObj.namespace = namespace + @_delimiter

    @_targets = @_targets.concat(target)

  addListener: (callback) ->
    invariant(callback, 'addListener: callback must be provided.')
    @_history.listen (location) =>
      @_activeComponent = @_handleRoute(@_router.match(location.pathname))
      callback(@_activeComponent) if @_activeComponent

  getCurrentComponent: ->
    return @_activeComponent


module.exports = Router
