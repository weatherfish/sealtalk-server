express           = require 'express'
_                 = require 'underscore'
jsonfile          = require 'jsonfile'
path              = require 'path'
semver            = require 'semver'

Utility           = require('../util/util').Utility
APIResult         = require('../util/util').APIResult

# 引用数据库对象和模型
[sequelize, User, Blacklist, Friendship, Group] = require '../db'

router = express.Router()

# 获取最新 Mac 客户端更新信息
router.get '/latest_update', (req, res, next) ->
  clientVersion = req.query.version

  try
    squirrelConfig = jsonfile.readFileSync path.join __dirname, '../squirrel.json'

    if (semver.valid(clientVersion) is null) or (semver.valid(squirrelConfig.version) is null)
      return res.status(400).send 'Invalid version.'

    if semver.gte(clientVersion, squirrelConfig.version)
      res.status(204).end()
    else
      res.send
        url: squirrelConfig.url
        name:squirrelConfig.name
        notes:squirrelConfig.notes
        pub_date:squirrelConfig.pub_date
  catch err
    next err

# 获取 Demo 演示所需要的群组和聊天室名单
router.get '/demo_square', (req, res, next) ->
  try
    demoSquareData = jsonfile.readFileSync path.join __dirname, '../demo_square.json'

    groupIds = _.chain(demoSquareData).where({ type: 'group' }).pluck('id').value()

    Group.findAll
      where:
        id:
          $in:
            groupIds
      attributes: [
        'id'
        'name'
        'portraitUri'
        'memberCount'
      ]
    .then (groups) ->
      demoSquareData.forEach (item) ->
        if item.type is 'group'
          group = _.findWhere(groups, { id: item.id })
          group = { name: 'Unknown', portraitUri: '', memberCount: 0 } if not group

          item.name = group.name
          item.portraitUri = group.portraitUri
          item.memberCount = group.memberCount
          item.maxMemberCount = group.maxMemberCount

      res.send new APIResult 200, Utility.encodeResults demoSquareData
  catch err
    next err

module.exports = router
