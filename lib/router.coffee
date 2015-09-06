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

    @_setupHistory(obj.history or 'hash', obj.defaultRoute or '/')

  _setupHistory: (historyType, defaultRoute) ->
    switch historyType
      when 'hash' then historyFactory = history.createHashHistory
      when 'push' then historyFactory = history.createHistory
      when 'memory' then historyFactory = history.createMemoryHistory
      else invariant(false, "There is no history type '#{history}'.")

    @_history = history.useQueries(historyFactory)()
    @_history.replaceState({}, defaultRoute) if defaultRoute != '/'

  _handleRoute: (route) ->
    unless route
      route = @_router.match('404')

    if _.isString(route.action)
      matchTarget = @_matchTarget(route.action)
      invariant matchTarget,
        'No route matched: You probably missed to specify a React component.'
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

  _matchTarget: (namespace) ->
    route = null
    for item in @_targets
      prefix = item.namespace or ''
      _descriptor = _.partial(@_namespaceDescriptor, _, _, prefix, namespace)
      if _.some item.states, _descriptor
        name = _.findKey(item.states, _descriptor)
        result =
          route:
            name: prefix + name
            originalName: name
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

  getCurrentComponent: ->
    return @_activeComponent

  getRouteByName: (name) ->
    invariant(@_config, 'getRouteByName: call `addRoutes` method first.')
    return _.findKey @_config, (item) -> item is name

  getRouterProps: ->
    location: @_location
    go: @_history.go
    goBack: @_history.goBack
    goForward: @_history.goForward
    pushState: @_history.pushState
    replaceState: @_history.replaceState
    getCurrentRouteProps: =>
      invariant @_routeProps,
        'No props set yet. You have to call `listen` methhod first.'
      return @_routeProps
    getCurrentComponent: => @getCurrentComponent()
    transitionTo: (name, state = {}, query = {}) =>
      pathname = @getRouteByName(name)
      @_history.pushState(state, pathname, query)


module.exports = Router
