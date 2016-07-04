React = require 'react'
{ render } = require 'react-dom'
{ Meteor } = require 'meteor/meteor'

require '/imports/startup/client/index.cjsx'

App = require '/imports/ui/App.cjsx'

Meteor.startup ->
  render <App />, document.getElementById 'render-target'
