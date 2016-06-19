module.exports =
  # 认证 Cookie 名称，根据业务自行修改
  AUTH_COOKIE_NAME: 'rong_im_auth'
  # 昵称 Cookie 名称，根据业务自行修改
  NICKNAME_COOKIE_NAME: 'rong_im_nickname'
  # Cookie 加密密钥，请在部署时重新生成
  AUTH_COOKIE_KEY: '<-- 此处设置一个加密 Cookie 密钥 -->'
  # Cookie 加密密钥，请在部署时重新生成
  AUTH_COOKIE_MAX_AGE: '<-- 此处设置一个 Cookie 过期时间 -->'
  # 融云颁发的 App Key，请访问融云开发者后台：https://developer.rongcloud.cn
  RONGCLOUD_APP_KEY: '<-- 此处填写融云颁发的 App Key -->'
  # 融云颁发的 App Secret，请访问融云开发者后台：https://developer.rongcloud.cn
  RONGCLOUD_APP_SECRET: '<-- 此处填写融云颁发的 App Secret -->'
  # 融云短信服务提供的注册用户短信模板 Id
  RONGCLOUD_SMS_REGISTER_TEMPLATE_ID: '<-- 此处填写融云颁发的短信模板 Id -->'
  # 融云短信服务提供的重置密码短信模板 Id
  RONGCLOUD_SMS_RESET_PASSWORD_TEMPLATE_ID: '<-- 此处填写融云颁发的短信模板 Id -->'
  # 七牛颁发的 Access Key，请访问七牛开发者后台：https://portal.qiniu.com
  QINIU_ACCESS_KEY: '<-- 此处填写七牛颁发的 Access Key -->'
  # 七牛颁发的 Secret Key，请访问七牛开发者后台：https://portal.qiniu.com
  QINIU_SECRET_KEY: '<-- 此处填写七牛颁发的 Secret Key -->'
  # 七牛创建的空间名称，请访问七牛开发者后台：https://portal.qiniu.com
  QINIU_BUCKET_NAME: '<-- 此处填写七牛创建的空间名称 -->'
  # 七牛创建的空间域名，请访问七牛开发者后台：https://portal.qiniu.com
  QINIU_BUCKET_DOMAIN: '<-- 此处填写七牛创建的空间域名 -->'
  # N3D 密钥，用来加密所有的 Id 数字，不要小于 5 位
  N3D_KEY: '<-- 此处设置一个加密 Id 的密钥 -->'
  # 跨域支持所需配置的主机信息（请求者），包括请求服务器的域名和端口号
  CORS_HOSTS: 'http://web.sealtalk.im'
  # 本服务部署的 HTTP 端口号
  SERVER_PORT: '8585'
  # MySQL 数据库名称
  DB_NAME: '<-- 此处设置数据库名称 -->'
  # MySQL 数据库用户名
  DB_USER: '<-- 此处设置数据库用户名 -->'
  # MySQL 数据库密码
  DB_PASSWORD: '<-- 此处设置数据库密码 -->'
  # MySQL 数据库地址
  DB_HOST: '<-- 此处设置数据库的 IP 地址 -->'
  # MySQL 数据库端口号
  DB_PORT: '3306'
