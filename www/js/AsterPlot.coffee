d3 = require('d3')
d3.tip = require('d3-tip')
console.log 'd3', d3

module.exports = (options, data) ->

  options.domNode ?= document.body
  options.width ?= 500
  options.height ?= options.width
  radius = Math.min(options.width, options.height) / 2
  innerRadius = 0.3 * radius
  pie = d3.layout.pie().sort(null).value((d) ->
    d.width
  )
  tip = d3.tip().attr('class', 'd3-tip').offset([
    0
    0
  ]).html((d) ->
    d.data.label + ': <span style=\'color:orangered\'>' + d.data.score + '</span>'
  )
  arc = d3.svg.arc().innerRadius(innerRadius).outerRadius((d) ->
    (radius - innerRadius) * d.data.score / 100.0 + innerRadius
  )
  outlineArc = d3.svg.arc().innerRadius(innerRadius).outerRadius(radius)

  svg = d3.select(options.domNode)
    .append('svg')
    .attr('width', options.width)
    .attr('height', options.height)
    .append('g')
    .attr('transform', 'translate(' + options.width / 2 + ',' + options.height / 2 + ')')
  svg.call tip
  path = null
  outerPath = null
  score = null

  load = (data) ->
    data.forEach (d) ->
      d.id = d.id
      d.order = +d.order
      d.color = d.color
      d.weight = +d.weight
      d.score = +d.score
      d.width = +d.weight
      d.label = d.label
      return
    
    colors = d3.scale.category20()

    path = svg
    .selectAll('.solidArc')
    .data(pie(data))
    .enter()
    .append('path')
    .attr('fill', (d, i) ->
      d.data.color or colors(i)
    ).attr('class', 'solidArc').attr('stroke', 'gray').attr('d', arc).on('mouseover', tip.show).on('mouseout', tip.hide)
    outerPath = svg.selectAll('.outlineArc').data(pie(data)).enter().append('path').attr('fill', 'none').attr('stroke', 'gray').attr('class', 'outlineArc').attr('d', outlineArc)
    # calculate the weighted mean score
    score = data.reduce(((a, b) ->
      #console.log('a:' + a + ', b.score: ' + b.score + ', b.weight: ' + b.weight);
      a + b.score * b.weight
    ), 0) / data.reduce(((a, b) ->
      a + b.weight
    ), 0)
    score = svg.append('svg:text').attr('class', 'aster-score').attr('dy', '.35em').attr('text-anchor', 'middle').text(Math.round(score))
    return

  unload = ->
    if path
      path.remove()
    if outerPath
      outerPath.remove()
    if score
      score.remove()
    return

  load data
  {
    load: load
    unload: unload
  }
