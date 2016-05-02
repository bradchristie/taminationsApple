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

class AnimListViewController : TamViewController {

  let level:String
  let link:String
  let call:String?
  //  Need to keep a pointer to the control so iOS doesn't zap it
  let animListControl = AnimListControl()
  var definitionAction:()->Void = { }
  
  override init(_ intent:[String:String]) {
    level = intent["level"]!
    link = intent["link"]!
    call = intent["call"]
    super.init(intent)
  }

  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  override func loadView() {
    let myview = AnimListLayout(frame: CGRectMake(contentFrame.origin.x,contentFrame.origin.y,contentFrame.width,contentFrame.height-40))
    myview.table.dataSource = animListControl
    myview.table.delegate = animListControl
    let definitionButton = TamButton(frame:CGRectMake(0,contentFrame.height-40,contentFrame.width/2,38))
    definitionButton.setTitle("Definition", forState: UIControlState.Normal)
    let settingsButton = TamButton(frame:CGRectMake(contentFrame.width/2,contentFrame.height-40,contentFrame.width/2,38))
    settingsButton.setTitle("Settings", forState: UIControlState.Normal)
    myview.addSubview(definitionButton)
    myview.addSubview(settingsButton)
    view = myview
    animListControl.hideDifficulty = {
      myview.hideDifficulty();
    }
    setLevelButton(level)
    //  Hook up controls
    settingsButton.addTarget(self, action: #selector(AnimListViewController.settingsSelector), forControlEvents: .TouchUpInside)
    definitionButton.addTarget(self, action: #selector(AnimListViewController.definitionSelector), forControlEvents: .TouchUpInside)
    definitionAction = {
      self.navigationController?.pushViewController(DefinitionViewController(self.intent), animated: true)
    }
    animListControl.selectAction = { (level:String,link:String,item:AnimListControl.AnimListData,animcount:Int)->Void in
      var intent = [String: String]()
      intent["level"] = level
      intent["link"] = link
      intent["animnum"] = "\(item.xmlindex)"
      intent["animcount"] = "\(animcount)"
      self.navigationController?.pushViewController(AnimationViewController(intent), animated: true)
    }
    animListControl.reset(link, level: level, call: call)
    title = animListControl.title
    setShareButton("http://www.tamtwirlers.org/tamination/"+link+".html")
  }
 
  @objc func settingsSelector() {
    navigationController?.pushViewController(SettingsViewController(intent), animated: true)
  }
  @objc func definitionSelector() {
    definitionAction()
  }
  
}
 