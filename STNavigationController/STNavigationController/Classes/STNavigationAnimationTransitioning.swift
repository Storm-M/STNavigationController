//
//  STNavigationAnimationTransitioning.swift
//
//
//  Created by Storm.Miao on 2023/4/20.
//

import Foundation

let ScreenWidth = UIScreen.main.bounds.size.width
let ScreenHeight = UIScreen.main.bounds.size.height

class STNavigationAnimationTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
//    var screenShotImgs : [UIViewController : UIImage?] = [ : ]
    //所属的导航栏有没有TabBarController
    var isTabbarExist = false
    var navigationOperation : UINavigationController.Operation!
    weak var navigationController : UINavigationController? {
        didSet{
            let rootVC = navigationController!.view.window?.rootViewController
            //判断该导航栏是否有TabBarController
            if navigationController!.tabBarController == rootVC {
                isTabbarExist = true
            }else {
                isTabbarExist = false
            }
        }
    }
    
    class func animationController(operation : UINavigationController.Operation) -> STNavigationAnimationTransitioning {
        let st = STNavigationAnimationTransitioning()
        st.navigationOperation = operation;
        return st
    }
    
    class func animationController(operation : UINavigationController.Operation, navigationController : UINavigationController) -> STNavigationAnimationTransitioning {
        let ac = STNavigationAnimationTransitioning()
        ac.navigationController = navigationController
        ac.navigationOperation = operation
        return ac
    }
    
    //MARK:UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        //取出fromViewController,fromView和toViewController，toView
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to),
              let toView = transitionContext.view(forKey: .to) else {
            return
        }
        
        var fromViewEndFrame = transitionContext.finalFrame(for: fromVC)
        fromViewEndFrame.origin.x = ScreenWidth
        var fromViewStartFrame = fromViewEndFrame
        let toViewEndFrame = transitionContext.finalFrame(for: toVC)
        let toViewStartFrame = toViewEndFrame
        
        let containerView = transitionContext.containerView
        
        
        let screenImgView = UIImageView(frame: CGRect(x: 0, y: 0, width: toViewEndFrame.size.width, height: toViewEndFrame.size.height))
        let screenImg = self.screenShot(toViewEndFrame)
        screenImgView.image = screenImg
        
        if navigationOperation == .push {
            if let currentImage = screenImg {
                if currentImage.size.height > screenImgView.frame.size.height {
                    screenImgView.frame.size = CGSizeMake(screenImgView.frame.size.width, currentImage.size.height)
                }
            }
            fromVC.mp_screenshotImage = screenImg
//            screenShotImgs[fromVC] = screenImg
            self.navigationController?.view.superview?.insertSubview(screenImgView, belowSubview: (self.navigationController?.view)!)
            
            containerView.addSubview(toView)
            toView.frame = toViewStartFrame
            screenImgView.frame.origin = CGPoint(x: 0, y: 0)
            
            navigationController?.view.transform = CGAffineTransform(translationX: toViewEndFrame.size.width, y: 0)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                self.navigationController?.view.transform = CGAffineTransform(translationX: 0, y: 0)
                screenImgView.frame.origin = CGPoint(x: -ScreenWidth, y: 0)
            }, completion: { (finished) in
                screenImgView.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        }
        
        if navigationOperation == .pop {
            if let currentImage = screenImg {
                if currentImage.size.height > screenImgView.frame.size.height {
                    screenImgView.frame.size = CGSizeMake(screenImgView.frame.size.width, currentImage.size.height)
                }
            }
            
            fromVC.view.removeFromSuperview()
            
            fromViewStartFrame.origin.x = 0
            containerView.addSubview(toView)
            toView.frame = toViewStartFrame
            
    
            self.navigationController?.view.transform = CGAffineTransform(translationX: -ScreenWidth, y: 0)
            self.navigationController?.view.superview?.insertSubview(screenImgView, aboveSubview: (self.navigationController?.view)!)
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                screenImgView.frame.origin  = CGPoint(x: toViewEndFrame.size.width, y: 0)
                self.navigationController?.view.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: { (finished) in
                screenImgView.removeFromSuperview()
//                self.screenShotImgs.removeValue(forKey: fromVC)
                transitionContext.completeTransition(true)
                NotificationCenter.default.post(name: .init("_STStopTabbarAnimationNotify"), object: nil, userInfo: nil)
            })
        }
    }
    
    func removeAllScreenShot() {// 移除全部屏幕截图
//        screenShotImgs.removeAll()
    }
    
    
    func screenShot(_ toViewEndFrame: CGRect) -> UIImage? {
        //将要被截图的view，即窗口的根控制器的view
        let rootVC = self.navigationController?.view.window?.rootViewController;
        //背景图片 总的大小
        var _size = rootVC?.view.frame.size
        if !isTabbarExist {
            _size = navigationController?.view.frame.size
        }
        
        
        guard let size = _size else {
            return nil
        }
        //开启上下文，使用参数之后，截出来的是原图（YES  0.0 质量高）
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        //要裁剪的矩形范围
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        ////注：iOS7以后renderInContext：由drawViewHierarchyInRect：afterScreenUpdates：替代
        if isTabbarExist {
            rootVC?.view.drawHierarchy(in: rect, afterScreenUpdates: false)
        }else {
            navigationController?.view.drawHierarchy(in: rect, afterScreenUpdates: false)
        }
        //从上下文中，取出UIImage
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        //千万记得，结束上下文（移除栈顶的基于当前位图的图形上下文）
        UIGraphicsEndImageContext()
        return snapshot;
    }
    
}


public extension NSNotification.Name {
    static let stopTabbarAnimtion = Notification.Name("StopTabbarAnimationNotify")
    static let setTabbarPositionX = Notification.Name("TabbarPositionXNotify")
}
