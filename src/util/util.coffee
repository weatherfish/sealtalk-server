crypto  = require 'crypto'
process = require 'process'
Config  = require '../conf'
N3D     = require './n3d'

class Utility
  @n3d = new N3D Config.N3D_KEY, 1, 4294967295

  @getCurrentUserId: (req) ->
    cookie = req.cookies[Config.AUTH_COOKIE_NAME]

    return null if not cookie

    parseInt @decryptText cookie, Config.AUTH_COOKIE_KEY

  @getCurrentUserNickname: (req) ->
    cookie = req.cookies[Config.NICKNAME_COOKIE_NAME]

    return null if not cookie

    @decryptText cookie, Config.AUTH_COOKIE_KEY

  @setAuthCookie: (res, userId) ->
    value = @encryptText userId, Config.AUTH_COOKIE_KEY

    res.cookie Config.AUTH_COOKIE_NAME, value,
      #secure: true
      httpOnly: true
      maxAge: Config.AUTH_COOKIE_MAX_AGE
      expires: new Date(Date.now() + Config.AUTH_COOKIE_MAX_AGE)

  @setNicknameCookie: (res, nickname) ->
    value = @encryptText nickname, Config.AUTH_COOKIE_KEY

    res.cookie Config.NICKNAME_COOKIE_NAME, value,
      #secure: true
      httpOnly: true
      maxAge: Config.AUTH_COOKIE_MAX_AGE
      expires: new Date(Date.now() + Config.AUTH_COOKIE_MAX_AGE)

  @encryptText: (text, password) ->
    salt = @random 1000, 9999
    text = salt + '|' + text + '|' + Date.now()
    cipher = crypto.createCipher 'aes-256-ctr', password
    crypted = cipher.update text, 'utf8', 'hex'
    crypted += cipher.final 'hex'

  @decryptText: (text, password) ->
    decipher = crypto.createDecipher 'aes-256-ctr', password
    dec = decipher.update text, 'hex', 'utf8'
    dec += decipher.final 'utf8'
    strs = dec.split('|')

    if strs.length isnt 3
      throw new Error 'Invalid cookie value!'

    strs[1]

  @hash: (text, salt) ->
    text = text + '|' + salt
    sha1 = crypto.createHash 'sha1'
    sha1.update text, 'utf8'
    sha1.digest 'hex'

  @random: (min, max) ->
    Math.floor(Math.random() * (max - min)) + min

  @isEmpty: (obj) ->
    obj is '' or obj is null or obj is undefined or (Array.isArray(obj) and obj.length is 0)

  # 转换 Ids 参数中的加密字符串为数字 Ids
  @decodeIds: (obj) ->
    return null if obj is null

    if Array.isArray obj
      obj.map (element) ->
        return null if typeof element isnt 'string'

        Utility.stringToNumber element
    else if typeof obj is 'string'
      Utility.stringToNumber obj
    else
      return null

  # 转换数字 Id 为加密 Id
  @encodeId: (str) ->
    Utility.numberToString str

  # 转换结果集中的数字 Id 为加密 Id
  @encodeResults: (obj, keys) ->
    # 默认转换 id
    keys = 'id' if not keys
    # 把字符串参数转换为数组
    keys = [keys] if typeof keys is 'string'

    isSubArrayKey = keys.length > 0 and Array.isArray keys[0]

    replaceKeys = (obj) ->
      return null if obj is null

      # 将 Sequelize Model 转换为 JSON
      obj = obj.dataValues if obj.dataValues

      if isSubArrayKey
        keys.forEach (key) ->
          # 将 Sequelize Model 转换为 JSON
          obj[key[0]] = obj[key[0]].dataValues if obj[key[0]].dataValues

          obj[key[0]][key[1]] = Utility.numberToString obj[key[0]][key[1]]
      else
        keys.forEach (key) ->
          obj[key] = Utility.numberToString obj[key]

      return obj

    if Array.isArray obj
      obj.map (item) ->
        replaceKeys item
    else
      replaceKeys obj

  # 将字符串 Id 反解为数字 Id
  @stringToNumber: (str) ->
    try
      @n3d.decrypt str
    catch
      null

  # 将数字 Id 转换为字符串 Id
  @numberToString: (num) ->
    try
      @n3d.encrypt num
    catch
      null

# 定义一个通用 API 返回结果模型
class APIResult
  constructor: (@code, @result, @message) ->
    if @code is null or @code is undefined
      throw new Error 'Code is null.'

    # 空内容不需要返回，以节省流量
    delete @result if @result is null
    delete @message if @message is null or process.env.NODE_ENV isnt 'development'

# 定义一个通用 HTTP 错误模型
class HTTPError
  constructor: (@message, @statusCode) ->

module.exports.Utility    = Utility
module.exports.APIResult  = APIResult
module.exports.HTTPError  = HTTPError
