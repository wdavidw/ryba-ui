
require('./NodeDisks.styl')
React = require 'react'
require 'd3'
socket = require './socket.cjsx'
c3 = require 'c3'

md5 = require 'blueimp-md5'

hash = (str) ->
  h = 0
  i = chr = len = null
  return h if str.length is 0
  for i in [0...str.length]
    chr   = str.charCodeAt i
    h  = ((h << 5) - h) + chr
    h |= 0; # Convert to 32bit integer
  h

bytes = (fileSizeInBytes) ->
    i = -1
    byteUnits = ['kB', ' MB', ' GB', ' TB', 'PB', 'EB', 'ZB', 'YB']
    while fileSizeInBytes > 1024
      fileSizeInBytes = fileSizeInBytes / 1024
      i++
    Math.max(fileSizeInBytes, 0.1).toFixed(1) + (byteUnits[i] || 'B')
console.log 'node_disks 1'
NodeDisk = React.createClass
  componentDidMount: ->
    @pie = c3.generate
      bindto: @getDOMNode()
      data:
        columns: []
        type : 'donut'
        colors:
          'free': 'green'
          'used': 'red'
          'reserved': 'grey'
      donut:
        title: @props.title
        columns: []
  componentWillUnmount: ->
    @pie.destroy()
  render: ->
    <div className="ryba-disk">ok</div>

NodeDisks = React.createClass
  getInitialState: -> disks: {}
  componentDidMount: ->
    socket.on 'jmx', (data) =>
      # Build disks object
      disks = {}
      for bean in data.jmx.beans
        continue unless bean.name is 'Hadoop:service=DataNode,name=DataNodeInfo'
        for volume, info of JSON.parse bean['VolumeInfo']
          disks[volume] = info
      @setState disks: disks
      for volume, info of disks
        @refs[volume].pie.load
          columns: [
            ['free', info.freeSpace]
            ['used', info.usedSpace]
            ['reserved', info.reservedSpace]
          ]
  render: ->
    disks = for volume, info of @state.disks
      <NodeDisk key="#{md5 volume}" ref="#{volume}" title="#{volume}" />
    <div className="ryba-disks">{disks}</div>

module.exports = NodeDisks
