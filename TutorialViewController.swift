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

class TutorialViewController : TamViewController, ReturnButtonListener, TitleSetter, TutorialFinishedListener {
  
  var layout:PracticeLayout!
  let control = TutorialControl()
  
  override func loadView() {
    layout = PracticeLayout()
    view = layout
    control.titleSetter = self
    layout.returnButtonListener = self
    control.reset(intent, layout: layout)
    control.nextAnimation()
  }
  
  override var shouldAutorotate : Bool {
    return false
  }
  override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
    //  Don't do anything
  }

  override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.landscapeLeft
  }
  
  override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
    return UIInterfaceOrientation.landscapeLeft
  }
  
  func tutorialFinished() {
    _ = self.navigationController?.popViewController(animated: true)
  }
  
  func returnAction() {
    _ = self.navigationController?.popViewController(animated: true)
  }
  
  func setThisTitle(_ title:String) {
      self.title = title
    }
  
}
