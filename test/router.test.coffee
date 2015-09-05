routes = require './fixtures/routes'
target = require './fixtures/target'

describe 'Router class: ', ->
  Router = null

  before ->
    Router = require '../lib'

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
    expect(router.addTarget(target, 'testing')).to.be.ok()

  it 'should return props', ->
    router = new Router()
    props = router.getRouterProps()
    expect(props).to.be.an('object')
    expect(props.go).to.be.a('function')
    expect(props.goBack).to.be.a('function')
    expect(props.goForward).to.be.a('function')
    expect(props.pushState).to.be.a('function')
    expect(props.replaceState).to.be.a('function')
    expect(props.getCurrentComponent).to.be.a('function')
    expect(props.transitionTo).to.be.a('function')

  it 'should return null', ->
    router = new Router()
    expect(router.getCurrentComponent()).to.be(null)

  it 'should return component', ->
    router = new Router(history: 'memory', defaultRoute: '/projects')
    router.addRoutes(routes)
    router.addTarget(target, 'project-manager')
    router.addListener ->
      expect(router.getCurrentComponent()).to.be.an('object')

  it 'should throw an error when not call `addRoutes` before `addListener`', ->
    router = new Router(history: 'memory')
    fn = -> router.addListener -> null
    expect(fn).to.throwError()

  it 'should call `addListener` method', ->
    router = new Router(history: 'memory', defaultRoute: '/projects')
    router.addRoutes(routes)
    router.addTarget(target, 'project-manager')
    callback = sinon.spy()
    router.addListener(callback)
    expect(callback.called).to.be(true)

  it 'fkodspfdsfsd', ->
    router = new Router(slash: 'enforce', history: 'memory')
