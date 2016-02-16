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

class TamViewController : UIViewController {

  let intent:[String:String]
  init(_ intent:[String:String]) {
    self.intent = intent
    super.init(nibName:nil,bundle:nil)
  }
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  
  var contentFrame: CGRect {
    let frame1 = navigationController!.view.frame
    let frame2 = navigationController!.navigationBar.frame
    //  hard-wired status bar size = 20, don't know how to detect it
    return CGRectMake(frame1.origin.x,frame1.origin.y,frame1.size.width,frame1.size.height-frame2.size.height-20)
  }
  var levelAction: () -> Void = { }
  
  override var title:String? {
    get {
      return super.title
    }
    set {
      super.title = newValue
      let navbarframe = navigationController!.navigationBar.bounds
      if (navigationController?.childViewControllers.count > 1) {
        let backButton = TamButton(frame: CGRectMake(0,0,navbarframe.height*2,navbarframe.height*0.6))
        backButton.setTitle("Back",forState:UIControlState.Normal)
        backButton.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.addTarget(self, action: "backAction", forControlEvents: .TouchUpInside)
      } else {
        navigationItem.hidesBackButton = true
      }
      let titleView = UILabel(frame:navbarframe)
      titleView.text = newValue
      titleView.textColor = UIColor.whiteColor()
      titleView.font = UIFont.boldSystemFontOfSize(28)
      titleView.textAlignment = NSTextAlignment.Center
      titleView.shadowColor = UIColor.blackColor()
      titleView.shadowOffset = CGSizeMake(1,1)
      titleView.numberOfLines = 0
      titleView.adjustsFontSizeToFitWidth = true
      navigationItem.titleView = titleView
    }
  }
  
  @objc func backAction() {
    navigationController?.popViewControllerAnimated(true)
  }
  
  func setLevelButton(level:String) {
    let navbarframe = navigationController!.navigationBar.bounds
    let levelButton = TamButton(frame:CGRectMake(0,0,navbarframe.height*3,navbarframe.height*0.6))
    levelButton.setTitle(level,forState:UIControlState.Normal)
    levelButton.sizeToFit()
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: levelButton)
    levelButton.addTarget(self, action: "levelSelector", forControlEvents: .TouchUpInside)
    //  Hook up action to pop to list of calls for this level
    levelAction = {
      for vc in (self.navigationController?.viewControllers)! {
        if let callListViewController = vc as? CallListViewController {
          //  might not be the same level
          callListViewController.level = level
          callListViewController.loadView()
          self.navigationController?.popToViewController(callListViewController, animated: true)
        }
      }
    }
  }
  
  @objc func levelSelector() {
    levelAction()
  }

  override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
    let isTablet = UIDevice.currentDevice().userInterfaceIdiom == .Pad
    if (isTablet && (fromInterfaceOrientation == .Portrait || fromInterfaceOrientation == .PortraitUpsideDown)) {
      navigationController?.setViewControllers([FirstLandscapeViewController(intent)], animated: true)
    } else {
      navigationController?.setViewControllers([LevelViewController(intent)], animated: true)
    }
  }
  
  
}