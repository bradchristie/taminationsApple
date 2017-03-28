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

class FirstLandscapeViewController: TamViewController, CallListFollower, LevelSelectionListener {

  var settingsControl:SettingsControl
  var model:CallListModel
  var firstcall = true

  var topview:UIView!
  var rightview:UIView!
  var levelLayout:LevelLayout!
  var aboutLayout:AboutLayout!
  var settingsLayout:SettingsLayout!
  var calllistLayout:CallListLayout!
  
  override init(_ intent:[String:String]) {
    model = CallListModel()
    settingsControl = SettingsControl()
    super.init(intent)
    model.follower = self
  }
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func loadView() {
    //  Create frames for left and right sides
    topview = UIView(frame: contentFrame)
    var leftframe = contentFrame
    leftframe.size.width = contentFrame.width/3
    var rightframe = contentFrame
    rightframe.size.width = contentFrame.width*2/3
    let rightbounds = rightframe
    rightframe.origin.x = contentFrame.width/3
    rightview = UIView(frame: rightframe)
    topview.addSubview(rightview)
    
    //  Create views for the frames
    levelLayout = LevelLayout(frame: leftframe)
    topview.addSubview(levelLayout)

    aboutLayout = AboutLayout(frame:rightbounds)
    rightview.addSubview(aboutLayout)
    aboutLayout.loadPage("about")

    settingsLayout = SettingsLayout(frame:rightbounds)
    settingsControl.reset(settingsLayout)
    rightview.addSubview(settingsLayout)

    calllistLayout = CallListLayout(frame: rightbounds)
    calllistLayout.dataSource = model
    calllistLayout.delegate = model
    calllistLayout.sb.delegate = model
    rightview.addSubview(calllistLayout)

    view = topview
    title = "Taminations"
    rightview.bringSubview(toFront: aboutLayout)
    levelLayout.levelSelectionListener = self
    //  If level passed in from URL sent to app, go there immediately
    if firstcall && intent["level"] != nil {
      selectLevel(intent["level"]!)
    }
  }
  
  func levelSelected(_ level: String) {
    levelLayout.unselect()
    title = "Taminations"
    switch level {
    case "About" : rightview.bringSubview(toFront: aboutLayout)
    case "Settings" : rightview.bringSubview(toFront: settingsLayout)
    case "Practice" : navigationController?.present(PracticeNavigationController(rootViewController: StartPracticeViewController(intent)), animated: true, completion: nil)
    case "Sequencer" : navigationController?.pushViewController(SequencerViewController(self.intent), animated: true)
    default : selectLevel(level)
    }
  }
  
  func selectLevel(_ level:String) -> Void {
    self.model.reset(self,level)
    calllistLayout.reloadData()
    rightview.bringSubview(toFront: calllistLayout)
    levelLayout.selectLevel(level)
    title = "Taminations - " + LevelData.find(level)!.name
  }
  
  func selectAction(level: String, link: String) {
    var intent = [String: String]()
    intent["level"] = level
    intent["link"] = link
    self.navigationController?.pushViewController(SecondLandscapeViewController(intent), animated: true)
  }
  
  func tableLoaded() {
    calllistLayout.reloadData()
  }

  override func viewDidAppear(_ animated: Bool) {
    //  If link passed in from URL sent to app, go there immediately
    if firstcall && intent["link"] != nil {
      self.navigationController?.pushViewController(SecondLandscapeViewController(intent), animated: true)
    }
    firstcall = false
    levelLayout.unselect(isLandscape: true)
  }

}
