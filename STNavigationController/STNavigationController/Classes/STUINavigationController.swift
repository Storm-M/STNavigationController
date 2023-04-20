//
//  STUINavigationController.swift
//
//
//  Created by Storm.Miao on 2023/4/20.
//

import UIKit

let kDefaultAlpha : CGFloat = 0.5 //默认的将要变透明的遮罩的初始透明度（全黑）
let kTargetTranslateScale : CGFloat = 0.75 //当拖动的距离，占了屏幕的总宽度的3/4时，就让imageView完全显示，遮盖完全消失

func colorFromRGB(rgbValue : Int) -> UIColor {
    return UIColor(red: CGFloat(((rgbValue & 0xFF0000) >> 16))/255.0, green: CGFloat(((rgbValue & 0x0FF00) >> 16))/255.0, blue: CGFloat(((rgbValue & 0x0000FF) >> 16))/255.0, alpha: 1.0)
}

open class STUINavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    private var isShowTabbar: Bool = false
    private var isNavBarHidden: Bool? = nil
    
    public var isUseCustomAnimation: Bool = true {
        didSet {
            if isUseCustomAnimation {
                view.addGestureRecognizer(panGestureRec)
            } else {
                view.removeGestureRecognizer(panGestureRec)
            }
        }
    }
    
    var screenshotImageView : UIImageView!
    var rightScreenshotImageView : UIImageView!
    var coverView : UIView!
    var screenshotImgs : [NSObject : UIImage?] = [:]
    var panGestureRec : UIScreenEdgePanGestureRecognizer!
   
    
    var animationController : STNavigationAnimationTransitioning!
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        UIViewController.setupViewWillAppearHook()
        
        delegate = self
        
        animationController = STNavigationAnimationTransitioning()
        
        if self.isUseCustomAnimation {
            //1、创建Pan手势识别器，并绑定监听方法
            panGestureRec = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(pan:)))
            panGestureRec.edges = UIRectEdge.left
            panGestureRec.delegate = self
            //为导航控制器的view添加Pan手势识别器
            view.addGestureRecognizer(panGestureRec)
            
            //2、创建截图的ImageView
            screenshotImageView = UIImageView()
            //app的frame是包括了状态栏高度的frame
            screenshotImageView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
            
            rightScreenshotImageView = UIImageView()
            rightScreenshotImageView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
            
            //3、创建截图上面的黑色半透明遮罩
            coverView = UIView()
            //遮罩的frame就是截图的frame
            coverView.frame = screenshotImageView.frame
            //遮罩为黑色
            coverView.backgroundColor = UIColor.black
        
        }
       
        
    }
    


    //MARK:响应手势的方法
    @objc func panGestureRecognizer(pan : UIScreenEdgePanGestureRecognizer) {
        if self.isUseCustomAnimation == false {
            return
        }

        //判断pan手势的各个阶段
        switch pan.state {
        case .began://开始拖拽阶段
            isShowTabbar = false
            isNavBarHidden = nil
            if self.visibleViewController == self.viewControllers[0] {
                return
            } else if self.visibleViewController == self.viewControllers[1] {
                isShowTabbar = true
            }
            
            if self.viewControllers.count > 1 {
                let willShowVC: UIViewController = self.viewControllers[self.viewControllers.count - 2]
                isNavBarHidden = willShowVC.navigationController?.isNavigationBarHidden ?? false
            }
            
            dragBegin(pan: pan)
//            //隐藏navigationbar 免得在滑动过程中冒出来
//            isNavBarHidden = self.navigationBar.isHidden
            if isNavBarHidden != nil {
                self.navigationBar.isHidden = true
            }
            //如果是二级页面返回的时候，会把tabbar显示出来，此时需要隐藏tabbar
            if isShowTabbar {//tabbar处理通知
                NotificationCenter.default.post(name: .init("_STShowTabbarNotify"), object: nil, userInfo: ["isShow" : false, "filterNav": self])
            }
        case .ended,.cancelled,.failed://结束拖拽阶段
            if currentViewController == nil {
                return
            }
            if screenshotImageView.superview == nil {
                return
            }
            dragEnd(pan: pan)
            if isNavBarHidden != nil {
                self.navigationBar.isHidden = isNavBarHidden!
            }
            
            
        default://正在拖拽阶段
            if currentViewController == nil {
                return
            }
            if screenshotImageView.superview == nil {
                return
            }
            dragging(pan: pan)
            if isNavBarHidden != nil {
                self.navigationBar.isHidden = true
            }
        }
    }
    
    var currentViewController: UIViewController? = nil
    
    
    var startPoint: CGPoint!
    
    //MARK:开始拖拽，添加图片和遮罩
    func dragBegin(pan : UIScreenEdgePanGestureRecognizer) {
        let image = getscreenShot()
        currentViewController = super.popViewController(animated: false)
        if currentViewController == nil {
            return
        }
        startPoint = pan.location(in: self.view.superview)
        
        rightScreenshotImageView.frame.size = image?.size ?? CGSizeZero
        view.superview?.insertSubview(screenshotImageView, at: 0)
        view.superview?.insertSubview(coverView, aboveSubview: screenshotImageView)
        
        rightScreenshotImageView.image = image
        view.addSubview(rightScreenshotImageView)
        
        if let current = self.topViewController {
            let image = screenshotImgs[current] as? UIImage
            screenshotImageView.image = image
            if screenshotImageView.image == nil  {
                let image = getVCScreenShot(current)
                if image != nil {
                    screenshotImageView.image = image
                    screenshotImgs[current] = image
                    screenshotImageView.frame.size = image!.size
                }
                
            }
        }
        screenshotImageView.frame.size = screenshotImageView.image?.size ?? CGSizeZero
    }
    
    //MARK:正在拖动，动画效果的精髓，进行位移和透明度的变化
    func dragging(pan : UIScreenEdgePanGestureRecognizer) {
        if screenshotImageView.image == nil , let current = self.topViewController {
            let image = getVCScreenShot(current)
            if image != nil {
                screenshotImageView.image = image
                screenshotImgs[current] = image
                screenshotImageView.frame.size = image!.size
            }
            
        }
        
        var currentPoint = pan.location(in: view.superview)
        var offsetX = currentPoint.x - startPoint.x
        
        if offsetX < 0 {
            offsetX = 0
        }
        //让整个view都平移
        //挪动整个导航view
        if offsetX >= 0 {
            view.frame.origin = CGPoint(x: offsetX, y: 0)//(translationX: offsetX, y: 0)
        }
        
        //计算目前手指拖动位移占屏幕总的宽高的比例，当这个比例达到3/4时，就让imageview完全显示，遮盖完全消失
        let currentTranslateScaleX = offsetX / self.view.frame.width
        
        if offsetX < ScreenWidth {
            screenshotImageView.transform = CGAffineTransform(translationX: (offsetX - ScreenWidth) * 0.6, y: 0)
        }
        
        // 让遮盖透明度改变,直到减为0,让遮罩完全透明,默认的比例-(当前平衡比例/目标平衡比例)*默认的比例
        let alpha = kDefaultAlpha - (currentTranslateScaleX / kTargetTranslateScale) * kDefaultAlpha
        
        coverView.alpha = alpha
    }
    
    //MARK:结束拖动，判断结束时拖动的距离做响应的处理，并将图片和遮罩从父控件上移除
    func dragEnd(pan : UIScreenEdgePanGestureRecognizer) {
        let currentPoint = pan.location(in: view.superview)
        let translateX = currentPoint.x - startPoint.x
        let width = view.frame.size.width
        
        if translateX <= 80 {// 如果手指移动的距离小于80,往左边挪 (弹回)
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame.origin = CGPoint(x: 0, y: 0)
                self.screenshotImageView.transform = CGAffineTransform(translationX: -ScreenWidth, y: 0)
                //让遮盖的透明度恢复默认的alpha
                self.coverView.alpha = kDefaultAlpha
                if let current = self.currentViewController {
                    super.pushViewController(current, animated: false)
                }
                
            }, completion: { (finished) in
                //重要,动画完成之后,每次都要记得 移除两个view,下次开始拖动时,再添加进来
                self.screenshotImageView.removeFromSuperview()
                self.rightScreenshotImageView.removeFromSuperview()
                self.coverView.removeFromSuperview()
                self.view.frame.origin = CGPoint(x: 0, y: 0)
            })
        } else {// 如果手指移动的距离还超过了屏幕的一半,往右边挪
            UIView.animate(withDuration: 0.3, animations: {
                // 让被右移的view完全挪到屏幕的最右边,结束之后,还要记得清空view的transform
                self.view.frame.origin = CGPoint(x: width, y: 0)
                //让imageView位移还原
                self.screenshotImageView.transform = CGAffineTransform(translationX: 0, y: 0)
                //让遮盖alpha变为0，变得完全透明
                self.coverView.alpha = 0
            }, completion: { (finished) in
                self.view.frame.origin = CGPoint(x: 0, y: 0)
                // 移除两个view,下次开始拖动时,再加回来
                self.screenshotImageView.removeFromSuperview()
                self.rightScreenshotImageView.removeFromSuperview()
                self.coverView.removeFromSuperview()
                if let current = self.currentViewController {
                    self.screenshotImgs.removeValue(forKey: current)
                }
                //在二级页面左滑的时候，tabbar会显示，此时需要手动恢复
                if self.isShowTabbar {
                    NotificationCenter.default.post(name: .init("_STShowTabbarNotify"), object: nil, userInfo: ["isShow" : true, "filterNav": self])
                }
                
                self.view.frame.origin = CGPoint(x: 0, y: 0)
            })
        }
        self.currentViewController = nil
    }
    
    private func setup() {
        
    }
    
    override public init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setup()
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if self.isUseCustomAnimation {
            animationController.navigationOperation = operation
            animationController.navigationController = self
            return animationController
        } else {
            return nil
        }
    }
    //
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    //MARK:实现截图保存功能，并在push前截图
    func getscreenShot() -> UIImage? {
        //将要被截图的view，即窗口的根控制器的view
        let beyondVC = self.view.window?.rootViewController;
        //背景图片 总的大小
        var _size = beyondVC?.view.frame.size
        if tabBarController != beyondVC {
            _size = view.frame.size
        }
        
        guard let size = _size else {
            return nil
        }
        
        //开启上下文，使用参数之后，截出来的是原图（YES  0.0 质量高）
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        //要裁剪的矩形范围
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        ////注：iOS7以后renderInContext：由drawViewHierarchyInRect：afterScreenUpdates：替代
        if tabBarController == beyondVC {
            beyondVC?.view.drawHierarchy(in: rect, afterScreenUpdates: false)
        }else{
            view.drawHierarchy(in: rect, afterScreenUpdates: false)
        }
        
        //从上下文中，取出UIImage
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        
        //千万记得，结束上下文（移除栈顶的基于当前位图的图形上下文）
        UIGraphicsEndImageContext()
        
        return snapshot
    }
    
    
    //MARK:实现截图保存功能，并在push前截图
    func getVCScreenShot(_ vc: UIViewController) -> UIImage? {
        //将要被截图的view，即窗口的根控制器的view
        let size = vc.view.frame.size
        //开启上下文，使用参数之后，截出来的是原图（YES  0.0 质量高）
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        var result = vc.view.drawHierarchy(in: rect, afterScreenUpdates: false)
        if result == false {
            UIGraphicsEndImageContext()
            return nil
        }
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshot
    }
    
    
    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.isUseCustomAnimation {
            if viewControllers.count >= 1 {
                //调用自定义方法，使用上下文截图
                let image = getscreenShot()
                if let vc = self.topViewController {
                    screenshotImgs[vc] = image
                }
            }
        }
        
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    open override func popViewController(animated: Bool) -> UIViewController? {
        if self.isUseCustomAnimation {
            let result = super.popViewController(animated: animated)
            if let current = result {
                screenshotImgs.removeValue(forKey: current)
            }
            return result
        } else {
            return super.popViewController(animated: animated)
        }
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? .all
    }
    
    open func gestureRecognizerShouldBegin(_ gesture: UIGestureRecognizer) -> Bool {
        if viewControllers.count <= 1 {
            return false
        }

        
        if let result = self.interactivePopGestureRecognizer?.isEnabled {
            return result
        }
        
        return true
    }
    
    override public func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if self.isUseCustomAnimation {
            screenshotImgs.removeAll()
        }
       
        if #available(iOS 14, *),
           self.viewControllers.count > 1 {
            self.topViewController?.hidesBottomBarWhenPushed = false
        }
        return super.popToRootViewController(animated: animated)
    }
    
    override public func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        
        if self.isUseCustomAnimation {
            var removeCount = 0
            for  vc in viewControllers {
                if viewController == vc {
                    break
                }
                self.screenshotImgs.removeValue(forKey: vc)
                removeCount += 1
            }
        }
        
        
        if #available(iOS 14, *),
           self.topViewController == viewController,
           self.viewControllers.count > 1 {
            self.topViewController?.hidesBottomBarWhenPushed = false
        }
        return super.popToViewController(viewController, animated: animated)
    }
}


private extension UIViewController {
    
    @discardableResult static func setupViewWillAppearHook() -> Bool {
        exchange(original: #selector(viewWillAppear(_:)), with: #selector(mp_viewWillAppear(_:)))
        return true
    }
    
    
    @objc private func mp_viewWillAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.delegate = navigationController as? UIGestureRecognizerDelegate//
        mp_viewWillAppear(animated)
    }
}

fileprivate extension UIViewController {
    static func exchange(original method: Selector, with newMethod: Selector) {
        guard let originalMethod = class_getInstanceMethod(self, method),
              let swizzledMethod = class_getInstanceMethod(self, newMethod)
        else { return }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
