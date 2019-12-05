cordova-plugin-Scanner是供vue开发以及h5混合开发app，使用ios原生二维码扫一扫功能的cordova 插件。
安装说明：cordova plugin add https://github.com/wkwl/cordova-plugin-Scanner.git

使用方式如下：
'''
<html>
<head>
<meta name="viewport" content="initial-scale=1, width=device-width, viewport-fit=cover">
<link rel="stylesheet" type="text/css" href="css/index.css">
<title>TestPlugin</title>
<meta http-equiv="Content-type" content="text/html; charset=utf-8">
<script type="text/javascript" charset="utf-8" src="cordova.js"></script>
<script type="text/javascript" charset="utf-8">

function gameSdkPlugin() {
Scanner.coolMethod(success,error);
}
function success(msg){
alert(msg);
}
function error(msg){
alert(msg);
}

</script>
</head>

<body style="padding-top:50px">
<button style="font-size:17px;" onclick="gameSdkPlugin()">调用插件</button> <br>
</body>
</html>
</code>
'''
