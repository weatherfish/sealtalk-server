# 配置安装与开发调试

## 环境配置

### 安装 Node.js 环境

请前往 Node.js 官网 [https://nodejs.org](https://nodejs.org) 下载安装，支持的最低 Node.js 版本为 4.0。

### MySQL 安装

请自行安装 MySQL，过程略...

### 安装全局 Node.js 包

请执行：

```
npm install -g grunt-cli coffee-script
```

项目支持的最低 CoffeeScript 版本为 1.9.2。

### 安装项目依赖的 Node.js 包

在项目根目录下执行：

```
npm install
```

## 项目配置

### 基础配置

请修改 conf.coffee 文件中的相关配置，不可跳过。每一个配置项在 conf.coffee 中均有说明。

> 如果您熟悉项目中使用的 Sequelize 数据库框架，也可以自行安装配置其他类型的数据库。但需要修改 db.coffee 中相应的 SQL 语句。

### 业务数据配置

client_version.json : 配置 SealTalk 移动端的最新 App 版本号、下载地址等信息，以供调用。

squirrel.json : 配置 SealTalk Desktop 端的最新 App 版本号、下载地址等信息，以供调用。

demo_square.json : 配置 SealTalk 移动端“发现”频道中的默认聊天室和群组数据。

> 新版的移动端中，已经去掉了“发现”频道中的默认群组功能。之所以保留是为了兼容已经发布的老版本移动端 App。

### MySQL 环境配置

请创建一个新的数据库，修改 conf.coffee 文件中的相关配置对应新创建的数据库。

## 启动开发环境

### 编译源码

在项目根目录下执行：

```
grunt build
```

build 任务会自动监视相关文件变化并自动重新编译。请不要关闭这个进程。

### 初始化数据库

第一次运行前需要初始化数据库结构，在项目根目录下执行：

```
npm run initdb
```

### 启动接口服务器

启动接口服务器可以提供一个在开发环境下的接口服务给需要调用的客户端。在项目根目录下执行：

```
NODE_ENV=development grunt nodemon
```

nodemon 任务会自动监视相关文件变化并自动重新启动服务器。

### 启动单元测试和代码覆盖率统计

运行前需要先终止 `grunt nodemon`。

在项目根目录下执行：

```
npm test
```

如果需要，可以开启 Log 输出：

```
DEBUG=app:* npm test
```
或者
```
DEBUG=app:path,app:result npm test
```

可用的 Log 项目包括：

* app:path
* app:log
* app:error
* app:result

## 生产环境安装配置

### 编译部署文件

环境配置等步骤同开发环境配置，到`编译源码`步骤，替换为在项目根目录下执行：

```
grunt release
```

然后将 `dist` 目录拷贝到部署路径即可。

### 修改配置文件

基础配置文件是 `dist` 下的 `conf.js` 文件，请根据需要配置。

业务数据配置文件同上述开发环境说明。

### 修改环境变量

生产环境下请设置 `NODE_ENV=production`。

### 启动服务

请在部署路径中用 `PM2` 等工具启动 `index.js` 文件。或直接使用 `node index.js` 启动（不推荐）。
