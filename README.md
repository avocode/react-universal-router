React Universal Router
============

**Finally a simple and universal router for React**


## Motivation

At Avocode we needed a simple universal router that can be used on the web as well as in an Electron app. We tried React Router since it's de-facto a standard, but sadly it didn't fit our needs. We didn't like the robustness, frequently changing API and the fact that some simple tasks were difficult for unknown reasons (e.g. getting a route name). Nevertheless, there were some nice things like the [History](https://github.com/mjackson/history) that perfectly manages browser history and can be used on a web, Electron or React Native thanks to MemoryHistory.
So eventually we've built React Universal Router, an abstraction above the History library with some added sugar. Keep in mind the API interface is not finalized yet and will probably change until it reaches the 1.0 version.


## Quick Tour

### 1. Definition of routes

Key/Value definition of routes.

```
module.exports = {
  '/': 'homepage',
  '/designs': 'designs',
  '/projects': 'projects',
  '/project/:projectId': 'project-detail',
  '404': 'notFound',
}
```

### 2. Definition of targets

Targets are the "glue" between the routes and your components.

```
module.exports = {
  component: MyAppComponent,
  states: {
    'homepage': {
      myCustomProp: 'Homepage section'
    },
    'designs': {
      myCustomProp: 'Designs section'
    },
    'projects': {
      myCustomProp: 'Projects section'
    },
    'project-detail': {
      myCustomProp: 'Project Detail section'
    },
  }
}
```

States are matching the names (values) defined in route definition(s). You can optionally add props that are going to be injected to defined component. In this case `MyAppComponent` will receive `myCustomProp` prop.

### 3. Actual usage

You need to create a new instance of Router, add route definition(s) and target definition(s).

```
const options = {}
const router = new Router(options)
router.addRoutes(routes)
router.addTarget(routeTarget)
```

Constructor optional options with default values:

 - avoidTransitionSameRoute
    - true (default)
    - false
 - slash:
    - 'enforce' - it always adds `/` at the end of the url
    - 'omit' - it always remove `/` at the end of the url
    - null (default)
 - history:
    - 'memory' - is used as a reference implementation and may also be used i non-DOM environments, like React Native or Electron
    - 'hash' - is for use in legacy web browsers
    - 'push' - is for use in modern web browsers that support the HTML5 history API
 - defaultRoute:
    - '/' - initial route (default)
    - '/my-route' - will be default instead of `/`

To start listening on route changes you need to add `listen` listener.
You can use it in your root component like this:

```
const App = React.createClass({
  getInitialState() {
    return { activeComponent: router.getCurrentComponent() };
  },

  componentDidMount() {
    router.listen(() => {
      this.setState({
        activeComponent: router.getCurrentComponent()
      });
    });
  },
  render() {
    return div(null, this.state.activeComponent);
  }
});
```

Or in a similar fashion as the React router:

```
router.listen(component => React.render(component, mountElement));
```

#### Changing the route

You can change the route by calling the `transitionTo` method and a name of the route defined in route definition(s).

```
// Simple transition to a different page
const { transitionTo } = router.getRouterProps();
transitionTo('designs');

// Transition to a different page with params
transitionTo('project-detail', {
  params: {
    projectId: 42
  }
});
```

**TransitionTo optional options:**

 - methodType:
  - 'pushState' (default)
  - 'replaceState'
- params, state, query - Read more about it in the History [documentation](https://github.com/mjackson/history/blob/v2.x/docs/Glossary.md#locationdescriptor)
