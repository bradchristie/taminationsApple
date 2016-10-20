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

class PracticeViewController : TamViewController {
  
  let control = PracticeControl()
  
  override func loadView() {
    let layout = PracticeLayout()
    view = layout
    control.setTitle = { (title:String) in
      self.title = title
    }
    layout.returnButtonAction = {
      _ = self.navigationController?.popViewController(animated: true)
    }
    layout.definitionButtonAction = {
      var intent = [String: String]()
      intent["link"] = self.control.link;
      self.navigationController?.pushViewController(DefinitionViewController(intent), animated: true)
    }
    control.reset(intent, practiceLayout: layout)
    control.nextAnimation()
  }
  
  override var shouldAutorotate : Bool {
    return false
  }
  override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
    //  Don't do anything
  }
}
