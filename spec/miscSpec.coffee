describe '其他接口测试', ->

  describe '获取最新 Mac 客户端更新信息', ->

    it '当前版本是旧版本', (done) ->
      this.testGETAPI '/misc/latest_update?version=1.0.1'
      , 200
      , url: 'STRING'
      , done

    it '当前版本是最新版本', (done) ->
      this.testGETAPI '/misc/latest_update?version=1.0.2'
      , 204
      , null
      , done

    it '当前版本大于最新版本', (done) ->
      this.testGETAPI '/misc/latest_update?version=1.0.3'
      , 204
      , null
      , done

    it '错误的版本号', (done) ->
      this.testGETAPI '/misc/latest_update?version=abc'
      , 400
      , null
      , done

  describe '获取 Demo 演示所需要的群组和聊天室名单', ->

    it '成功', (done) ->
      this.testGETAPI '/misc/demo_square'
      , 200
      , code: 200
      , done
