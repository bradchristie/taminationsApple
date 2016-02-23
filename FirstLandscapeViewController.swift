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

class FirstLandscapeViewController: TamViewController {

  var settingsControl:SettingsControl
  var callListControl:CallListControl
  var firstcall = true
  var selectLevel:(String)->Void = { arg in }
  var unselect:()->Void = { }

  override init(_ intent:[String:String]) {
    callListControl = CallListControl()
    settingsControl = SettingsControl()
    super.init(intent)
  }
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func loadView() {
    //  Create frames for left and right sides
    let topview = UIView(frame: contentFrame)
    var leftframe = contentFrame
    leftframe.size.width = contentFrame.width/3
    var rightframe = contentFrame
    rightframe.size.width = contentFrame.width*2/3
    let rightbounds = rightframe
    rightframe.origin.x = contentFrame.width/3
    let rightview = UIView(frame: rightframe)
    topview.addSubview(rightview)
    
    //  Create views for the frames
    let levelLayout = LevelLayout(frame: leftframe)
    topview.addSubview(levelLayout)

    let aboutLayout = AboutLayout(frame:rightbounds)
    rightview.addSubview(aboutLayout)
    aboutLayout.loadPage("about")

    let settingsLayout = SettingsLayout(frame:rightbounds)
    settingsControl.reset(settingsLayout)
    rightview.addSubview(settingsLayout)

    let calllistview = CallListLayout(frame: rightbounds)
    calllistview.dataSource = callListControl
    calllistview.delegate = callListControl
    calllistview.sb.delegate = callListControl
    callListControl.reloadTable = { calllistview.reloadData() }
    rightview.addSubview(calllistview)

    view = topview
    title = "Taminations"
    rightview.bringSubviewToFront(aboutLayout)
    levelLayout.selectAction = { (level:String)->Void in
      levelLayout.unselect()
      self.title = "Taminations"
      switch level {
        case "About" : rightview.bringSubviewToFront(aboutLayout)
        case "Settings" : rightview.bringSubviewToFront(settingsLayout)
        case "Practice" : self.navigationController?.presentViewController(PracticeNavigationController(rootViewController: StartPracticeViewController(self.intent)), animated: true, completion: nil)
          case "Sequencer" : self.navigationController?.pushViewController(SequencerViewController(self.intent), animated: true)
        default : self.selectLevel(level)
      }
    }
    selectLevel = { level in
      self.callListControl.reset(level)
      calllistview.reloadData()
      rightview.bringSubviewToFront(calllistview)
      levelLayout.selectLevel(level)
      self.title = "Taminations - " + LevelData.find(level)!.name
    }
    unselect = { levelLayout.unselect(isLandscape: true) }
    callListControl.selectAction = { (level:String,link:String)->Void in
      var intent = [String: String]()
      intent["level"] = level
      intent["link"] = link
      self.navigationController?.pushViewController(SecondLandscapeViewController(intent), animated: true)
    }
    //  If level passed in from URL sent to app, go there immediately
    if firstcall && intent["level"] != nil {
      levelLayout.selectAction(intent["level"]!)
    }
  }

  override func viewDidAppear(animated: Bool) {
    //  If link passed in from URL sent to app, go there immediately
    if firstcall && intent["link"] != nil {
      self.navigationController?.pushViewController(SecondLandscapeViewController(intent), animated: true)
    }
    firstcall = false
    unselect()
  }

}
