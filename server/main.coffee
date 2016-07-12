Zabbix    = require '/imports/monitoring/zabbix.coffee'
Services  = require '/imports/collections/services.coffee'
_ = require 'lodash'

getData = ->
  console.log "getData::begin"
  zabbix = new Zabbix()
  zabbix.login()
  res = zabbix.getItems 'web.test.fail', 'Zabbix server'
  x = _.filter res.result, (item) -> item.lastvalue isnt '0'

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
  console.log "getData::done"

# Meteor.setTimeout getData, 500
# Meteor.setInterval getData, 60000

zabbix = new Zabbix()
zabbix.login()

lastUpdatedTrigger = Services.findOne {type: 'trigger'}, sort: updatedOn: -1
console.log 'lastUpdatedTrigger', lastUpdatedTrigger

eventSearchObject = {object: 0, sortfield: 'clock'}
if lastUpdatedTrigger
  eventSearchObject.time_from = lastUpdatedTrigger.updatedOn.getTime() / 1000

console.log 'search', eventSearchObject
x = zabbix.call 'event.get', eventSearchObject
x = x.result #_.filter x.result, (e) -> e.objectid is "16513"
x = x.map (e) ->
  if trigger = Services.findOne {type: 'trigger', triggerid: e.objectid}
    console.log 'update trigger', e.objectid
    Services.update {_id : trigger._id},
      $set:
        value: e.value
        updatedOn: new Date(e.clock * 1000)
  else
    console.log 'insert trigger', e.objectid
    trigger = (zabbix.call 'trigger.get', {triggerids: e.objectid})?.result?[0]
    if trigger
      Services.insert
        type: 'trigger'
        triggerid: e.objectid
        description: trigger.description
        value: e.value
        updatedOn: new Date(e.clock * 1000)
