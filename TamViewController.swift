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

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

protocol TamViewControllerObserver : NSObjectProtocol  {
  func viewAppeared() -> Void
}

class TamViewController : UIViewController {

  let intent:[String:String]
  let levelButton = TamButton()
  let shareButton = ShareButton()
  let logoButton = LogoButton()
  var levelText = ""
  var shareText = ""
  var levelAction:()->Void = { }
  var shareAction:()->Void = { }
  weak var observer:TamViewControllerObserver? = nil
  
  init(_ intent:[String:String]) {
    self.intent = intent
    super.init(nibName:nil,bundle:nil)
    levelButton.addTarget(self, action: #selector(TamViewController.levelSelector), for: .touchUpInside)
    shareButton.addTarget(self, action: #selector(TamViewController.shareSelector), for: .touchUpInside)
    logoButton.addTarget(self, action: #selector(TamViewController.logoSelector), for: .touchUpInside)
  }
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  
  var contentFrame: CGRect {
    let frame1 = navigationController!.view.frame
    let frame2 = navigationController!.navigationBar.frame
    //  hard-wired status bar size = 20, don't know how to detect it
    return CGRect(x: frame1.origin.x,y: frame1.origin.y,width: frame1.size.width,height: frame1.size.height-frame2.size.height-20)
  }
  
  override var title:String? {
    get {
      return super.title
    }
    set {
      super.title = newValue
      let navbarframe = navigationController!.navigationBar.bounds
      if (navigationController?.childViewControllers.count > 1 || presentingViewController != nil) {
        let backButton = TamButton(frame: CGRect(x: 0,y: 0,width: navbarframe.height*2,height: navbarframe.height*0.6))
        backButton.setTitle("Back",for:UIControlState())
        backButton.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.addTarget(self, action: #selector(TamViewController.backAction), for: .touchUpInside)
      } else if (!(navigationController?.visibleViewController is FirstLandscapeViewController) &&
                (!(navigationController?.visibleViewController is LevelViewController))) {
        //  Looks like we got here by a direct handoff from Safari
        //  Let the user go back to the main Taminations page
        navigationItem.hidesBackButton = false
        logoButton.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoButton)
      } else {
        navigationItem.hidesBackButton = true
      }
      let titleView = UILabel(frame:navbarframe)
      titleView.text = newValue
      titleView.textColor = UIColor.white
      titleView.font = UIFont.boldSystemFont(ofSize: 28)
      titleView.textAlignment = NSTextAlignment.center
      titleView.shadowColor = UIColor.black
      titleView.shadowOffset = CGSize(width: 1,height: 1)
      titleView.numberOfLines = 0
      titleView.adjustsFontSizeToFitWidth = true
      navigationItem.titleView = titleView
    }
  }
  
  @objc func backAction() {
    if (navigationController?.childViewControllers.count > 1) {
      _ = navigationController?.popViewController(animated: true)
    } else if (presentingViewController != nil) {
      dismiss(animated: true, completion: nil)
    } else if (!(navigationController?.visibleViewController is FirstLandscapeViewController) &&
      (!(navigationController?.visibleViewController is LevelViewController))) {
      navigationController?.pushViewController(FirstLandscapeViewController([:]), animated: true)
    }
  }
  
  func setRightButtonItems() {
    var items:[UIBarButtonItem] = []
    if (levelText.length > 0) {
      levelButton.setTitle(levelText,for:UIControlState())
      levelButton.sizeToFit()
      items.append(UIBarButtonItem(customView: levelButton))
      //  Hook up action to pop to list of calls for this level
      levelAction = { [unowned self] in
        for vc in (self.navigationController?.viewControllers)! {
          if let callListViewController = vc as? CallListViewController {
            //  might not be the same level
            callListViewController.level = self.levelText
            callListViewController.loadView()
            _ = self.navigationController?.popToViewController(callListViewController, animated: true)
            return
          }
        }
        for vc in (self.navigationController?.viewControllers)! {
          if let firstViewController = vc as? FirstLandscapeViewController {
            firstViewController.selectLevel(self.levelText)
            _ = self.navigationController?.popToViewController(firstViewController, animated: true)
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
  
  func setLevelButton(_ level:String) {
    levelText = level
    setRightButtonItems()
  }
  
  func setShareButton(_ share:String) {
    shareText = share
    setRightButtonItems()
    shareAction = { [unowned self] in
      let controller = UIActivityViewController(activityItems: [self.shareText.matches("http.*") ? URL(string:self.shareText.replaceAll("\\s",""))! as Any : self.shareText as Any], applicationActivities: nil)
      if (UIDevice.current.userInterfaceIdiom == .pad) {
        let pop = UIPopoverController(contentViewController: controller)
        pop.present(from: self.shareButton.bounds, in: self.shareButton, permittedArrowDirections: .any, animated: true)
      } else {
        self.present(controller, animated:true, completion:nil)
      }
    }
  }
  
  @objc func levelSelector() {
    levelAction()
  }
  @objc func shareSelector() {
    shareAction()
  }
  
  @objc func logoSelector() {
    let isTablet = UIDevice.current.userInterfaceIdiom == .pad
    if (isTablet && UIDevice.current.orientation.isLandscape) {
      navigationController?.setViewControllers([FirstLandscapeViewController([:])], animated: true)
    } else {
      navigationController?.setViewControllers([LevelViewController([:])], animated: true)
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    observer?.viewAppeared()
  }
  
  override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
    let isTablet = UIDevice.current.userInterfaceIdiom == .pad
    if (isTablet && (fromInterfaceOrientation == .portrait || fromInterfaceOrientation == .portraitUpsideDown)) {
      navigationController?.setViewControllers([FirstLandscapeViewController(intent)], animated: true)
    } else {
      navigationController?.setViewControllers([LevelViewController(intent)], animated: true)
    }
  }
  
  
}
