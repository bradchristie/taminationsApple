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


class LevelLayout2: UIView {

  var selectAction:(String)->Void = { arg in }
  var selectedLabel:LevelView? = nil

  class LevelView : UIView {
    
    var label:UILabel
    var layout:LevelLayout2
    var color:UIColor
    
    init(_ layout:LevelLayout2, _ text:String, indent:CGFloat, color: UIColor) {
      self.layout = layout
      self.color = color
      //  Add a text view
      label = UILabel()
      //  This is the background view
      super.init(frame:CGRectInfinite)
      userInteractionEnabled = true
      backgroundColor = color
      layer.borderWidth = 1
      layer.borderColor = UIColor.blackColor().CGColor
      label.text = text
      label.font = UIFont(name:"Helvetica Bold", size: layout.frame.size.height/40)
      addSubview(label)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {  }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {  }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {  }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
      backgroundColor = UIColor.blueColor()
      label.textColor = UIColor.whiteColor()
      layout.selectAction(label.text ?? "")
      layout.selectedLabel = self
    }
    func unselect() {
      backgroundColor = color
      label.textColor = UIColor.blackColor()
    }
    
  }
  
  
  init() {
    super.init(frame:CGRectInfinite)
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  

}
