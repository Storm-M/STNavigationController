# STNavigationController
版本更新记录：

截图方案->非截图方案

生命周期与系统一致，不会产生任何问题。可以解决navigationbar隐藏展示切换的UI问题。

demo效果：

<h1>系统默认效果
</h1>
<div>
  <image src="https://github.com/Storm-M/STNavigationController/blob/main/STNavigationController/Example/video/before.jpg" controls="controls" width="300" height="550" />
    <image src="https://github.com/Storm-M/STNavigationController/blob/main/STNavigationController/Example/video/before_1.jpg" controls="controls" width="300" height="550" />
</div>
<h1>使用后效果
</h1>
<div>
  <image src="https://github.com/Storm-M/STNavigationController/blob/main/STNavigationController/Example/video/after.pic.jpg" controls="controls" width="300" height="550" />
    <image src="https://github.com/Storm-M/STNavigationController/blob/main/STNavigationController/Example/video/after_1.jpg" controls="controls" width="300" height="550" />
</div>

<h2>可以看出，返回页面的navigationbar显示效果明显更好</h2>
      
使用方式：

window = UIWindow.init()

let vc = ViewController()

let nav = STUINavigationController.init(rootViewController: vc)
