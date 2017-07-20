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

class CallListViewController : TamViewController, CallListFollower {
 
  var level:String
  var firstcall = true
  //  Need to keep a pointer to the control so iOS doesn't zap it
  let model = CallListModel()
  var callListView:CallListLayout!
  
  override init(_ intent:[String:String]) {
    level = intent["level"]!
    super.init(intent)
    model.follower = self
  }
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")  }
  
  override func loadView() {
    callListView = CallListLayout(frame: contentFrame)
    callListView.dataSource = model
    callListView.delegate = model
    model.reset(self,level)
    callListView.sb.delegate = model
    view = callListView
    title = LevelData.find(level)!.name
  }
  
  func selectAction(level: String, link: String) {
    var intent = [String: String]()
    intent["level"] = level
    intent["link"] = link
    self.navigationController?.pushViewController(AnimListViewController(intent), animated: true)
  }
  
  func tableLoaded() {
    callListView.reloadData()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    //  If link passed in from URL sent to app, go there immediately
    if firstcall && intent["link"] != nil {
      self.navigationController?.pushViewController(AnimListViewController(intent), animated: true)
    }
    firstcall = false
  }
  
}
