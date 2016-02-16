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

class PlayButton : TamButton {

  override func drawRect(rect: CGRect) {
    super.drawRect(rect)
    
    //  This controls the size
    let h = bounds.height/2
    let black = UIColor.blackColor()
    black.setFill()
    let path = UIBezierPath()
    
    if (selected) {
      let w = h/3
      path.appendPath(UIBezierPath(rect: CGRectMake(bounds.width/2-w*1.5,bounds.height/2-h/2,w,h)))
      path.appendPath(UIBezierPath(rect: CGRectMake(bounds.width/2+w*1.5,bounds.height/2-h/2,w,h)))
    } else {
      path.moveToPoint(CGPoint(x: bounds.width/2-h*0.433, y: bounds.height/2-h/2))
      path.addLineToPoint(CGPoint(x: bounds.width/2+h*0.433, y: bounds.height/2))
      path.addLineToPoint(CGPoint(x: bounds.width/2-h*0.433, y: bounds.height/2+h/2))
      path.closePath()
    }
    
    //  Draw it
    path.fill()
    
  }
  

}
