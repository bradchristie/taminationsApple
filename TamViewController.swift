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
  let levelButton = TamButton()
  let shareButton = ShareButton()
  var levelText = ""
  var shareText = ""
  var levelAction:()->Void = { }
  var shareAction:()->Void = { }
  
  init(_ intent:[String:String]) {
    self.intent = intent
    super.init(nibName:nil,bundle:nil)
    levelButton.addTarget(self, action: #selector(TamViewController.levelSelector), forControlEvents: .TouchUpInside)
    shareButton.addTarget(self, action: #selector(TamViewController.shareSelector), forControlEvents: .TouchUpInside)
  }
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  
  var contentFrame: CGRect {
    let frame1 = navigationController!.view.frame
    let frame2 = navigationController!.navigationBar.frame
    //  hard-wired status bar size = 20, don't know how to detect it
    return CGRectMake(frame1.origin.x,frame1.origin.y,frame1.size.width,frame1.size.height-frame2.size.height-20)
  }
  
  override var title:String? {
    get {
      return super.title
    }
    set {
      super.title = newValue
      let navbarframe = navigationController!.navigationBar.bounds
      if (navigationController?.childViewControllers.count > 1 || presentingViewController != nil) {
        let backButton = TamButton(frame: CGRectMake(0,0,navbarframe.height*2,navbarframe.height*0.6))
        backButton.setTitle("Back",forState:UIControlState.Normal)
        backButton.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.addTarget(self, action: #selector(TamViewController.backAction), forControlEvents: .TouchUpInside)
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
    if (navigationController?.childViewControllers.count > 1) {
      navigationController?.popViewControllerAnimated(true)
    } else if (presentingViewController != nil) {
      dismissViewControllerAnimated(true, completion: nil)
    }
  }
  
  func setRightButtonItems() {
    var items:[UIBarButtonItem] = []
    if (levelText.length > 0) {
      levelButton.setTitle(levelText,forState:UIControlState.Normal)
      levelButton.sizeToFit()
      items.append(UIBarButtonItem(customView: levelButton))
      //  Hook up action to pop to list of calls for this level
      levelAction = {
        for vc in (self.navigationController?.viewControllers)! {
          if let callListViewController = vc as? CallListViewController {
            //  might not be the same level
            callListViewController.level = self.levelText
            callListViewController.loadView()
            self.navigationController?.popToViewController(callListViewController, animated: true)
            return
          }
        }
        for vc in (self.navigationController?.viewControllers)! {
          if let firstViewController = vc as? FirstLandscapeViewController {
            firstViewController.selectLevel(self.levelText)
            self.navigationController?.popToViewController(firstViewController, animated: true)
            return
          }
        }
      }
    }
    if (shareText.length > 0) {
      shareButton.sizeToFit()
      items.append(UIBarButtonItem(customView: shareButton))
    }
    navigationItem.rightBarButtonItems = items
  }
  
  func setLevelButton(level:String) {
    levelText = level
    setRightButtonItems()
  }
  
  func setShareButton(share:String) {
    shareText = share
    setRightButtonItems()
    shareAction = {
      let controller = UIActivityViewController(activityItems: [self.shareText.matches("http.*") ? NSURL(string:self.shareText.replaceAll("\\s",""))! : self.shareText], applicationActivities: nil)
      if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
        let pop = UIPopoverController(contentViewController: controller)
        pop.presentPopoverFromRect(self.shareButton.bounds, inView: self.shareButton, permittedArrowDirections: .Any, animated: true)
      } else {
        self.presentViewController(controller, animated:true, completion:nil)
      }
    }
  }
  
  @objc func levelSelector() {
    levelAction()
  }
  @objc func shareSelector() {
    shareAction()
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