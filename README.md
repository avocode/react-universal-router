React Universal Router
=========

**Finally a simple and universal router for React**


## Motivation



## Example


### Definition of routes
```
module.exports = {
  '/': 'project-manager/projects',
  '/designs': 'project-manager/designs',
  '/project/:projectId': 'project-manager/detail',
  '404': 'project-manager/notFound'
}
```

### Definition of targets
```
module.exports = {
  component: MyReactComponent,
  states: {
    'projects': {
      activeItem: 'projects'
    },
    'designs': {
      activeItem: 'designs'
    },
    'project-detail': {
      activeItem: 'project-detail'
    },
  }
}
```

### Actual usage
```
router = new Router()
router.addRoutes(routes)
router.addTarget(routeTarget, 'project-manager')
```
