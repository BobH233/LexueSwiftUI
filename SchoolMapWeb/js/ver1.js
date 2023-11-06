function createLocationIndicatorLayer() {
  // 创建一个指示当前位置的指示器
  var canvas = document.createElement("canvas");
  document.mapInstance.locationCanvas = canvas;
  document.mapInstance.locationCanvasContext = canvas.getContext("2d");
  canvas.width = canvas.height = 1000;
  var CanvasLayer = new AMap.CanvasLayer({
    canvas: canvas,
    bounds: new AMap.Bounds(
      [116.16932464695257, 39.726016233346705],
      [116.17032464695257, 39.727016233346705]
    ),
    zIndex: 7,
    zooms: [15, 20],
  });
  document.mapInstance.canvasLayer = CanvasLayer;
  document.mapInstance.map.addLayer(CanvasLayer);
  drawLocationIndicatorFrame()
}

// 绘制用户位置标识的每一帧
function drawLocationIndicatorFrame() {
  var canvas = document.mapInstance.locationCanvas;
  var context = document.mapInstance.locationCanvasContext;
  context.clearRect(0, 0, canvas.width, canvas.height);
  if (typeof document.mapInstance.gps == "undefined") {
    // 此时app还没有初始化好我们需要绘制的数据，不用绘制
    AMap.Util.requestAnimFrame(drawLocationIndicatorFrame);
    return;
  }
  if (!document.mapInstance.gps.enableDisplayPosition) {
    // 如果没有允许显示当前的位置，不绘制
    AMap.Util.requestAnimFrame(drawLocationIndicatorFrame);
    return;
  }
  if (typeof document.mapInstance.gps.bound != 'undefined') {
    document.mapInstance.canvasLayer.setBounds(document.mapInstance.gps.bound);
  }
  // 获取用户的指南针朝向
  var gpsDirection = document.mapInstance.gps.direction;
  var centerX = canvas.width / 2;
  var centerY = canvas.height / 2;

  // 画底部圆形
  context.beginPath();
  context.moveTo(centerX, centerY);
  context.arc(centerX, centerY, 170, 0, 2 * Math.PI);
  context.fillStyle = "rgba(0,100,255, 0.2)";
  context.fill();
  context.closePath();

  // 描边圆形
  context.beginPath();
  context.lineWidth = 5;
  context.arc(centerX, centerY, 170, 0, 2 * Math.PI);
  context.strokeStyle = "rgba(255,255,255, 0.7)";
  context.stroke();
  context.closePath();

  // 定义扇形的参数
  var radius = 300;
  var startAngle = 0;
  var endAngle = Math.PI / 4; // 扇形的终止角度
  var rotationAngle = (gpsDirection - 22.5 - 90 + 360) % 360; // 要旋转的角度
  // 创建渐变
  var gradient = context.createRadialGradient(centerX, centerY, 0, centerX, centerY, radius);
  gradient.addColorStop(0, "rgba(0,100,255,0)"); // 内部颜色，透明
  gradient.addColorStop(0.5, "rgba(0,100,255, 0.5)"); // 内部颜色，蓝色
  gradient.addColorStop(1, "rgba(0,100,255,0)"); // 外部颜色，透明
  // 将角度转换为弧度
  var startAngleInRadians = startAngle;
  var endAngleInRadians = endAngle;
  var rotationAngleInRadians = (rotationAngle * Math.PI) / 180;
  // 开始路径
  context.beginPath();
  // 旋转画布
  context.translate(centerX, centerY);
  context.rotate(rotationAngleInRadians);
  context.translate(-centerX, -centerY);
  // 绘制扇形
  context.arc(centerX, centerY, radius, startAngleInRadians, endAngleInRadians);
  // 闭合路径并填充
  context.lineTo(centerX, centerY);
  context.closePath();
  context.fillStyle = gradient;
  context.fill();
  // 恢复画布旋转前的状态
  context.setTransform(1, 0, 0, 1, 0, 0);
  // 结束路径
  context.closePath();

  // 刷新画布
  if(typeof document.mapInstance.canvasLayer == 'object') {
    document.mapInstance.canvasLayer.reFresh();
  }
  AMap.Util.requestAnimFrame(drawLocationIndicatorFrame);
}

function init() {
  if(typeof document.mapInstance == 'undefined') {
    document.mapInstance = {};
  }
  // 禁止选中
  document.addEventListener("selectstart", function (e) {
    e.preventDefault();
  });
  // 初始化高德api
  var map = new AMap.Map("container", {
    viewMode: "3D",
    pitch: 20,
    zoom: 20,
    terrain: true,
    center: [116.16932464695257, 39.726016233346705],
  });
  document.mapInstance.map = map; // 导出给全局
  // 覆盖校园地图
  var imageLayer = new AMap.ImageLayer({
    url: "https://cdn.bit-helper.cn/map.jpeg",
    bounds: new AMap.Bounds(
      [116.16524858, 39.7237884],
      [116.1813301, 39.7405679]
    ),
    opacity: 0.9,
    zooms: [15, 20],
    zIndex: 6,
  });
  map.addLayer(imageLayer);
  document.mapInstance.imageLayer = imageLayer;
  // 懒加载工具控件
  AMap.plugin("AMap.ToolBar", function () {
    // 异步加载插件
    var toolBar = new AMap.ToolBar({
      visible: false,
      position: {
        top: "110px",
        right: "40px",
      },
    });
    document.mapInstance.toolBar = toolBar;
    map.addControl(toolBar);
    toolBar.show();
  });
  // 懒加载控制组件
  AMap.plugin("AMap.ControlBar", function () {
    // 异步加载插件
    var controlBar = new AMap.ControlBar({
      visible: false,
      position: {
        top: "10px",
        right: "10px",
      },
    });
    document.mapInstance.controlBar = controlBar;
    map.addControl(controlBar);
    controlBar.show();
  });
  createLocationIndicatorLayer()
}

init();
