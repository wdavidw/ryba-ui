
$ = require 'jquery'

window.nodes_disks = ->
  NodesDisks = require './NodesDisks.cjsx'
  React = require 'react'
  $ -> React.render <NodesDisks />, document.getElementById('disk')

window.node_disks = ->
  NodeDisks = require './NodeDisks.cjsx'
  React = require 'react'
  $ -> React.render <NodeDisks />, document.getElementById('disk')

window.hdfs_nav = ->
  nav = require './hdfs_nav/index.coffee'
  $ nav
