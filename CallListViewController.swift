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

class CallListViewController : TamViewController {
 
  var level:String
  var firstcall = true
  //  Need to keep a pointer to the control so iOS doesn't zap it
  var callListControl = CallListControl()
  
  override init(_ intent:[String:String]) {
    level = intent["level"]!
    super.init(intent)
  }
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")  }
  
  override func loadView() {
    let myview = CallListLayout(frame: contentFrame)
    myview.dataSource = callListControl
    myview.delegate = callListControl
    callListControl.reset(level)
    myview.sb.delegate = callListControl
    view = myview
    title = LevelData.find(level)!.name
    callListControl.selectAction = { (level:String,link:String)->Void in
      var intent = [String: String]()
      intent["level"] = level
      intent["link"] = link
      self.navigationController?.pushViewController(AnimListViewController(intent), animated: true)
    }
    callListControl.reloadTable = { myview.reloadData() }
  }
  
  override func viewDidAppear(animated: Bool) {
    //  If link passed in from URL sent to app, go there immediately
    if firstcall && intent["link"] != nil {
      self.navigationController?.pushViewController(AnimListViewController(intent), animated: true)
    }
    firstcall = false
  }
  
}