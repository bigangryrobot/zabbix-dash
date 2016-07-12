Zabbix    = require '/imports/monitoring/zabbix.coffee'
Services  = require '/imports/collections/services.coffee'

getData = ->
  zabbix = new Zabbix()
  console.log 'Get data'
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
  res.result.map (item) ->
    # console.log item
    scenario = (zabbix.getWebScenarioByName parseUrl item.key_).result?[0]
    Services.upsert { key_: item.key_, type: 'web.test' },
      key_: item.key_
      type: 'web.test'
      value: item.lastvalue
      httptestid: scenario?.httptestid
      updatedOn: new Date(item.lastclock * 1000)
      zabbixUrl: "#{Meteor.settings.zabbix.url}/httpdetails.php?httptestid=#{scenario?.httptestid}"

#getData()
Meteor.setInterval getData, 60000
