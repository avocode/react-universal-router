React = require 'react'

componentA = React.createClass
  displayName: 'componentA'
  render: ->
    React.DOM.div null, 'componentA...'

componentB = React.createClass
  displayName: 'componentB'
  render: ->
    React.DOM.div null, 'componentB...'


module.exports = {
  componentA
  componentB
}
