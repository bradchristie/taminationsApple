/*

Taminations Square Dance Animations App for iOS
Copyright (C) 2016 Brad Christie

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var mywindow:UIWindow?

  func processURL(url:NSURL)->[String:String] {
    var intent:[String:String] = [:]
    if let parts = url.pathComponents {
      if (parts.count > 2) {
        intent["level"] = parts[2]
        if (parts.count > 3) {
          intent["link"] = parts[2] + "/" + (url.URLByDeletingPathExtension?.pathComponents![3])!
          intent["call"] = url.query
        }
      }
    }
    return intent
  }
  
  func performStartup(intent:[String:String]) {
    let mybounds = UIScreen.mainScreen().bounds
    mywindow = UIWindow.init(frame: mybounds)
    let istablet = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
    let islandscape = mybounds.width > mybounds .height
    let myroot = istablet && islandscape ? FirstLandscapeViewController(intent) : LevelViewController(intent)
    let nav = UINavigationController.init(rootViewController: myroot)
    nav.customNavBar()
    mywindow?.rootViewController = nav
    mywindow?.addSubview(myroot.view)
    mywindow?.makeKeyAndVisible()
  }
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    TamUtils.readinitfiles()
    let url = launchOptions?[UIApplicationLaunchOptionsURLKey]
    let intent = url==nil ? [:] : processURL(url as! NSURL)
    performStartup(intent)
    return false   // so method below is not called
  }

  //  This method is called when a browser sends a custom link to Taminations
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    //  Since we don't know the current navigation state, just replace it
    performStartup(processURL(url))
    return true;     // we handled the URL
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

