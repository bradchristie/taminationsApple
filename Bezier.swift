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


/*
Table for matrix fields iOS and Java
iOS                         Java
a    b     0          MSCALE_X   MSKEW_Y     MPERSP_0 (? - not used?)
c    d     0          MSKEW_X    MSCALE_Y    MPERSP_1
x    y     1          MTRANS_X   MTRANS_Y    MPERSP_2

*/

import Foundation
import QuartzCore

class Bezier {
  
  let x1:CGFloat
  let y1:CGFloat
  let ctrlx1:CGFloat
  let ctrly1:CGFloat
  let ctrlx2:CGFloat
  let ctrly2:CGFloat
  let x2:CGFloat
  let y2:CGFloat
  
  let ax:CGFloat
  let bx:CGFloat
  let cx:CGFloat
  let ay:CGFloat
  let by:CGFloat
  let cy:CGFloat
  
  init(x1:CGFloat, y1:CGFloat, ctrlx1:CGFloat, ctrly1:CGFloat, ctrlx2:CGFloat, ctrly2:CGFloat, x2:CGFloat, y2:CGFloat) {
    self.x1 = x1
    self.y1 = y1
    self.ctrlx1 = ctrlx1
    self.ctrly1 = ctrly1
    self.ctrlx2 = ctrlx2
    self.ctrly2 = ctrly2
    self.x2 = x2
    self.y2 = y2
    
    //  Calculate coefficients
    self.cx = 3.0 * (ctrlx1-x1)
    self.bx = 3.0 * (ctrlx2-ctrlx1) - cx
    self.ax = x2 - x1 - cx - bx
    self.cy = 3.0 * (ctrly1-y1)
    self.by = 3.0 * (ctrly2-ctrly1) - cy
    self.ay = y2 - y1 - cy - by
  }
  
  //  Return the movement along the curve given "t" between 0 and 1
  func translate(_ t:CGFloat) -> Matrix {
    let x = x1 + t*(cx + t*(bx + t*ax))
    let y = y1 + t*(cy + t*(by + t*ay))
    return Matrix.makeTranslation(x,y)
  }
  
  //  Return the angle of the derivative given "t" between 0 and 1
  func rotate(_ t:CGFloat) -> Matrix {
    let x = cx + t*(2.0*bx + t*3.0*ax)
    let y = cy + t*(2.0*by + t*3.0*ay)
    let theta = atan2(y,x)
    return Matrix.makeRotation(theta)
  }

  //  Return turn direction at end of curve
  var rolling:CGFloat { get {
    let v1 = Vector3D(x: x2-ctrlx2, y: y2-ctrly2)
    let v2 = Vector3D(x: x2-ctrlx1, y: y2-ctrly1)
    return v2.cross(v1).z
  } }
  
}



