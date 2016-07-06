React                       = require 'react'
{ createContainer }         = require 'meteor/react-meteor-data'
ReactGridLayout             = require 'react-grid-layout'
Services                    = require '/imports/collections/services.coffee'

RGL = ReactGridLayout.WidthProvider ReactGridLayout

getRglLayout = (failingServiceCount) ->
  console.log failingServiceCount
  if failingServiceCount > 0
    [
      {i: 'allServices', x: 0, y: 0, w: 1, h: 2, static: true}
      {i: 'servicesUp', x: 1, y: 0, w: 1, h: 2, static: true}
      {i: 'servicesDown', x: 3, y: 0, w: 4, h: 2, static: true}
    ]
  else
    [
      {i: 'allServices', x: 0, y: 0, w: 2, h: 2, static: true}
      {i: 'servicesUp', x: 2, y: 0, w: 2, h: 2, static: true}
      {i: 'servicesDown', x: 4, y: 0, w: 2, h: 2, static: true}
    ]


App = React.createClass
  displayName: 'ZabbixDash'
  render: ->
    layout = getRglLayout @props.failingServiceCount
    <RGL className="layout" layout=layout cols=6 rowHeight=50>
      <div className='serviceTotals allServices' key='allServices'>Monitored Services<div className="count">{@props.serviceCount}</div></div>
      <div className='serviceTotals okServices' key='servicesUp'>Up &amp; Running<div className="count">{@props.okServiceCount}</div></div>
      <div className='serviceTotals failingServices' key='servicesDown'>Failing<div className="count">{@props.failingServiceCount}</div></div>
    </RGL>


module.exports = createContainer (props) ->
  serviceCount: Services.find(type: 'web.test').count()
  okServiceCount: Services.find(type: 'web.test', value:'0').count()
  failingServiceCount: Services.find(type: 'web.test', value: {$ne: '0'}).count()
, App
