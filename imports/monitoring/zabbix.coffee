{ Meteor }  = require 'meteor/meteor'
{ HTTP }    = require 'meteor/http'



ZABBIX_API_URL = Meteor.settings.zabbix.api_url
ZABBIX_HOST_ID = Meteor.settings.zabbix.host_id
ZABBIX_USER = Meteor.settings.zabbix.user
ZABBIX_USER_PASSWORD = Meteor.settings.zabbix.password

module.exports = ->
  _authToken = null
  _id = 1

  call: call = (method, params) ->
    rpcObj =
      jsonrpc:'2.0'
      id: _id
      auth: _authToken
      method: method
      params: params
    _id += 1
    (HTTP.call 'POST', ZABBIX_API_URL, data: rpcObj).data
    # JSON.parse (request 'POST', ZABBIX_API_URL, json: rpcObj).getBody()

  getWebScenarios: ->
    call 'httptest.get',
      output: ['name']
      selectSteps: 'extend'

  deleteWebScenario: (id) ->
    call 'httptest.delete', [id]

  updateWebScenario: (id, stepid, url, statusCode) ->
    call 'httptest.update',
      httptestid: id
      steps: [
        stepid: stepid
        name: 'check url'
        url: url
        status_codes: statusCode
        no: 1
      ]

  createWebScenario: (name, url, statusCode, hostId) ->
    call 'httptest.create',
      name: name
      hostid: hostId
      steps: [
        name: 'check url'
        url: url
        status_codes: statusCode
        no: 1
      ]

  getItems: (key_, host) ->
    call 'item.get',
      output: 'extend'
      host: host
      webitems: true
      search:
        key_: key_

  login: ->
    unless _authToken
      _authToken = (call 'user.login', (user: ZABBIX_USER, password: ZABBIX_USER_PASSWORD)).result
