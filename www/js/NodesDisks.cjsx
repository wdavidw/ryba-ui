
require './NodesDisks.styl'
React = require 'react'
require 'd3'
socket = require './socket.cjsx'
AsterPlot = require './AsterPlot.coffee'

NodeDisk = React.createClass
  componentDidMount: ->
    @plot = new AsterPlot domNode: @getDOMNode(), width: 260, []
  render: ->
    <div className="ryba-nodes-disk">
      <div>{@props.host}</div>
    </div>

Disks = React.createClass
  getInitialState: -> hosts: [], disks: {}
  componentDidMount: ->
    hosts = []
    socket.on 'jmx', (data) =>
      unless data.host in hosts
        hosts.push data.host 
      @setState hosts: hosts
      # Build disks object
      disks = {}
      for bean in data.jmx.beans
        continue unless bean.name is 'Hadoop:service=DataNode,name=DataNodeInfo'
        for volume, info of JSON.parse bean['VolumeInfo']
          disks[volume] = info
      # Update plot
      i = 0
      l = Object.keys(disks).length
      plot = for volume, info of disks
        score = 100 * info.usedSpace / (info.freeSpace + info.usedSpace)
        id: data.host, order: i++, weight: 1/l, score: score, width: 1, label: data.host
      @refs[data.host].plot.unload()
      @refs[data.host].plot.load plot
  onClick: (e) ->
    # toggle()
    # React.render <Disk />, document.getElementById('disk')
  toggle: ->
    $(@getDOMNode()).toggle()
  render: ->
    nodes = for host in @state.hosts.sort()
      <NodeDisk key="#{host}" ref="#{host}" host={host} /> # , disks={@disks[host]} 
    <div className="ryba-nodes-disks" onClick={@onClick}>{nodes}</div>

module.exports = Disks
