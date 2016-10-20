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
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    let scale = 126.0/bounds.height
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 46.0/scale,y: 40.0/scale))
    path.addLine(to: CGPoint(x: 20.0/scale, y: 40.0/scale))
    path.addLine(to: CGPoint(x: 20.0/scale, y: 122.0/scale))
    path.addLine(to: CGPoint(x: 106.0/scale, y: 122.0/scale))
    path.addLine(to: CGPoint(x: 106.0/scale, y: 40.0/scale))
    path.addLine(to: CGPoint(x: 80.0/scale, y: 40.0/scale))
    path.move(to: CGPoint(x: 63.0/scale, y: 75.0/scale))
    path.addLine(to: CGPoint(x: 63.0/scale, y: 4.0/scale))
    path.addLine(to: CGPoint(x: 47.0/scale, y: 20.0/scale))
    path.move(to: CGPoint(x: 63.0/scale, y: 4.0/scale))
    path.addLine(to: CGPoint(x: 79.0/scale, y: 20.0/scale))
    let white = UIColor.white
    white.setStroke()
    path.lineWidth = 8.0/scale
    path.stroke()
  }
  
}
