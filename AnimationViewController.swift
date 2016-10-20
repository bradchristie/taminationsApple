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

class AnimationViewController : TamViewController {

  let level:String
  let link:String
  let animnum:Int
  let animcount:Int
  let animationControl:AnimationControl
  let panelControl:AnimationPanelControl
  let downSwiper = UISwipeGestureRecognizer()
  let upSwiper = UISwipeGestureRecognizer()
  
  var definitionAction:()->Void = { }
  var reloadSettings:()->Void = { }
  
  override init(_ intent:[String:String]) {
    level = intent["level"]!
    link = intent["link"]!
    animnum = Int(intent["animnum"]!)!
    animcount = Int(intent["animcount"]!)!
    animationControl = AnimationControl()
    panelControl = AnimationPanelControl()
    super.init(intent)
    downSwiper.direction = .down
    upSwiper.direction = .up
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func loadView() {
    let animationLayout = AnimationLayout(frame: contentFrame)
    view = animationLayout
    animationControl.reset(animationLayout, animationLayout.animationView, link: link, animnum: animnum)
    title = animationControl.title
    setLevelButton(level)
    setShareButton("http://www.tamtwirlers.org/tamination/\(link).html?\(animationControl.animname)")
    panelControl.reset(animationLayout.animationPanel, view: animationLayout.animationView)

    //  Hook up controls
    animationLayout.settingsButton.addTarget(self, action: #selector(AnimationViewController.settingsSelector), for: .touchUpInside)
    animationLayout.definitionButton.addTarget(self, action: #selector(AnimationViewController.definitionSelector), for: .touchUpInside)
    definitionAction = {
      self.navigationController?.pushViewController(DefinitionViewController(self.intent), animated: true)
    }
    downSwiper.addTarget(self, action: #selector(AnimationViewController.downSwipeAction))
    upSwiper.addTarget(self, action: #selector(AnimationViewController.upSwipeAction))
    animationLayout.addGestureRecognizer(downSwiper)
    animationLayout.addGestureRecognizer(upSwiper)
    
    //  On resume, re-read settings in case they have changed
    reloadSettings = { self.animationControl.readSettings(animationLayout.animationView) }
    
  }
  
  @objc override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    reloadSettings()
  }
  
  @objc func settingsSelector() {
    navigationController?.pushViewController(SettingsViewController(intent), animated: true)
  }
  @objc func definitionSelector() {
    definitionAction()
  }
  
  @objc func upSwipeAction() {
    if (animnum+1 < animcount) {
      var vcs = navigationController!.viewControllers
      var intent = [String: String]()
      intent["level"] = level
      intent["link"] = link
      intent["animcount"] = "\(animcount)"
      intent["animnum"] = "\(animnum+1)"
      vcs[vcs.count-1] = AnimationViewController(intent)
      navigationController!.setViewControllers(vcs, animated: true)
    } else {
      navigationController!.popViewController(animated: true)
    }
  }
  
  @objc func downSwipeAction() {
    if (animnum > 0) {
      var vcs = navigationController!.viewControllers
      var intent = [String: String]()
      intent["level"] = level
      intent["link"] = link
      intent["animcount"] = "\(animcount)"
      intent["animnum"] = "\(animnum-1)"
      vcs[vcs.count-1] = AnimationViewController(intent)
      navigationController!.setViewControllers(vcs, animated: true)
    } else {
      navigationController!.popViewController(animated: true)
    }
  }
  
}
