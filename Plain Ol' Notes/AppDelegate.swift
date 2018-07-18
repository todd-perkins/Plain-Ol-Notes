//
//  AppDelegate.swift
//  Plain Ol' Notes
//
//  Created by Todd Perkins on 6/27/18.
//  Copyright © 2018 Todd Perkins. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CAAnimationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldToolbarUsesTextFieldTintColor = true
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        
        let layout = UICollectionViewFlowLayout()
        let mainView = NoteCollectionController(collectionViewLayout: layout)
        let navigationController = UINavigationController(rootViewController: mainView)
        
        mainView.title = "Notes"
        navigationController.navigationBar.prefersLargeTitles = true
        
        window?.rootViewController = navigationController
        window?.backgroundColor = .white
        
        animateIntro(navigationController)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func animateIntro(_ navigationController: UIViewController) {
        // logo mask
        let mask = CALayer()
        mask.contents = #imageLiteral(resourceName: "icon_mask").cgImage
        mask.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        mask.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let topPadding = navigationController.view.safeAreaInsets.top
        let bottomPadding = navigationController.view.safeAreaInsets.bottom
        mask.position = CGPoint(x: navigationController.view.frame.width / 2, y: (navigationController.view.frame.height -  topPadding - bottomPadding) / 2 + topPadding)
        navigationController.view.layer.mask = mask
        
        // fades image to masked area to make the transition less jarring (not necessary if your mask/startup image is a solid color)
        let fadingImage = UIImageView(image: #imageLiteral(resourceName: "iconInverted"))
        fadingImage.frame = mask.frame
        window?.addSubview(fadingImage)
        
        // the background view that shows when main view is masked
        let maskBgColor = UIView(frame: navigationController.view.frame)
        maskBgColor.backgroundColor = .noteBlue
        window!.addSubview(maskBgColor)
        window?.sendSubview(toBack: maskBgColor)
        
        // white background fades to app background
        let maskBgView = UIView(frame: navigationController.view.frame)
        maskBgView.backgroundColor = .white
        navigationController.view.addSubview(maskBgView)
        navigationController.view.bringSubview(toFront: maskBgView)
        
        // logo mask animation
        let transformAnimation = CAKeyframeAnimation(keyPath: "bounds")
        transformAnimation.delegate = self
        transformAnimation.duration = 1
        transformAnimation.beginTime = CACurrentMediaTime() + 1 //add delay of 1 second
        let initalBounds = NSValue(cgRect: mask.bounds)
        let secondBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 80, height: 80))
        let finalBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        transformAnimation.values = [initalBounds, secondBounds, finalBounds]
        transformAnimation.keyTimes = [0, 0.5, 1]
        transformAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
        transformAnimation.isRemovedOnCompletion = false
        transformAnimation.fillMode = kCAFillModeForwards
        mask.add(transformAnimation, forKey: "maskAnimation")
        
        // logo mask background view animation
        UIView.animate(withDuration: 0.35, delay: 0.65, options: .curveEaseInOut, animations: {
            fadingImage.alpha = 0.0
        }, completion: { finished in
            fadingImage.removeFromSuperview()
        })
        
        // logo mask background view animation
        UIView.animate(withDuration: 0.3,delay: 1.35,options: .curveEaseOut,animations: {
            maskBgView.alpha = 0.0
        }, completion: { finished in
            maskBgView.removeFromSuperview()
        })
        
        // logo mask background view animation
        UIView.animate(withDuration: 0.15,delay: 1.5,options: .curveEaseOut,animations: {
            maskBgColor.alpha = 0
        }, completion: { finished in
            maskBgColor.removeFromSuperview()
        })
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        window?.rootViewController?.view.layer.mask = nil
    }

}

