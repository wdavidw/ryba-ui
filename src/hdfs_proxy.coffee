
krb5 = require 'krb5'
request = require 'request'

process.env.NODE_TLS_REJECT_UNAUTHORIZED = 0
module.exports = (req, res) ->
  krb5.spnego
    principal: 'hdfs@HADOOP.RYBA',
    password: 'hdfs123',
    service_principal: "HTTP@master1.ryba"
  , (err, token) ->
    return res.send err if err
    request.get
      url: "https://master1.ryba:50470#{req.originalUrl}"
      headers:
        'Authorization': 'Negotiate ' + token
    , (err, response, body) ->
      try
        res.json err or JSON.parse body
      catch e
        res.json e.message