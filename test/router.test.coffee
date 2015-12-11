routes = require './fixtures/routes'
{targetA, targetB} = require './fixtures/target'

describe 'Router class: ', ->
  Router = null

  before ->
    Router = require '../src'

  it 'should create Route instance', ->
    router = new Router()
    expect(router).to.be.an(Router)

  it 'should just work and not throw any error', ->
    router = new Router(history: 'hash', delimiter: '@')
    expect(router).to.be.ok()
    router = new Router(history: 'push')
    expect(router).to.be.ok()
    router = new Router(history: 'memory')
    expect(router).to.be.ok()

  it 'should throw an error when user provide non existing history type', ->
    fn = -> new Router(history: 'nonsense')
    expect(fn).to.throwError()

  it 'should return defaultRoute', ->
    router = new Router(history: 'memory', defaultRoute: '/projects')
    router.addRoutes(routes)
    router.addTarget(targetA, 'project-manager')
    router.listen ->
      expect(router.getRouterProps().location.pathname).to.be('/projects')

    router = new Router(history: 'memory')
    router.addRoutes(routes)
    router.addTarget(targetB)
    router.listen ->
      expect(router.getRouterProps().location.pathname).to.be('/')

  it 'should throw an error when calling `addRoutes` method without arg', ->
    router = new Router()
    fn = -> router.addRoutes()
    expect(fn).to.throwError()

  it 'should not throw an error when user provides arg to `addRoutes` method', ->
    router = new Router()
    fn = -> router.addRoutes(routes)
    expect(fn).to.not.throwException()

  it 'should find route by name', ->
    router = new Router()
    router.addRoutes(routes)
    routeName = router.getRouteByName('index')
    expect(routeName).to.be('/')

  it 'should throw an error when calling `target` without arg', ->
    router = new Router()
    fn = -> router.addTarget()
    expect(fn).to.throwError()

  it 'should not throw an error when user provides args to `addTarget` method', ->
    router = new Router()
    expect(router.addTarget(targetA, 'testing')).to.be.ok()

  it 'should return props', ->
    router = new Router()
    props = router.getRouterProps()
    expect(props).to.be.an('object')
    expect(props.go).to.be.a('function')
    expect(props.goBack).to.be.a('function')
    expect(props.goForward).to.be.a('function')
    expect(props.pushState).to.be.a('function')
    expect(props.replaceState).to.be.a('function')
    expect(props.getCurrentRouteProps).to.be.a('function')
    expect(props.getCurrentComponent).to.be.a('function')
    expect(props.transitionTo).to.be.a('function')

  it 'should return null', ->
    router = new Router()
    expect(router.getCurrentComponent()).to.be(null)

  it 'should return component', ->
    router = new Router(history: 'memory', defaultRoute: '/projects')
    router.addRoutes(routes)
    router.addTarget(targetA, 'project-manager')
    router.listen (component) ->
      expect(router.getCurrentComponent()).to.be.an('object')
      expect(component).to.be.an('object')
      expect(_.isEqual(router.getCurrentComponent(), component)).to.be(true)


  it 'should throw an error when not calling `addRoutes` before `listen`', ->
    router = new Router(history: 'memory')
    fn = -> router.listen -> null
    expect(fn).to.throwError()

  it 'should call `listen` method', ->
    router = new Router(history: 'memory', defaultRoute: '/projects')
    router.addRoutes(routes)
    router.addTarget(targetA, 'project-manager')
    callback = sinon.spy()
    router.listen(callback)
    expect(callback.called).to.be(true)

  it 'should throw an error when no route matches', ->
    router = new Router(history: 'memory')
    router.addRoutes(routes)
    router.addTarget(targetA)
    fn = -> router.listen -> null
    expect(fn).to.throwError()

  it 'should match url', ->
    router = new Router(history: 'memory', defaultRoute: '/projects')
    router.addRoutes(routes)
    router.addTarget(targetA, 'project-manager')
    router.addTarget(targetB)
    matchRoute = '/projects'
    props = router.getRouterProps()
    router.listen ->
      expect(props.location.pathname).to.be(matchRoute)

    matchRoute = '/'
    props.pushState({}, '/')

    matchRoute = '/projects'
    props.transitionTo('project-manager/list')

    matchRoute = '/qwerty'
    props.replaceState({}, '/qwerty')

    matchRoute = '/'
    props.goBack()

    matchRoute = '/qwerty'
    props.goForward()

  it 'should get component props', ->
    router = new Router(history: 'memory', defaultRoute: '/projects?test=123')
    router.addRoutes(routes)
    router.addTarget(targetA, 'project-manager')
    router.addTarget(targetB)

    router.listen -> null

    props = router.getCurrentRouteProps()
    test = (props) ->
      expect(props.route).to.be.an('object')
      expect(props.router).to.be.an('object')
      expect(props.list).to.be(22)
      expect(props.route.originalName).to.be('list')
      expect(props.route.name).to.be('project-manager/list')
      expect(props.route.pathname).to.be('/projects')
      expect(props.route.query.test).to.be('123')
      expect(props.router.getCurrentComponent()).to.be.an('object')

    test(props)
    props = router.getRouterProps().getCurrentRouteProps()
    test(props)


  it 'should enforce or omit slash at the the of the url', ->
    router = new Router(slash: 'enforce', history: 'memory')
    router.addRoutes(routes)
    router.addTarget(targetA, 'project-manager')
    router.addTarget(targetB)
    props = router.getRouterProps()
    location = props.location
    router.listen ->
      expect(_.endsWith(location.pathname, '/')).to.be(true)

    props.pushState({}, '/haha', {testing: 123})
    props.transitionTo 'project-manager/detail',
     params:
       id: 12

    router2 = new Router(slash: 'omit', history: 'memory')
    router2.addRoutes(routes)
    router2.addTarget(targetA, 'project-manager')
    router2.addTarget(targetB)

    props = router2.getRouterProps()
    location = props.location
    router2.listen ->
      if location.pathname.length > 1
        expect(_.endsWith(location.pathname, '/')).to.be(false)

    props.pushState({}, '/haha////', {testing: 123})
    props.transitionTo 'project-manager/detail',
      params:
        id: 99
    props.replaceState({}, '/qazwsx/?j=123')

  it 'should redirect to provided route', ->
    router = new Router(history: 'memory', defaultRoute: '/project/13')
    router.addRoutes(routes)
    router.addTarget(targetA, 'project-manager')
    router.addTarget(targetB)
    location = router.getRouterProps().location
    router.listen ->
      expect(location.pathname).to.be('/projects/13')

  it 'should render corrent React component', ->
    router = new Router(history: 'memory')
    router.addRoutes(routes)
    router.addTarget(targetA, 'project-manager')
    router.addTarget(targetB)
    shallowRenderer = ReactTestUtils.createRenderer()

    text = 'componentB...'

    router.listen ->
      component = router.getCurrentComponent()
      shallowRenderer = ReactTestUtils.createRenderer()
      shallowRenderer.render(component)
      output = shallowRenderer.getRenderOutput()
      expect(output.props.children).to.be(text)

    text = 'componentA...'
    router.getRouterProps().transitionTo('project-manager/list')

  it 'should render component to string', ->
    router = new Router(history: 'memory')
    router.addRoutes(routes)
    router.addTarget(targetA, 'project-manager')
    router.addTarget(targetB)

    result = '<div>componentB...</div>'

    router.listen (component) ->
      expect(React.renderToStaticMarkup(component)).to.be(result)

    result = '<div>componentA...</div>'
    router.getRouterProps().transitionTo('project-manager/list')

  it 'should register/unregister transition hook', ->
    router = new Router(history: 'memory')
    router.addRoutes(routes)
    router.addTarget(targetA, 'project-manager')
    router.addTarget(targetB)

    router.listen -> null

    test = (_router) =>
      fn = (location) ->
        expect(location.pathname).to.be.a('string')
      _router.registerTransitionHook fn
      props = router.getRouterProps()
      props.pushState({}, '/projects')
      props.goBack()
      props.goForward()
      _router.unregisterTransitionHook fn

    test(router.getRouterProps())
    test(router)


  it 'should throw an error when not providing callback', ->
    router = new Router(history: 'memory')
    expect(router.registerTransitionHook).to.throwError()
    expect(router.unregisterTransitionHook).to.throwError()

  it 'should avoid transition to the same view twice', ->
    router = new Router(history: 'memory')
    router.addRoutes(routes)
    router.addTarget(targetA, 'project-manager')
    router.addTarget(targetB)
    count = 0

    router.listen ->
      count += 1

    router.getRouterProps().transitionTo('index')
    router.getRouterProps().transitionTo('index')
    router.getRouterProps().transitionTo('index')
    router.getRouterProps().transitionTo('index')
    expect(count).to.be(2)

  it 'should return null when no route is matched', ->
    router = new Router(history: 'memory', defaultRoute: '/bla')
    _routes = _.assign({}, routes)
    delete _routes['404']
    router.addRoutes(_routes)
    router.addTarget(targetA, 'project-manager')
    router.addTarget(targetB)

    router.listen ->
      expect(router.getCurrentComponent()).to.be(null)

  it 'should have location.params', ->
    router = new Router(history: 'memory', defaultRoute: '/projects/42')
    router.addRoutes(routes)
    router.addTarget(targetA, 'project-manager')

    router.listen ->
      expect(router.getRouterProps().location.params.id).to.be('42')

  it 'should reset the memory history', ->
    router = new Router(history: 'memory', defaultRoute: '/projects/42')
    router.addRoutes(routes)
    router.addTarget(targetA, 'project-manager')
    router.getRouterProps().transitionTo('index')
    router.resetMemoryHistory()

    expect(router.getRouterProps().goBack).to.throwError()
