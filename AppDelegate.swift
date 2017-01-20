/*

Taminations Square Dance Animations App for iOS
Copyright (C) 2017 Brad Christie

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

  private var mywindow:UIWindow?

  //  General method to get web data
  func httpGet(_ request: URLRequest!, callback: @escaping (String, String?) -> Void) {
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: {
      (data, response, error) -> Void in
      if error != nil {
        callback("", error!.localizedDescription)
      } else {
        let result = NSString(data: data!, encoding: String.Encoding.ascii.rawValue)!
        callback(result as String, nil)
      }
    }) 
    task.resume()
  }
  
  func processURL(_ url:URL)->[String:String] {
    var intent:[String:String] = [:]
    let parts = url.pathComponents
    if (parts.count > 2) {
      intent["level"] = LevelData.find(parts[2])?.name
      if (parts.count > 3) {
        intent["link"] = parts[2] + "/" + (url.deletingPathExtension().pathComponents[3])
        intent["call"] = url.query
      }
    }
    return intent
  }
  
  func performStartup(_ intent:[String:String]) {
    let mybounds = UIScreen.main.bounds
    mywindow = UIWindow.init(frame: mybounds)
    let istablet = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    let islandscape = mybounds.width > mybounds .height
    let myroot = istablet && islandscape ? FirstLandscapeViewController(intent) : LevelViewController(intent)
    let nav = istablet ? UINavigationController.init(rootViewController: myroot)
                       : PortraitNavigationController.init(rootViewController:myroot)
    nav.customNavBar()
    mywindow?.rootViewController = nav
    mywindow?.addSubview(myroot.view)
    mywindow?.makeKeyAndVisible()
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    TamUtils.readinitfiles()
    let url = launchOptions?[UIApplicationLaunchOptionsKey.url]
    let intent = url==nil ? [:] : processURL(url as! URL)
    performStartup(intent)
    return false   // so method below is not called
  }

  //  This method is called when a browser sends a custom link to Taminations
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    //  Since we don't know the current navigation state, just replace it
    performStartup(processURL(url))
    return true;     // we handled the URL
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

