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

class ShareButton : UIButton {
  
  override func drawRect(rect: CGRect) {
    super.drawRect(rect)
    let scale = 126.0/bounds.height
    let path = UIBezierPath()
    path.moveToPoint(CGPointMake(46.0/scale,40.0/scale))
    path.addLineToPoint(CGPointMake(20.0/scale, 40.0/scale))
    path.addLineToPoint(CGPointMake(20.0/scale, 122.0/scale))
    path.addLineToPoint(CGPointMake(106.0/scale, 122.0/scale))
    path.addLineToPoint(CGPointMake(106.0/scale, 40.0/scale))
    path.addLineToPoint(CGPointMake(80.0/scale, 40.0/scale))
    path.moveToPoint(CGPointMake(63.0/scale, 75.0/scale))
    path.addLineToPoint(CGPointMake(63.0/scale, 4.0/scale))
    path.addLineToPoint(CGPointMake(47.0/scale, 20.0/scale))
    path.moveToPoint(CGPointMake(63.0/scale, 4.0/scale))
    path.addLineToPoint(CGPointMake(79.0/scale, 20.0/scale))
    let white = UIColor.whiteColor()
    white.setStroke()
    path.lineWidth = 8.0/scale
    path.stroke()
  }
  
}