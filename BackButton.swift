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

class BackButton : TamButton {
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    let ctx = UIGraphicsGetCurrentContext()
    ctx?.translateBy(x: bounds.minX+bounds.width/2, y: bounds.minY+bounds.height/2)
    ctx?.scaleBy(x: bounds.height/4, y: bounds.height/4)
    ctx?.setLineWidth(0.2)
    ctx?.setStrokeColor(UIColor.black.cgColor)
    
    ctx?.move(to: CGPoint(x: 0.433, y: -0.5))
    ctx?.addLine(to: CGPoint(x: -0.433, y: 0))
    ctx?.addLine(to: CGPoint(x: 0.433, y: 0.5))
    ctx?.strokePath()
    
  }
  
}
