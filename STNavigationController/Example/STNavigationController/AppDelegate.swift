//
//  AppDelegate.swift
//  STNavigationController
//
//  Created by storm.miao on 04/20/2023.
//  Copyright (c) 2023 storm.miao. All rights reserved.
//

import UIKit
import STNavigationController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var tabbar: UITabBarController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow.init()
        let vc = ViewController()
        let nav = STUINavigationController.init(rootViewController: vc)
        
        let tabar = UITabBarController()
        let tabbarItem = UITabBarItem.init(title: "tabitem_1", image: nil, tag: 0)

        nav.tabBarItem = tabbarItem
        
        
        let tabbarItem2 = UITabBarItem.init(title: "tabitem_22", image: nil, tag: 0)
        let vc2 = ViewController3()
        let nav2 = STUINavigationController.init(rootViewController: vc2)
        

        nav2.tabBarItem = tabbarItem2
        
        tabar.viewControllers = [nav, nav2]
        self.tabbar = tabar
        window?.rootViewController = tabar
        window?.makeKeyAndVisible()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showTabbarNotify(_: )), name: .init("ShowTabbarNotify"), object: nil)
       
        NotificationCenter.default.addObserver(self, selector: #selector(stopTabbarNotify(_: )), name: .stopTabbarAnimtion, object: nil)
        
        
        return true
    }
    
    @objc func stopTabbarNotify(_ notification: Notification) {
        self.tabbar.tabBar.layer.removeAllAnimations()
    }
    
    
    @objc func showTabbarNotify(_ notification: Notification) {
//        UINavigationController *nav = [[notification userInfo] objectForKey:@"filterNav"];
//        if (nav && ![self.viewControllers containsObject:nav]) { //如果带着filternav，需要判断是否在tab上。不在的话就不处理
//            return;
//        }
        if let isShow = notification.userInfo?["isShow"] as? NSNumber {
            let ishidden = !isShow.boolValue
            if (ishidden) {
                let tabbar = self.tabbar
                let tabbar2 = tabbar?.tabBar
                print(tabbar2)
                
//                self.tabbar.tabBar.frame.origin = CGPointMake( -self.tabbar.tabBar.frame.size.width, self.tabbar.tabBar.frame.origin.y)
            }
        }
    
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

