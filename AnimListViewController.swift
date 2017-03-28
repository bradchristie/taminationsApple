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

class AnimListViewController : TamViewController, AnimListSelectListener, AnimListDifficultyHider {

  let level:String
  let link:String
  let call:String?
  //  Need to keep a pointer to the control so iOS doesn't zap it
  let animListControl = AnimListControl()
  var animlist:AnimListLayout!
  
  override init(_ intent:[String:String]) {
    level = intent["level"]!
    link = intent["link"]!
    call = intent["call"]
    super.init(intent)
  }

  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  override func loadView() {
    animlist = AnimListLayout(frame:CGRect(x:0,y:0,width:contentFrame.width,height:contentFrame.height-40))
    animlist.table.dataSource = animListControl
    animlist.table.delegate = animListControl
    let definitionButton = TamButton()
    definitionButton.setTitle("Definition", for: UIControlState())
    let settingsButton = TamButton() //frame:CGRect(x: contentFrame.width/2,y: contentFrame.height-40,width: contentFrame.width/2,height: 38))
    settingsButton.setTitle("Settings", for: UIControlState())
    let buttonpanel = UIView(frame:CGRect(x: 0,y: contentFrame.height-40,width: contentFrame.width,height: 38))
    buttonpanel.addSubview(definitionButton)
    buttonpanel.addSubview(settingsButton)
    view = UIView(frame:contentFrame)
    view.addSubview(animlist)
    view.addSubview(buttonpanel)
    buttonpanel.visualConstraints("|[a][b(==a)]|",fillVertical:true)
    view.visualConstraints("V:|[a][b(==40)]|",fillHorizontal: true)
    setLevelButton(level)

    //  Hook up controls
    settingsButton.addTarget(self, action: #selector(AnimListViewController.settingsSelector), for: .touchUpInside)
    definitionButton.addTarget(self, action: #selector(AnimListViewController.definitionSelector), for: .touchUpInside)
    animListControl.selectListener = self
    animListControl.difficultyHider = self
    animListControl.reset(link, level: level, call: call)
    title = animListControl.title
    setShareButton("http://www.tamtwirlers.org/tamination/"+link+".html")
  }
 
  func selectAction(level: String, link: String, data: AnimListControl.AnimListData, xmlcount: Int) {
    var intent = [String: String]()
    intent["level"] = level
    intent["link"] = link
    intent["animnum"] = "\(data.xmlindex)"
    intent["animcount"] = "\(xmlcount)"
    navigationController?.pushViewController(AnimationViewController(intent), animated: true)
  }
  
  func hideDifficulty() {
    animlist.hideDifficulty();
  }
  
  @objc func settingsSelector() {
    navigationController?.pushViewController(SettingsViewController(intent), animated: true)
  }
  @objc func definitionSelector() {
    navigationController?.pushViewController(DefinitionViewController(self.intent), animated: true)
  }
  
}
 
