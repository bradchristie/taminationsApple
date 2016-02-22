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

class LevelViewController: TamViewController {

  var levelLayout:LevelLayout? = nil
  
  override func loadView() {
    levelLayout = LevelLayout(frame: contentFrame)
    levelLayout!.selectAction = { (level:String)->Void in
      var intent = [String: String]()
      intent["level"] = level
      self.levelLayout!.selectLevel(level)
      switch level {
      case "Settings" : self.navigationController?.pushViewController(SettingsViewController(intent), animated: true)
      case "About" : self.navigationController?.pushViewController(AboutViewController(intent), animated: true)
      case "Sequencer" : self.navigationController?.pushViewController(SequencerViewController(intent), animated: true)
      case "Practice" : self.navigationController?.pushViewController(StartPracticeViewController(intent), animated: true)
      default : self.navigationController?.pushViewController(CallListViewController(intent), animated: true)
      }
    }
    view = levelLayout
    title = "Taminations"
    //  If level passed in from URL sent to app, go there immediately
    if intent["level"] != nil {
      self.navigationController?.pushViewController(CallListViewController(intent), animated: true)
    }
  }
    
  override func viewDidAppear(animated: Bool) {
    levelLayout?.unselect()
  }
  
}
