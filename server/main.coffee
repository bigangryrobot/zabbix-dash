Zabbix    = require '/imports/monitoring/zabbix.coffee'
Services  = require '/imports/collections/services.coffee'

getData = ->
  zabbix = new Zabbix()
  console.log 'Get data'
  zabbix.login()
  res = zabbix.getItems 'web.test.fail', 'Zabbix server'
  x = _.filter res.result, (item) -> console.log item; item.lastvalue isnt '0'
  console.log x
  res.result.map (item) ->
    Services.upsert { key_: item.key_, type: 'web.test' },
      key_: item.key_
      type: 'web.test'
      value: item.lastvalue
      updatedOn: new Date(item.lastclock)

getData()
Meteor.setTimeout getData, 60000
