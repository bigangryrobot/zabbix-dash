Zabbix    = require '/imports/monitoring/zabbix.coffee'
Services  = require '/imports/collections/services.coffee'

getData = ->
  zabbix = new Zabbix()
  console.log 'Get data'
  zabbix.login()
  res = zabbix.getItems 'web.test.fail', 'Zabbix server'
  x = _.filter res.result, (item) -> console.log item; item.lastvalue isnt '0'

  # find all services that should be deleted
  allCurrentServiceKeys = Services.find(type: 'web.test').map (s) -> s.key_
  allZabbixServiceKeys = res.result.map (i) -> i.key_
  serviceKeysThatShouldBeDeleted = _.difference allCurrentServiceKeys, allZabbixServiceKeys
  serviceKeysThatShouldBeDeleted.map (key) ->
    Services.remove {key_: key, type: 'web.test'}

  res.result.map (item) ->
    console.log item
    Services.upsert { key_: item.key_, type: 'web.test' },
      key_: item.key_
      type: 'web.test'
      value: item.lastvalue
      updatedOn: new Date(item.lastclock * 1000)

getData()
Meteor.setInterval getData, 60000
