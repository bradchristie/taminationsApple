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

class DefinitionViewController : TamViewController {

  let definitionControl = DefinitionControl()
  var link = ""
  var level = ""
  
  override init(_ intent:[String:String]) {
    super.init(intent)
    level = intent["level"]!
    link = intent["link"]!
  }
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func loadView() {
    title = TamUtils.getTitle(link)
    setLevelButton(level)
    let myview = DefinitionLayout(frame: contentFrame)
    definitionControl.reset(myview,link: link)
    view = myview
  }
  
  override func viewDidAppear(animated: Bool) {
    definitionControl.defstyleAction()
  }
  
}