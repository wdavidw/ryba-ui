
krb5 = require 'krb5'
url = require 'url'
request = require 'request'
process.env.NODE_TLS_REJECT_UNAUTHORIZED = 0

module.exports = (config, callback) ->
  # Configuration
  config.fetch ?= {}
  config.fetch.urls = [config.fetch.urls] unless Array.isArray config.fetch.urls
  config.fetch.interval ?= 3*1000 # 3s
  for location, i in config.fetch.urls
    location = config.fetch.urls[i] = {url: location} if typeof location is 'string'
    location.hostname ?= url.parse(location.url).hostname
    location.principal ?= config.hdfs.principal
    location.password ?= config.hdfs.password
    location.service_principal ?= "HTTP@#{location.hostname}"
  # Work
  connect = (location, callback) ->
    krb5.spnego
      principal: location.principal
      password: location.password
      service_principal: location.service_principal
    , callback
  fetch = (location, token, callback) ->
    request.get
      url: location.url
      headers:
        'Authorization': 'Negotiate ' + token
    , (err, response, body) ->
      callback err, body
  orchestrate = (location, callback) ->
    _connect = ->
      connect location, (err, token) ->
        return callback err if err
        return callback Error "Unsynchronize Clocks" if token is ''
        _fetch token
    _fetch = (token) ->
      fetch location, token, (err, data) ->
        callback err, location, data
        setTimeout (-> _connect()), config.fetch.interval
    _connect()
  orchestrate location, callback for location in config.fetch.urls
    