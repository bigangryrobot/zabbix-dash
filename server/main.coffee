Zabbix    = require '/imports/monitoring/zabbix.coffee'
Services  = require '/imports/collections/services.coffee'
_ = require 'lodash'

getData = ->
  console.log "getData::begin"
  zabbix = new Zabbix()
  zabbix.login()
  res = zabbix.getItems 'web.test.fail', 'Zabbix server'

  # find all services that should be deleted
  allCurrentServiceKeys = Services.find(type: 'web.test').map (s) -> s.key_
  allZabbixServiceKeys = res.result.map (i) -> i.key_
  serviceKeysThatShouldBeDeleted = _.difference allCurrentServiceKeys, allZabbixServiceKeys
  serviceKeysThatShouldBeDeleted.map (key) ->
    Services.remove {key_: key, type: 'web.test'}

  parseUrl = (key) -> (/\[(Check .+)\]/.exec key)[1]
  for item in res.result
    if service = Services.findOne { key_: item.key_, type: 'web.test' }
      Services.update {_id: service._id},
        $set:
          value: item.lastvalue
          updatedOn: new Date(item.lastclock * 1000)
    else
      scenario = (zabbix.getWebScenarioByName parseUrl item.key_).result?[0]
      Services.insert
        type: 'web.test'
        key_: item.key_
        value: item.lastvalue
        httptestid: scenario?.httptestid
        updatedOn: new Date(item.lastclock * 1000)
        zabbixUrl: "#{Meteor.settings.zabbix.url}/httpdetails.php?httptestid=#{scenario?.httptestid}"

  triggers = (zabbix.call 'trigger.get', {expandDescription: true, expandExpression:true, search: {status: 0}}).result
  for trigger in triggers
    if trigger.lastchange > 0 # triggers with a lastchange of 0 are not really in use
      l = (i) -> if i < 10 then "0#{i}" else i
      d = new Date(parseInt(trigger.lastchange) * 1000)
      date="#{d.getFullYear()}#{l d.getMonth()+1}#{l d.getDate()}#{l d.getHours()}#{l d.getMinutes()}00"
      host =  /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/.exec "#{trigger.description}#{trigger.expression}"
      Services.upsert {type: 'trigger', triggerid: trigger.triggerid},
        type: 'trigger'
        triggerid: trigger.triggerid
        description: trigger.description
        expression: trigger.expression
        value: trigger.value
        updatedOn: d
        host: host?[0]
        zabbixUrl: "#{Meteor.settings.zabbix.url}/events.php?filter_set=1&triggerid=#{trigger.triggerid}&period=60&stime=#{date}"

  console.log "getData::done"

Meteor.setTimeout getData, 500
Meteor.setInterval getData, 60000
