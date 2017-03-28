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

class PlayButton : TamButton {

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    self.accessibilityIdentifier = "Play"  // for testing
    
    //  This controls the size
    let h = bounds.height/2
    let black = UIColor.black
    black.setFill()
    let path = UIBezierPath()
    
    if (isSelected) {
      let w = h/3
      path.append(UIBezierPath(rect: CGRect(x: bounds.width/2-w*1.5,y: bounds.height/2-h/2,width: w,height: h)))
      path.append(UIBezierPath(rect: CGRect(x: bounds.width/2+w*1.5,y: bounds.height/2-h/2,width: w,height: h)))
    } else {
      path.move(to: CGPoint(x: bounds.width/2-h*0.433, y: bounds.height/2-h/2))
      path.addLine(to: CGPoint(x: bounds.width/2+h*0.433, y: bounds.height/2))
      path.addLine(to: CGPoint(x: bounds.width/2-h*0.433, y: bounds.height/2+h/2))
      path.close()
    }
    
    //  Draw it
    path.fill()
    
  }
  

}
