//
//  STInteractiveNavigationAnimationTransitioning.swift
//
//
//  Created by Storm.Miao on 2023/4/20.
//

import Foundation



class STInteractiveNavigationAnimationTransitioning: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    public var isSendTabBarNotify: Bool = false
    weak var navigationController : UINavigationController? = nil
    var navigationOriginY: CGFloat = 0
    var navigationSnapShot: UIView? = nil
    var rightLeaveView: UIView!
    weak var toView: UIView!
    weak var containerView: UIView!
    
    func findRootView(_ view: UIView?) -> UIView? {
        var findView: UIView? = view;
        while findView?.superview != nil {
            findView = findView?.superview
        }
        
        return findView
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        currentTransitionContext = transitionContext
        //取出fromViewController,fromView和toViewController，toView
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to),
              let toView1 = transitionContext.view(forKey: .to) else {
            return
        }
        
        toView = toView1
        
        var fromViewEndFrame = transitionContext.finalFrame(for: fromVC)
        fromViewEndFrame.origin.x = ScreenWidth
        
        let toViewEndFrame = transitionContext.finalFrame(for: toVC)
        let toViewStartFrame = toViewEndFrame
        let containerView = transitionContext.containerView
        self.containerView = containerView

        //这句非常重要，没有这句，就无法正常push和Pop出对应的界面
        containerView.addSubview(toView)
        
        self.navigationController?.view.transform = CGAffineTransform(translationX: -toView.frame.size.width/2, y: 0)
        if self.isSendTabBarNotify {
            NotificationCenter.default.post(name: .setTabbarPositionX, object: nil, userInfo: ["x" : -toView.frame.size.width/2])
        }
       

        rightLeaveView = UIView.init(frame: fromVC.view.frame)
        findRootView(self.navigationController?.view)?.addSubview(rightLeaveView) //insertSubview(rightLeaveView, aboveSubview: (self.navigationController?.view)!)
        rightLeaveView.addSubview(fromVC.view)
        if let snapShot = self.navigationSnapShot {
            var screenShotFrame = fromVC.view.frame
            if screenShotFrame.origin.y > 0 {
                screenShotFrame.size.height = screenShotFrame.size.height + screenShotFrame.origin.y
                screenShotFrame.origin.y = 0
                rightLeaveView.frame = screenShotFrame
                
                if let image = partScreenShot(screenShotFrame, cropRect: CGRect(x: 0, y: 0, width: screenShotFrame.size.width, height: fromVC.view.frame.origin.y)) {
                    let imageView = UIImageView.init(image: image)
                    rightLeaveView.addSubview(imageView)
                }
                if fromVC.view.frame.height >= ScreenHeight {
                    fromVC.view.frame.size = CGSize(width: fromVC.view.frame.size.width, height: fromVC.view.frame.height - fromVC.view.frame.origin.y)
                }
            }
            
            snapShot.frame.origin.y = self.navigationOriginY
            rightLeaveView.addSubview(snapShot)
        }
        
        
        toView.frame = toViewEndFrame
        
        navigationController?.view.transform = CGAffineTransform(translationX: -toViewEndFrame.size.width, y: 0)
        
    }
    
    override func update(_ percentComplete: CGFloat) {
        super.update(percentComplete)
        let width = toView?.frame.size.width ?? 0
        if let leaveView = rightLeaveView {
            leaveView.frame.origin = CGPoint(x: width * percentComplete , y: leaveView.frame.origin.y)
        }
        
//        toView?.frame.origin = CGPoint(x:  (-1 + percentComplete) * toView.frame.size.width, y: 0)
        let x = -width / 2 + width * percentComplete / 2
        self.navigationController?.view.transform = CGAffineTransform(translationX: x, y: 0)
        if self.isSendTabBarNotify {
            NotificationCenter.default.post(name: .setTabbarPositionX, object: nil, userInfo: ["x" : x])
        }
     ////                screenImgView.frame = CGRect(x:  0, y: 0, width: toViewEndFrame.size.width, height: toViewEndFrame.size.height)
    }
    
    func partScreenShot(_ toViewEndFrame: CGRect, cropRect: CGRect) -> UIImage? {
        //将要被截图的view，即窗口的根控制器的view

        let size = toViewEndFrame.size
        //开启上下文，使用参数之后，截出来的是原图（YES  0.0 质量高）
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        //要裁剪的矩形范围
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        ////注：iOS7以后renderInContext：由drawViewHierarchyInRect：afterScreenUpdates：替代
        navigationController?.view.drawHierarchy(in: rect, afterScreenUpdates: false)
        //从上下文中，取出UIImage

        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        var result: UIImage? = nil
        if let partSnapShot = snapshot?.cgImage?.cropping(to: cropRect) {
            result = UIImage.init(cgImage: partSnapShot)
        }

        //千万记得，结束上下文（移除栈顶的基于当前位图的图形上下文）
        UIGraphicsEndImageContext()
        return result;
    }

    
    //MARK:UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0
    }
    
    func clean() {
        if self.isSendTabBarNotify {
            NotificationCenter.default.post(name: .setTabbarPositionX, object: nil, userInfo: ["x" : 0])
        }
        rightLeaveView?.removeFromSuperview()
        rightLeaveView = nil
        containerView?.frame.origin = CGPoint(x: 0.0, y: 0.0)
        self.navigationController?.view.transform = .identity
        self.navigationController?.view.frame.origin = CGPoint(x: 0, y: 0)
        toView = nil
        
    }
    
    public func cancelAnimation() {
        if let current = currentTransitionContext {
            
            if let fromVC = current.viewController(forKey: .from) {
                let containerView = current.containerView
                containerView.addSubview(fromVC.view)
                toView?.removeFromSuperview()
            }
           
            current.cancelInteractiveTransition()
            current.completeTransition(false)
        }
        currentTransitionContext = nil
        clean()
        NotificationCenter.default.post(name: .stopTabbarAnimtion, object: nil, userInfo: nil)
    }
    
    public func finishAnimation() {
        if let current = currentTransitionContext {
            current.finishInteractiveTransition()
            current.completeTransition(true)
        }
        currentTransitionContext = nil
        clean()
        NotificationCenter.default.post(name: .stopTabbarAnimtion, object: nil, userInfo: nil)
    }
    
    var currentTransitionContext:UIViewControllerContextTransitioning? = nil

}


