React                       = require 'react'
{ createContainer }         = require 'meteor/react-meteor-data'
ReactGridLayout             = require 'react-grid-layout'
Services                    = require '/imports/collections/services.coffee'

RGL = ReactGridLayout.WidthProvider ReactGridLayout


App = React.createClass
  displayName: 'ZabbixDash'
  render: ->
    layout = [
      {i: 'allServices', x: 0, y: 0, w: 1, h: 2, static: true}
      {i: 'servicesUp', x: 1, y: 0, w: 1, h: 2}
      {i: 'servicesDown', x: 2, y: 0, w: 1, h: 2}
    ]
    <RGL className="layout" layout=layout cols=3 rowHeight=50 width=1200>
      <div key='allServices'>{@props.serviceCount}</div>
      <div key='servicesUp'>b</div>
      <div key='servicesDown'>c</div>
    </RGL>


module.exports = createContainer (props) ->
  serviceCount: Services.find().count()
, App
