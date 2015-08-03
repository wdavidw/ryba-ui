

Chart = require 'chart.js'
mlpc = require './MultiLevelPieChart.js'
Please = require 'pleasejs'

module.exports = ->

  bytesToSize = (bytes) ->
    sizes = [
      'Bytes'
      'KB'
      'MB'
      'GB'
      'TB'
    ]
    if bytes == 0
      return '0 Byte'
    i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)))
    Math.round(bytes / 1024 ** i, 2) + ' ' + sizes[i]

  canvas = document.getElementById('demo')
  ctx = canvas.getContext('2d')
  counterLabel = document.getElementById('counter')
  counter = 0
  button = document.getElementById('submit_button')
  # Spawn the web worker ready to start generating file trees
  hdfsWorker = new Worker('/js/hdfs_nav/worker.js')

  # Bind a handler so we know when data is available

  hdfsWorker.onmessage = (event) ->

    mlpc(Chart)
    if !event.data.success
      try
        alert JSON.stringify event
      catch e
        alert 'Error'
      return
    if event.data.message == 'tree'
      data = event.data
      root = data.tree

      assignColor = (node) ->
        childLength = if node.children then node.children.length else 0
        base_color = node.color
        if base_color
          scheme = Please.make_scheme(Please.HEX_to_HSV(base_color),
            count: childLength
            scheme_type: 'analogous')
          $.each node.children, (index, child) ->
            child.color = scheme[index]
            assignColor child
            return
        return

      root.color = Please.make_color()[0]
      $.each root.children, (_, child) ->
        child.color = Please.make_color()[0]
        assignColor child
        return

      window.chart = new Chart(ctx).MultiLevelPie([ root ],
        animation: true
        segmentWidth: 25
        segmentHighlight: null
        tooltipTemplate: (c) ->
          bytesToSize(c.value) + ' (' + c.label + ')'
        responsive: false)

      canvas.onclick = (evt) ->
        element = window.chart.getSegmentsAtEvent(evt)
        if element
          alert element[0].label
        return

      counterLabel.innerHTML = ''
      counter = 0
    else if event.data.message == 'path'
      path = event.data.path
      rev = path.split('').reverse().join('')
      if rev.length > 140
        rev = rev.substr(0, 140)
        path = '...' + rev.split('').reverse().join('')
      counter++
      counterLabel.innerHTML = counter + ' paths processed (' + path + ')'
    return

  hdfsWorker.postMessage
    hdfs_namenode: 'http://localhost:3000/'
    hdfs_path: '/user/ryba/.staging'