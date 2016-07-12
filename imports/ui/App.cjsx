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

createHttpWidget = (service) ->
  console.log service
  parseUrl = (key) -> (/\[Check (.+)\]/.exec key)[1]
  <div key={service._id} className="widget service">
    <div className="inner">
      <h3>HTTP Check failed</h3>
      <a target="_blank" href="#{parseUrl service.key_}">{parseUrl service.key_}</a> <br />
      <div className='lastChecked'>Last checked: <TimeAgo date={new Date(TimeSync.serverTime(service.updatedOn))} /></div>
      <a className="externalLink" href={service.zabbixUrl} target='_blank'><i className="material-icons">open_in_new</i></a>
    </div>
  </div>

App = React.createClass
  displayName: 'ZabbixDash'

  getRglLayout: ->
    x = -3
    p = @props.failingServices.map (service) ->
      if (x += 3) > 9 then x = 0
      i: "#{service._id}", x: x, y: 2, w: 3, h: 2, static: false
    _.union defaultRglLayout, p

  calcRootClass: -> if @props.failingServiceCount > 0 then 'failing' else 'ok'

  render: ->
    layout = @getRglLayout()
    console.log 'layout', layout
    staticComponents = [
      <div className='widget serviceTotals allServices' key='allServices'>Monitored Services<div className="count">{@props.serviceCount}</div></div>
      <div className='widget serviceTotals okServices' key='servicesUp'>Up &amp; Running<div className="count">{@props.okServiceCount}</div></div>
      <div className='widget serviceTotals failingServices' key='servicesDown'>Failing<div className="count">{@props.failingServiceCount}</div></div>
    ]
    <div className="root #{@calcRootClass()}">
      <RGL className="layout" layout=layout cols=12 rowHeight=50>
        {_.union staticComponents, @props.failingServices.map createHttpWidget }
      </RGL>
        {if @props.failingServiceCount > 0
          <div className="emoji failPlaceholder">👎</div>
        else
          <div className="emoji okPlaceholder">👍</div>
        }
    </div>


module.exports = createContainer (props) ->
  serviceCount: Services.find(type: 'web.test').count()
  okServiceCount: Services.find(type: 'web.test', value:'0').count()
  failingServiceCount: Services.find(type: 'web.test', value: {$ne: '0'}).count()
  failingServices: Services.find(type: 'web.test', value: {$ne: '0'}).fetch()
, App
