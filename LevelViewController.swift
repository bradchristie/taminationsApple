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

class LevelViewController: TamViewController, LevelSelectionListener {

  var levelLayout:LevelLayoutBase!
  
  override func loadView() {
    levelLayout = LevelLayout(frame: contentFrame)
    title = "Taminations"
    levelLayout.levelSelectionListener = self
    view = levelLayout
    //  If level passed in from URL sent to app, go there immediately
    if intent["level"] != nil {
      self.navigationController?.pushViewController(CallListViewController(intent), animated: true)
    }
  }
  
  func levelSelected(_ level: String) {
    var intent = [String: String]()
    intent["level"] = level
    //  self.levelLayout!.selectLevel(level)
    switch level {
    case "Settings" : navigationController?.pushViewController(SettingsController(intent), animated: true)
    case "About" : navigationController?.pushViewController(AboutController(intent), animated: true)
    case "Sequencer" : navigationController?.pushViewController(SequencerController(intent), animated: true)
    case "Practice" : navigationController?.present(PracticeNavigationController(rootViewController: StartPracticeViewController(intent)), animated: true, completion: nil)
    default : navigationController?.pushViewController(CallListViewController(intent), animated: true)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    levelLayout.unselect()
  }
  
}
