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

class PracticeViewController : TamViewController, ReturnButtonListener, DefinitionButtonListener, TitleSetter {
  
  var layout:PracticeLayout!
  let control = PracticeControl()
  
  override func loadView() {
    layout = PracticeLayout()
    view = layout
    control.titleSetter = self
    layout.returnButtonListener = self
    layout.definitionButtonListener = self
    control.reset(intent, layout: layout)
    control.nextAnimation()
  }
  
  func setThisTitle(_ newTitle: String) {
    title = newTitle
  }
  
  func returnAction() {
    _ = navigationController?.popViewController(animated: true)
  }
  func definitionAction() {
    var intent = [String: String]()
    intent["link"] = self.control.link;
    navigationController?.pushViewController(DefinitionViewController(intent), animated: true)
  }
  
  override var shouldAutorotate : Bool {
    return false
  }
  override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
    //  Don't do anything
  }
}
