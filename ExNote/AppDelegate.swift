//
//  AppDelegate.swift
//  ExNote
//
//  Created by 佐藤紬 on 2021/04/15.
//

import UIKit
import NCMB

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window:UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        NCMB.setApplicationKey("ebcac4359ee6de1578e9df0f099b2d6ce7eb0b2451db27b994b84de7b88628fc", clientKey: "c3f3fd06b40f410818c157e773d675b39343fedde9811e7d8d738724a813da4e")
        let ud = UserDefaults.standard
        let isLogin = ud.bool(forKey: "isLogin")
        
        if isLogin == true{
            //ログイン中だったら
            self.window = UIWindow(frame:UIScreen.main.bounds)
            let storyboard = UIStoryboard(name:"Main",bundle:Bundle.main)
            let rootViewController = storyboard.instantiateViewController(identifier: "RootTabBarController")
            self.window?.rootViewController = rootViewController
            self.window?.backgroundColor = UIColor.white
            self.window?.makeKeyAndVisible()
//            UINavigationBar.appearance().barTintColor = UIColor.green
//            UITabBar.appearance().barTintColor = UIColor.green
        }else{
            //ログインしていなかったら
            self.window = UIWindow(frame:UIScreen.main.bounds)
            let storyboard = UIStoryboard(name:"SignIn",bundle:Bundle.main)
            let rootViewController = storyboard.instantiateViewController(identifier: "RootNavigationController")
            self.window?.rootViewController = rootViewController
//            #8CD790
            self.window?.makeKeyAndVisible()
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
}

