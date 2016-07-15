React                       = require 'react'
_                           = require 'lodash'
TimeAgo                     = require('react-timeago').default
{ createContainer }         = require 'meteor/react-meteor-data'
ReactGridLayout             = require 'react-grid-layout'
Services                    = require '/imports/collections/services.coffee'

RGL = ReactGridLayout.WidthProvider ReactGridLayout

defaultRglLayout = [
  {i: 'allServices', x: 0, y: 0, w: 4, h: 2, static: true}
  {i: 'servicesUp', x: 4, y: 0, w: 4, h: 2, static: true}
  {i: 'servicesDown', x: 8, y: 0, w: 4, h: 2, static: true}
]

createWidget = (check) ->
  console.log check
  <div key={check._id} className="widget failing">
    {switch check.type
      when 'web.test' then createHttpWidget check
      when 'trigger' then createTriggerWidget check
      else <div>Dont know how to render check type {checl.type}</div>
    }
  </div>


createTriggerWidget = (trigger) ->
  <div className="inner trigger">
    {if not trigger.host or trigger.description.match trigger.host
      <h3>{trigger.description}</h3>
    else
      <h3>{trigger.host}: {trigger.description}</h3>
    }
    <div className='lastChecked'>Since: <TimeAgo date={new Date(TimeSync.serverTime(trigger.updatedOn))} /></div>
    <a className="externalLink" href={trigger.zabbixUrl} target='_blank'><i className="material-icons">open_in_new</i></a>
  </div>

createHttpWidget = (service) ->
  parseUrl = (key) -> (/\[Check (.+)\]/.exec key)[1]
  <div className="inner service">
    <h3>HTTP Check failed</h3>
    <a target="_blank" href="#{parseUrl service.key_}">{parseUrl service.key_}</a> <br />
    <div className='lastChecked'>Last checked: <TimeAgo date={new Date(TimeSync.serverTime(service.updatedOn))} /></div>
    <a className="externalLink" href={service.zabbixUrl} target='_blank'><i className="material-icons">open_in_new</i></a>
  </div>

App = React.createClass
  displayName: 'ZabbixDash'

  getRglLayout: ->
    x = -3
    y = 2
    p = @props.failingServices.map (service) ->
      if (x += 3) > 9 then x = 0; y += 2;
      i: "#{service._id}", x: x, y: y, w: 3, h: 2, static: false
    _.union defaultRglLayout, p

  calcRootClass: -> if @props.failingServiceCount > 0 then 'failing' else 'ok'

  render: ->
    console.log @props.failingServices
    layout = @getRglLayout()
    staticComponents = [
      <div className='widget serviceTotals allServices' key='allServices'>Total Checks<div className="count">{@props.serviceCount}</div></div>
      <div className='widget serviceTotals okServices' key='servicesUp'>Passing<div className="count">{@props.okServiceCount}</div></div>
      <div className='widget serviceTotals failingServices' key='servicesDown'>Failing<div className="count">{@props.failingServiceCount}</div></div>
    ]
    <div className="root #{@calcRootClass()}">
      <RGL className="layout" layout=layout cols=12 rowHeight=50>
        {_.union staticComponents, @props.failingServices.map createWidget }
      </RGL>
      {if @props.failingServiceCount > 0
        <div className="emoji failPlaceholder"></div>
      else
        <div className="emoji okPlaceholder">👍</div>
      }
    </div>


module.exports = createContainer (props) ->
  serviceCount: Services.find().count()
  okServiceCount: Services.find(value:'0').count()
  failingServiceCount: Services.find(value: {$ne: '0'}).count()
  failingServices: Services.find({value: {$ne: '0'}}, sort: updatedOn: -1).fetch()
, App
