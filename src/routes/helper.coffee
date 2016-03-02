express   = require 'express'
_         = require 'underscore'
Utility   = require('../util/util').Utility
APIResult = require('../util/util').APIResult

# 引用数据库对象和模型
[sequelize, User, Blacklist, Friendship, Group, GroupMember, GroupSync, DataVersion, VerificationCode, LoginLog] = require '../db'

GROUP_CREATOR = 0
GROUP_MEMBER  = 1

router = express.Router()

# 快速创建一个用户
router.post '/user/create', (req, res, next) ->
  # username      = req.body.username
  region        = req.body.region
  phone         = req.body.phone
  nickname      = req.body.nickname
  password      = req.body.password
  passwordSalt = _.random 1000, 9999
  passwordHash = Utility.hash password, passwordSalt

  User.create
    #username: username
    region: region
    phone: phone
    nickname: nickname
    passwordHash: passwordHash
    passwordSalt: passwordSalt.toString()
  .then (user) ->
    res.send new APIResult 200, Utility.encodeResults id: user.id

module.exports = router
