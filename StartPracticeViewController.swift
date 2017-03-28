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

class StartPracticeViewController : TamViewController {
  
  var layout:StartPracticeLayout!
  var startPracticeControl = StartPracticeControl()
  
  override func loadView() {
    navigationController!.customNavBar()
    layout = StartPracticeLayout(frame:contentFrame)
    view = layout
    title = "Practice"
    startPracticeControl.reset(layout)
    layout.selectAction = { (level:String)->Void in
      var intent = [String: String]()
      if (level == "Tutorial") {
        self.navigationController?.pushViewController(TutorialViewController(intent), animated: true)
      } else {
        intent["level"] = level
        self.navigationController?.pushViewController(PracticeViewController(intent), animated: true)
      }
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    layout.unselect()
  }
  
  override var shouldAutorotate : Bool {
    return true
  }
  override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
    //  Don't do anything
  }
  


}
