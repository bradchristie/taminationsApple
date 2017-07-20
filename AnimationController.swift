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

class AnimationController : TamViewController {

  let level:String
  let link:String
  let animnum:Int
  let animcount:Int
  let animationControl:AnimationControl
  let panelControl:AnimationPanelControl
  let rightSwiper = UISwipeGestureRecognizer()
  let leftSwiper = UISwipeGestureRecognizer()
  
  var animationLayout:AnimationLayout!
  
  override init(_ intent:[String:String]) {
    level = intent["level"]!
    link = intent["link"]!
    animnum = Int(intent["animnum"]!)!
    animcount = Int(intent["animcount"]!)!
    animationControl = AnimationControl()
    panelControl = AnimationPanelControl()
    super.init(intent)
    rightSwiper.direction = .right
    leftSwiper.direction = .left
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func loadView() {
    animationLayout = AnimationLayout(frame: contentFrame)
    view = animationLayout
    animationControl.reset(animationLayout, animationLayout.animationView, link: link, animnum: animnum)
    title = animationControl.title
    setLevelButton(level)
    setShareButton("http://www.tamtwirlers.org/tamination/\(link).html?\(animationControl.animname)")
    panelControl.reset(animationLayout.animationPanel, v: animationLayout.animationView)
    animationLayout.itemText.text = "\(animnum+1) of \(animcount)"

    //  Hook up controls
    animationLayout.settingsButton.addTarget(self, action: #selector(AnimationController.settingsSelector), for: .touchUpInside)
    animationLayout.definitionButton.addTarget(self, action: #selector(AnimationController.definitionSelector), for: .touchUpInside)
    rightSwiper.addTarget(self, action: #selector(AnimationController.rightSwipeAction))
    leftSwiper.addTarget(self, action: #selector(AnimationController.leftSwipeAction))
    animationLayout.addGestureRecognizer(rightSwiper)
    animationLayout.addGestureRecognizer(leftSwiper)
  }
  
  @objc override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    //  On resume, re-read settings in case they have changed
    animationControl.readSettings(animationLayout.animationView)
  }
  
  @objc func settingsSelector() {
    navigationController?.pushViewController(SettingsController(intent), animated: true)
  }
  @objc func definitionSelector() {
    navigationController?.pushViewController(DefinitionViewController(intent), animated: true)
  }
  
  @objc func leftSwipeAction() {
    if (animnum+1 < animcount) {
      var vcs = navigationController!.viewControllers
      var intent = [String: String]()
      intent["level"] = level
      intent["link"] = link
      intent["animcount"] = "\(animcount)"
      intent["animnum"] = "\(animnum+1)"
      vcs[vcs.count-1] = AnimationController(intent)
      //  Default iOS presentation is scroll in from the right
      navigationController!.setViewControllers(vcs, animated: true)
    }
  }
  
  @objc func rightSwipeAction() {
    if (animnum > 0) {
      var vcs = navigationController!.viewControllers
      var intent = [String: String]()
      intent["level"] = level
      intent["link"] = link
      intent["animcount"] = "\(animcount)"
      intent["animnum"] = "\(animnum-1)"
      vcs[vcs.count-1] = AnimationController(intent)
      //  Default iOS presentation is scroll in from the right
      //  Trick iOS into scrolling from the left
      //  by making it think it is popping a VC
      if let nav = navigationController {
        nav.setViewControllers(vcs, animated: false)
        nav.pushViewController(self,animated:false)
        nav.popViewController(animated: true)
      }
    }
  }
  
}
