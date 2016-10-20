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

class CallListLayout : UITableView {
  
  var sb: UISearchBar
  
  init(frame: CGRect) {
    sb = UISearchBar(frame: CGRect(x: 0,y: 0,width: frame.size.width,height: 44))
    super.init(frame:frame, style:UITableViewStyle.plain)
    addSubview(sb)
    tableHeaderView = sb
  }
    
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
}
