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

enum DifficultyColor:UInt {
  case COMMON = 0xffc0ffc0
  case HARDER = 0xffffffc0
  case EXPERT = 0xffffc0c0
  case DEFAULT = 0xffffffff
}

class AnimListLayout : UIView {

  let table:UITableView
  let difficultyview:UIView
  
  override init(frame: CGRect) {
    let h = UIScreen.mainScreen().bounds.height/40
    let diffframe = CGRectMake(0, frame.height-h*1.5, frame.width, h*1.5)
    difficultyview = UIView(frame:diffframe)
    let common = UILabel(frame:CGRectMake(0, 0, frame.width/3, h*1.5))
    common.font = UIFont.systemFontOfSize(h)
    common.textAlignment = NSTextAlignment.Center
    common.backgroundColor = UIColor.colorFromHex(DifficultyColor.COMMON.rawValue)
    common.text = "Common"
    let harder = UILabel(frame:CGRectMake(frame.width/3,0,frame.width/3,h*1.5))
    harder.font = UIFont.systemFontOfSize(h)
    harder.textAlignment = NSTextAlignment.Center
    harder.backgroundColor = UIColor.colorFromHex(DifficultyColor.HARDER.rawValue)
    harder.text = "Harder"
    let expert = UILabel(frame:CGRectMake(frame.width*2/3,0,frame.width/3,h*1.5))
    expert.font = UIFont.systemFontOfSize(h)
    expert.textAlignment = NSTextAlignment.Center
    expert.backgroundColor = UIColor.colorFromHex(DifficultyColor.EXPERT.rawValue)
    expert.text = "Expert"
    difficultyview.addSubview(common)
    difficultyview.addSubview(harder)
    difficultyview.addSubview(expert)
    table = UITableView(frame:frame, style:UITableViewStyle.Plain)
    super.init(frame: frame)
    addSubview(table)
    addSubview(difficultyview)
    
    table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "animlisttablecell")
  }
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  func hideDifficulty() {
    difficultyview.removeFromSuperview()
  }

}

