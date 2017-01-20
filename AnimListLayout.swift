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

enum DifficultyColor:UInt {
  case common = 0xffc0ffc0
  case harder = 0xffffffc0
  case expert = 0xffffc0c0
  case `default` = 0xffffffff
}

class AnimListLayout : UIView {

  let table:UITableView
  let difficultyview:UIView
  
  override init(frame: CGRect) {
    let h = UIScreen.main.bounds.height/40
    let diffframe = CGRect(x: 0, y: frame.height-h*1.5, width: frame.width, height: h*1.5)
    difficultyview = UIView(frame:diffframe)
    let common = UILabel(frame:CGRect(x: 0, y: 0, width: frame.width/3, height: h*1.5))
    common.font = UIFont.systemFont(ofSize: h)
    common.textAlignment = NSTextAlignment.center
    common.backgroundColor = UIColor.colorFromHex(DifficultyColor.common.rawValue)
    common.text = "Common"
    let harder = UILabel(frame:CGRect(x: frame.width/3,y: 0,width: frame.width/3,height: h*1.5))
    harder.font = UIFont.systemFont(ofSize: h)
    harder.textAlignment = NSTextAlignment.center
    harder.backgroundColor = UIColor.colorFromHex(DifficultyColor.harder.rawValue)
    harder.text = "Harder"
    let expert = UILabel(frame:CGRect(x: frame.width*2/3,y: 0,width: frame.width/3,height: h*1.5))
    expert.font = UIFont.systemFont(ofSize: h)
    expert.textAlignment = NSTextAlignment.center
    expert.backgroundColor = UIColor.colorFromHex(DifficultyColor.expert.rawValue)
    expert.text = "Expert"
    difficultyview.addSubview(common)
    difficultyview.addSubview(harder)
    difficultyview.addSubview(expert)
    table = UITableView(frame:frame, style:UITableViewStyle.plain)
    super.init(frame: frame)
    addSubview(table)
    addSubview(difficultyview)
    
    table.register(UITableViewCell.self, forCellReuseIdentifier: "animlisttablecell")
  }
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  func hideDifficulty() {
    difficultyview.removeFromSuperview()
  }

}

