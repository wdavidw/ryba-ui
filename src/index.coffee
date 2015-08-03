
path = require 'path'
http = require 'http'
nib = require 'nib'
express = require 'express'
bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'
methodOverride = require 'method-override'
session = require 'express-session'
errorhandler = require 'errorhandler'
serve_favicon = require 'serve-favicon'
jade_static = require 'connect-jade-static'
try
  config = require '../data/config'
catch e then console.log 'No configation found "./data/config"'

app = express()
server = http.Server(app)

fetch = require './fetch'

io = require('socket.io')(server)
io.on 'connection', (socket) ->
  fetch config, (err, options, data) ->
    return if err
    socket.emit 'jmx',
      host: options.host
      jmx: JSON.parse data
  socket.on 'cmd', (data) ->
    console.log data

# app.get '/data.json', (req, res) ->
#   fetch.latest (err, body) ->
#     res.json err or body

app.set 'views', path.resolve __dirname, '../www'
app.set 'view engine', 'jade'
app.use bodyParser.json()
app.use bodyParser.urlencoded()
app.use cookieParser 'my secret'
app.use methodOverride '_method'
app.use session secret: 'my secret', resave: true, saveUninitialized: true

app.get '/', (req, res) ->
  res.render 'index.jade'

app.get /^\/webhdfs\/v1/, require './hdfs_proxy'

app.use jade_static
  baseDir: path.join __dirname, '/../www'
  baseUrl: '/'
  maxAge: 86400
  serveIndex: true
  jade: pretty: true

webpackDevMiddleware = require 'webpack-dev-middleware'
webpack = require 'webpack'

compiler = webpack
  context: __dirname + "/../www"
  entry: ['./js/ryba.cjsx']
  output:
    path: __dirname + '/../www/build'
    filename: 'bundle.js'
  # output: path: '/'
  plugins: [
    new webpack.ProvidePlugin
      $: "jquery"
      jQuery: "jquery"
      "windows.jQuery": "jquery"
  ,
    new webpack.ProvidePlugin
      Chart: "../../bower_components/chartjs/Chart.js"
  ]
  module:
    loaders: [
      { test: /\.styl$/, loader: 'style-loader!css-loader!stylus-loader' },
      { test: /\.css$/, loader: 'style-loader!css-loader' },
      { test: /\.coffee$/, loader: 'coffee-loader' },
      { test: /\.cjsx$/, loader: 'coffee-jsx-loader' },
      { test: /\.jsx$/, loader: 'jsx-loader' },
      { test: /\.less$/, loader: 'style-loader!css-loader!less-loader' },
      { test: /\.(png|jpg)$/, loader: 'url-loader?limit=8192'},
      { test: /\.woff(\?v=\d+\.\d+\.\d+)?$/, loader: "url?limit=10000&minetype=application/font-woff" },
      { test: /\.woff2(\?v=\d+\.\d+\.\d+)?$/, loader: "url?limit=10000&minetype=application/font-woff2" },
      { test: /\.ttf(\?v=\d+\.\d+\.\d+)?$/, loader: "url?limit=10000&minetype=application/octet-stream" },
      { test: /\.eot(\?v=\d+\.\d+\.\d+)?$/, loader: "file" },
      { test: /\.svg(\?v=\d+\.\d+\.\d+)?$/, loader: "url?limit=10000&minetype=image/svg+xml" },
    ]

app.use webpackDevMiddleware compiler,
  devtool: 'eval'
  hot: true
  progress: true
  colors: true
  'content-base': 'build'

serve_static = require 'serve-static'
app.use serve_static path.resolve __dirname, '../www'

serve_index = require 'serve-index'
app.use serve_index path.resolve __dirname, '../www'

app.use (err, req, res, next) ->
  code = if typeof err.code is 'number' then err.code else 500
  code = 404 if err.code is 'ENOENT'
  console.log err
  res.status(code).render 'error.jade', error: err

server.listen 3000
module.exports = server






