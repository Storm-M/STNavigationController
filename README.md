# STNavigationController
版本更新记录：

截图方案->非截图方案

生命周期与系统一致，不会产生任何问题。可以解决navigationbar隐藏展示切换的UI问题。

demo效果：


使用方式：

window = UIWindow.init()

let vc = ViewController()

let nav = STUINavigationController.init(rootViewController: vc)
