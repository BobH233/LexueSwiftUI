import cv2

# 用于存储标记的点的列表
marked_points = []

# 鼠标事件的回调函数
def mouse_callback(event, x, y, flags, param):
    if event == cv2.EVENT_LBUTTONDOWN:
        marked_points.append((x, y))
        print("Marked point at:", (x, y))

# 读取图像
image = cv2.imread('map.jpeg')

# 创建一个窗口并将鼠标回调函数绑定到窗口
cv2.namedWindow('Image')
cv2.setMouseCallback('Image', mouse_callback)

# 在窗口中显示图像，并等待按键事件
while True:
    cv2.imshow('Image', image)
    key = cv2.waitKey(1)
    
    # 按下 'q' 键退出循环
    if key == ord('q'):
        break

# 销毁窗口
cv2.destroyAllWindows()

# 输出标记的点的坐标
print("Marked Points:", marked_points)
