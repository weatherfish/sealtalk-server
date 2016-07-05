express           = require 'express'
_                 = require 'underscore'
debug             = require 'debug'
cookieParser      = require 'cookie-parser'
bodyParser        = require 'body-parser'
compression       = require 'compression'
cors              = require 'cors'
jsonfile          = require 'jsonfile'
path              = require 'path'

Config            = require './conf'
Utility           = require('./util/util').Utility
APIResult         = require('./util/util').APIResult
HTTPError         = require('./util/util').HTTPError
userRouter        = require './routes/user'         # 引用用户相关接口
friendshipRouter  = require './routes/friendship'   # 引用好友相关接口
groupRouter       = require './routes/group'        # 引用群组相关接口
miscRouter        = require './routes/misc'         # 引用其他功能接口

log       = debug 'app:log'
logError  = debug 'app:error'
logPath   = debug 'app:path'

app = express()

app.use compression()       # 使用内容压缩
app.use cookieParser()      # 使用 Cookie 解析器
app.use bodyParser.json()   # 使用 Body 解析器
app.use cors                # 使用 CORS，支持跨域
  origin: Config.CORS_HOSTS
  credentials: true

# 前置身份验证
app.all '*', (req, res, next) ->
  logPath 'Request: %s %s %s', (req.method + ' ').substr(0, 4), req.originalUrl, JSON.stringify(req.body).replace(/"password":".*?"/, '"password":"**********"')

  # 不需要验证身份的路径
  for reqPath in [
    '/user/login'
    '/user/register'
    '/user/reset_password'
    '/user/send_code'
    '/user/verify_code'
    '/user/get_sms_img_code'
    '/user/check_username_available'
    '/user/check_phone_available'
    '/misc/latest_update'
    '/misc/demo_square'
    /\/helper\/.*/
  ]
    if (typeof reqPath is 'string' and req.path is reqPath) or (typeof reqPath is 'object' and reqPath.test req.path)
      return next() # 跳过验证

  currentUserId = Utility.getCurrentUserId req

  # 无法获取用户 Id，即表示没有登录
  if not currentUserId
    return res.status(403).send 'Not loged in.'

  next()

parameterPreprocessor = (req, res, next) ->
  for prop of req.body
    if Utility.isEmpty(req.body[prop]) and prop isnt 'displayName'
      return res.status(400).send "Empty #{prop}."

    if prop.endsWith('Id') or prop.endsWith('Ids')
      req.body['encoded' + prop[0].toUpperCase() + prop.substr(1)] = req.body[prop]
      req.body[prop] = Utility.decodeIds req.body[prop]

  next()

errorHandler = (err, req, res, next) ->
  if err instanceof HTTPError
    return res.status(err.statusCode).send err.message

  logError err

  res.status(500).send err.message || 'Unknown error.'

app.options '*', cors()                 # 跨域支持
app.use parameterPreprocessor           # 参数判断和转换
app.use '/user', userRouter             # 加载用户相关接口
app.use '/friendship', friendshipRouter # 加载好友相关接口
app.use '/group', groupRouter           # 加载群组相关接口
app.use '/misc', miscRouter             # 加载其他功能接口

# IMPORTANT !!!
# 开发测试环境支持，上线时务必将 NODE_ENV 设置为 production 以屏蔽相关接口
# IMPORTANT !!!
if app.get('env') is 'development'
  # 引用并加载开发测试环境的测试辅助接口
  helperRouter = require './routes/helper'
  app.use '/helper', helperRouter

app.use errorHandler

# 开启端口监听
server = app.listen Config.SERVER_PORT, ->
  console.log 'SealTalk Server listening at http://%s:%s in %s mode.',
    server.address().address,
    server.address().port,
    app.get('env')

module.exports = app
