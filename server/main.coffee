Zabbix = require '/imports/monitoring/zabbix.coffee'

getData = ->
  zabbix = new Zabbix()
  console.log 'Get data'
  zabbix.login()
  res = zabbix.getItems 'web.test.fail', 'Zabbix server'
  x = _.filter res.result, (item) -> console.log item; item.lastvalue isnt '0'
  console.log x

getData()
Meteor.setTimeout getData, 60000
