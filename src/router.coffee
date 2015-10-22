_ = require 'lodash'
pathToRegexp = require 'path-to-regexp'
invariant = require 'invariant'
Ruta3 = require 'ruta3'
history  = require 'history'
React = require 'react'

class Router

  constructor: (obj = {}) ->
    @_activeComponent = null
    @_config = null
    @_targets = []
    @_location = {}
    @_routeProps = null
    @_delimiter = obj.delimiter or '/'
    @_router = new Ruta3()
    @_slash = obj.slash or null
    avoidTransitionSameRoute = true
    if obj.avoidTransitionSameRoute is false
      avoidTransitionSameRoute = false

    @_setupHistory obj.history or 'hash',
      obj.defaultRoute or '/',
      avoidTransitionSameRoute

  _setupHistory: (historyType, defaultRoute, avoidTransitionSameRoute) ->
    switch historyType
      when 'hash' then historyFactory = history.createHashHistory
      when 'push' then historyFactory = history.createHistory
      when 'memory' then historyFactory = history.createMemoryHistory
      else invariant(false, "There is no history type '#{history}'.")

    @_history = history.useQueries(historyFactory)()
    @_history.replaceState({}, defaultRoute) if defaultRoute != '/'
    @_avoidTransitionSameRoute() if avoidTransitionSameRoute

  _handleRoute: (route) ->
    unless route
      route = @_router.match('404')

    return null unless route

    if _.isString(route.action)
      matchTarget = @_matchTarget(route)
      invariant matchTarget,
        'No route matched: You probably missed to specify a React component.'
      @_location.params = route.params
      component = matchTarget.component
      componentProps =
        route: _.assign(matchTarget.route, @_location)
        router: @getRouterProps()
      props = _.assign({}, componentProps, matchTarget.props or {})
      @_routeProps = props
      return React.createElement(component, props)

    if _.isPlainObject(route.action)
      redirectTo = route.action.redirectTo
      invariant redirectTo,
        'Routes config: redirectTo key is misspelled or missing.'
      path = pathToRegexp.compile(redirectTo)
      @_history.replaceState(null, path(route.params))
      return null

  _matchTarget: (route) ->
    namespace = route.action
    for item in @_targets
      prefix = item.namespace or ''
      _descriptor = _.partial(@_namespaceDescriptor, _, _, prefix, namespace)
      if _.some item.states, _descriptor
        name = _.findKey(item.states, _descriptor)
        result =
          route:
            name: prefix + name
            originalName: name
            params: route.params
          props: _.findLast item.states, _descriptor
          component: item.component

    return result

  _namespaceDescriptor: (item, key, prefix, namespace) ->
    return namespace is (prefix + key)

  _slashResolver: (location) ->
    resolved = null
    if location.pathname.length > 1
      if @_slash is 'enforce'
        unless _.endsWith(location.pathname, '/')
          location.pathname = "#{location.pathname}/"
          resolved = true
      if @_slash is 'omit'
        if _.endsWith(location.pathname, '/')
          location.pathname = location.pathname.replace(/\/+$/, '')
          resolved = true
    @_history.replaceState(null, location.pathname) if resolved
    return resolved

  _updateLocationObj: (location) ->
    @_location.pathname = location.pathname
    @_location.query = location.query
    @_location.state = location.state
    @_location.search = location.search

  _avoidTransitionSameRoute: ->
    @_history.registerTransitionHook (location) =>
      isSameLocation = _.isEqual(location.pathname, @_location.pathname) and
        _.isEqual(location.search, @_location.search) and
        _.isEqual(location.state, @_location.state)
      return false if isSameLocation

  addRoutes: (config) ->
    invariant(config, 'addRoutes: config must be provided.')
    @_config = config
    _.forEach @_config, (item, key) => @_router.addRoute(key, item)

  addTarget: (target, namespace) ->
    invariant(target, 'addTarget: target must be provided.')
    if namespace
      targetObj = target
      targetObj.namespace = namespace + @_delimiter

    @_targets.push(target)

  listen: (callback) ->
    invariant(callback, 'listen: callback must be provided.')
    invariant(@_config, 'listen: call `addRoutes` method first.')
    invariant(@_targets.length, 'listen: call `addTarget` method first.')
    @_history.listen (location) =>
      @_updateLocationObj(location)
      return if @_slashResolver(location)
      @_activeComponent = @_handleRoute(@_router.match(location.pathname))
      callback(@_activeComponent) if @_activeComponent

  registerTransitionHook: (callback) ->
    invariant(callback, 'registerTransitionHook: callback must be specified.')
    @_history.registerTransitionHook(callback) if _.isFunction(callback)

  unregisterTransitionHook: (callback) ->
    invariant(callback, 'unregisterTransitionHook: callback must be specified.')
    @_history.unregisterTransitionHook(callback) if _.isFunction(callback)

  getCurrentComponent: ->
    return @_activeComponent

  getCurrentRouteProps: ->
    invariant @_routeProps,
      'No props set yet. You have to call `listen` methhod first.'
    return @_routeProps

  getRouteByName: (name) ->
    invariant(@_config, 'getRouteByName: call `addRoutes` method first.')
    result = _.findKey @_config, (item) -> item is name
    return result or null

  getRouterProps: ->
    location: @_location
    go: @_history.go
    goBack: @_history.goBack
    goForward: @_history.goForward
    pushState: @_history.pushState
    replaceState: @_history.replaceState
    getCurrentRouteProps: => @getCurrentRouteProps()
    getCurrentComponent: => @getCurrentComponent()
    registerTransitionHook: (callback) => @registerTransitionHook(callback)
    unregisterTransitionHook: (callback) => @unregisterTransitionHook(callback)
    transitionTo: (name, options) =>
      defaults =
        params: {}
        state: {}
        query: {}
        methodType: 'pushState'

      obj = _.assign {}, defaults, options
      {params, state, query, methodType} = obj
      route = @getRouteByName(name)
      invariant(route, 'transitionTo: wrong name argument provided.')
      path = pathToRegexp.compile(route)
      @_history[methodType](state, path(params), query)


module.exports = Router
