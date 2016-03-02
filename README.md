# demo-server-v2-nodejs
SealTalk app server powered by RongCloud.

# 配置安装

## 开发环境配置

### 安装 Node.js 环境

请自行安装 Node.js 环境，过程略...

### 安装全局 Node.js 包

```
npm install -g grunt-cli
```

### 安装项目依赖的 Node.js 包

在项目根目录下执行。

```
npm install
```

## 项目配置

### 基础配置

请修改 conf.coffee 文件中的相关配置，不可跳过。

如果您熟悉项目中使用的 Sequelize 数据库框架，也可以自行安装配置其他类型的数据库。但需要修改 db.coffee 中相应的 SQL 语句。

### MySQL 安装

请自行安装 MySQL，过程略...

### MySQL 环境配置

请创建一个新的数据库，修改 conf.coffee 文件中的相关配置对应新创建的数据库。

## 初始化数据库

在项目根目录下执行。

```
npm run initdb
```
## 启动开发环境

### 编译源码

在项目根目录下执行。

```
grunt build
```

build 任务会自动监视相关文件变化并自动重新编译。

### 启动接口服务器

在项目根目录下执行

```
grunt nodemon
```

nodemon 任务会自动监视相关文件变化并自动重新启动服务器。

### 启动单元测试和代码覆盖率统计

在项目根目录下执行，注意，运行前需要先终止 `grunt nodemon`。

```
npm test
```

## 生产环境安装配置

### 编译部署文件

环境配置等步骤同开发环境配置，到`编译源码`步骤，转为在项目根目录下执行。

```
grunt release
```

然后将 `dist` 目录拷贝到部署路径即可，请用 `PM2` 等工具启动 `index.js` 文件。

### 修改配置文件

配置文件是 `dist` 下的 `conf.js` 文件，请根据需要配置。

### 修改环境变量

生产环境下请 **务必** 设置 `NODE_ENV=production`，否则会将测试辅助接口和功能暴露导致安全问题。

## 客户端数据同步策略说明

通过以版本号为基础的数据同步策略，能够极大的降低客户端到服务器的请求次数和流量，提高业务性能和用户体验。注意：客户端数据同步策略并不需要强制使用。

### 本地缓存数据库设计

客户端本地建立一套如下表格作为本地数据缓存：用户表、黑名单表、好友关系表、加入的群组表、加入的群组的成员关系表，用来存储需要的数据。各表结构如下：

用户表（当前用户的好友）：

| 字段名       |    数据类型    |    说明   |
|-------------|:-------------:|----------|
| id          | INT UNSIGNED  | 用户 Id |
| nickname    | VARCHAR(32)   | 用户的昵称 |
| portraitUri | VARCHAR(256)  | 用户的头像 |
| timestamp   | BIGINT        | 时间戳（版本号） |

黑名单表：

| 字段名       |    数据类型    |    说明   |
|-------------|:-------------:|----------|
| friendId    | INT UNSIGNED  | 好友 Id |
| status      | TINYINT       | 黑名单状态，参考 db.coffee |
| timestamp   | BIGINT        | 时间戳（版本号） |

好友关系表：

| 字段名       |    数据类型    |    说明   |
|-------------|:-------------:|----------|
| friendId    | INT UNSIGNED  | 好友 Id |
| displayName | VARCHAR(32)   | 好友屏显名 |
| status      | INT           | 好友关系状态，参考 db.coffee |
| timestamp   | BIGINT        | 时间戳（版本号）|

加入的群组表：

| 字段名       |    数据类型    |    说明   |
|-------------|:-------------:|----------|
| id          | INT UNSIGNED  | 群组 Id |
| name        | VARCHAR(32)   | 群组名称 |
| portraitUri | VARCHAR(256)  | 群组头像 |
| displayName | VARCHAR(32)   | 当前用户在群组中的屏显名 |
| role        | INT           | 当前用户在群组中的权限，参考 db.coffee |
| timestamp   | BIGINT        | 时间戳（版本号）|

加入的群组的成员关系表：

| 字段名       |    数据类型    |    说明   |
|-------------|:-------------:|----------|
| groupId     | INT UNSIGNED  | 群组成员所属群组 Id |
| memberId    | INT UNSIGNED  | 群组成员 Id |
| displayName | VARCHAR(32)   | 群组成员的屏显名 |
| role        | INT           | 群组成员的权限，参考 db.coffee |
| nickname    | VARCHAR(32)   | 群组成员的昵称 |
| portraitUri | VARCHAR(256)  | 群组成员的头像 |
| timestamp   | BIGINT        | 时间戳（版本号）|

### 同步策略

客户端本地保存一个当前版本号数据，如 `version`，用户创建时，本地值为 `0`

1、登录同步：

每次登录后，调用服务器 `GET /user/sync/:version` 接口，将本地的版本号 `versoin` 传递给服务端，服务端会返回 `versoin` 之后所有的变化数据结果集。

根据情况，将结果集的数据更新到本地缓存表中，包括插入、更新、删除（结果集中返回群组、群成员 isDeleted == true 或者黑名单 status == 0 或者好友关系 status == 30）

最后，将本地的版本号 `versoin` 更新为刚刚接口返回的最新版本号 `versoin` 即可。

2、操作同步：

群成员变化时，会收到通知消息 `GroupNotificationMessage`，通知消息中也包含时间戳（版本号）`timestamp`，可以根据通知消息中的信息，更新到本地缓存数据库中。

当进行各种操作时，请注意更新本地缓存中的数据，并更新本地各个字段的时间戳（版本号），但不要更新本地的 `version`。

### 本地缓存读取策略

采用客户端数据同步策略后，所有的用户信息、好友关系、黑名单列表、群组信息、群组成员信息，都可以直接从本地缓存中读取。

## 好友关系说明

在数据库 `friendships` 表 `status` 字段中包括如下值：

* FRIENDSHIP_REQUESTING = 10
* FRIENDSHIP_REQUESTED  = 11
* FRIENDSHIP_AGREED     = 20
* FRIENDSHIP_IGNORED    = 21
* FRIENDSHIP_DELETED    = 30

所有可能的状态组合如下：

| 对自己的状态 | 自己 | 好友 | 对好友的状态 |
|------------|:---:|:----:|------------|
| 发出了好友邀请 | 10 | 11 | 收到了好友邀请 |
| 发出了好友邀请 | 10 | 21 | 忽略了好友邀请 |
| 已是好友      | 20 | 20 | 已是好友      |
| 已是好友      | 20 | 30 | 删除了好友关系 |
| 删除了好友关系 | 30 | 30 | 删除了好友关系 |

## API 列表

| 接口地址 | 说明 |
|---------|-----|
| [/user/send_code](#/user/send_code) | 发送验证码 |
| [/user/verify_code](#/user/verify_code) | 验证验证码 |

## API 说明

请注意文档中`返回码`和 HTTP Status Code 之间的区别，`返回码`是 HTTP Status Code 为 `200` 时，返回的 JSON 结果集中 `code` 的值，`code` 值正常返回时，也是 `200` 请注意区分，避免混淆。

### POST /user/send_code

向手机发送验证码。

#### 请求参数

```
{
  "region": 86
  "phone": 13912345678
}
```

* region: 国际电话区号
* phone: 手机号

#### 返回结果

正常返回，返回的 HTTP Status Code 为 200，返回的内容如下：

```
{
  "code": 200
}
```

返回码说明：

* 200: 发送成功
* 5000: 发送失败，超过频率限制

异常返回，返回的 HTTP Status Code 如下：

* 400: 错误的请求
* 500: 应用服务器内部错误

### POST /user/verify_code

验证验证码。

#### 请求参数

```
{
  "region": 86
  "phone": 13912345678
  "code": '1234'
}
```

* region: 国际电话区号
* phone: 手机号
* code: 验证码，由 /user/send_code 方法发送到手机上

#### 返回结果

正常返回，返回的 HTTP Status Code 为 200，返回的内容如下：

```
{
  "code": 200
  "result": {
    "verification_token": "75dd0f90-9b0d-11e5-803f-59b82644bc50"
  }
}
```

返回码说明：

* 200: 验证成功
* 1000: 验证码错误
* 2000: 验证码过期

异常返回，返回的 HTTP Status Code 如下：

* 400: 错误的请求
* 500: 应用服务器内部错误

### POST /user/check_phone_available

检查手机号是否可以注册。

#### 请求参数

```
{
  "region": 86
  "phone": 13912345678
}
```

* region: 国际电话区号
* phone: 手机号

#### 返回结果

正常返回，返回的 HTTP Status Code 为 200，返回的内容如下：

```
{
  "code": 200
  "result": true
}
```

返回码说明：

* 200: 请求成功

返回结果说明：

* true: 手机号可用
* false: 手机号不可用

异常返回，返回的 HTTP Status Code 如下：

* 400: 错误的请求
* 500: 应用服务器内部错误

### POST /user/register

注册用户。

#### 请求参数

```
{
  "nickname": "Tom"
  "password": "P@ssw0rd"
  "verification_token": "75dd0f90-9b0d-11e5-803f-59b82644bc50"
}
```

* nickname: 昵称，1 到 32 个字节
* password: 密码，6 到 20 个字节，不能包含空格
* verification_token: 调用 /user/verify_code 成功后返回的 verification_token

#### 返回结果

正常返回，返回的 HTTP Status Code 为 200，返回的内容如下：

```
{
  "code": 200
  "result": {
    "id": "5Vg2Xh9f"
  }
}
```

返回码说明：

* 200: 请求成功

返回结果说明：

* id: 注册的用户 Id

异常返回，返回的 HTTP Status Code 如下：

* 400: 错误的请求
* 404: verification_token 不存在
* 500: 应用服务器内部错误

### POST /user/login

用户登录。登录成功后，会设置 Cookie，后续接口调用需要登录的权限都依赖于 Cookie。

#### 请求参数

```
{
  "region": 86
  "phone": 13912345678
  "password": "P@ssw0rd"
}
```

* region: 国际电话区号
* phone: 手机号
* password: 密码，6 到 20 个字节，不能包含空格

#### 返回结果

正常返回，返回的 HTTP Status Code 为 200，返回的内容如下：

```
{
  "code": 200
  "result": {
    "id": "5Vg2Xh9f"
    "token": "C4nEgo1TK0Ly6zUr/+Hqqu/XQOlLIWwcquFNlNhLydOQwZlSzscUQQfhEU6nFWJ+yPKQhMU6qP5XXBgOWA1AhckFbQ/t+nm4"
  }
}
```

返回码说明：

* 200: 请求成功
* 1000: 错误的手机号或者密码

返回结果说明：

* id: 登录的用户 Id

异常返回，返回的 HTTP Status Code 如下：

* 400: 错误的请求
* 500: 应用服务器内部错误

### POST /user/logout

用户注销。

#### 请求参数

无

#### 返回结果

正常返回，返回的 HTTP Status Code 为 200，返回的内容如下：

```
{
  "code": 200
}
```

返回码说明：

* 200: 请求成功

### POST /user/reset_password

通过手机验证码设置新密码。

#### 请求参数

```
{
  "password": "P@ssw0rd"
  "verification_token": "75dd0f90-9b0d-11e5-803f-59b82644bc50"
}
```

* password: 密码，6 到 20 个字节，不能包含空格
* verification_token: 调用 /user/verify_code 成功后返回的 verification_token

#### 返回结果

正常返回，返回的 HTTP Status Code 为 200，返回的内容如下：

```
{
  "code": 200
}
```

返回码说明：

* 200: 请求成功

异常返回，返回的 HTTP Status Code 如下：

* 400: 错误的请求
* 404: token 不存在
* 500: 应用服务器内部错误

### POST /user/change_password

当前登录用户通过旧密码设置新密码。

#### 前置条件

需要登录才能访问

#### 请求参数

```
{
  "oldPassword": "P@ssw0rdOld"
  "newPassword": "P@ssw0rdNew"
}
```

* oldPassword: 旧密码，6 到 20 个字节，不能包含空格
* newPassword: 新密码，6 到 20 个字节，不能包含空格

#### 返回结果

正常返回，返回的 HTTP Status Code 为 200，返回的内容如下：

```
{
  "code": 200
}
```

返回码说明：

* 200: 请求成功

异常返回，返回的 HTTP Status Code 如下：

* 400: 错误的请求
* 404: token 不存在
* 500: 应用服务器内部错误

## 主要引用项目

Express [http://expressjs.com](http://expressjs.com)

Sequelize [http://sequelizejs.com](http://sequelizejs.com)

SuperTest [https://github.com/visionmedia/supertest](https://github.com/visionmedia/supertest)

Jasmine [http://jasmine.github.io](http://jasmine.github.io)

RongCloud SDK in Node.js [https://github.com/rongcloud/server-sdk-nodejs](https://github.com/rongcloud/server-sdk-nodejs)
