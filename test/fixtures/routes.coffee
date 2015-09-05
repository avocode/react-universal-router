module.exports =
  '/projects': 'project-manager/list'
  '/projects/:id': 'project-manager/detail'
  '/project/:id':
    redirectTo: '/projects/:id'
  404: 'notFoundComponent'
  '/': 'index'
