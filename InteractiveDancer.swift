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

class InteractiveDancer : Dancer {
  
  let LEFTSENSITIVITY:CGFloat = 0.02
  let RIGHTSENSITIVITY:CGFloat = 0.02
  let DIRECTIONALPHA:CGFloat = 0.9
  let DIRECTIONTHRESHOLD:CGFloat = 0.01
  
  var onTrack = true
  var primaryTouch = CGPointZero
  var primaryMove = CGPointZero
  var secondaryTouch = CGPointZero
  var secondaryMove = CGPointZero
  var primaryDirection = Vector3D(x: 0, y: 0)
  var primaryUITouch:UITouch? = nil
  var secondaryUITouch:UITouch? = nil
  
  override init(number:String, number_couple:String, gender:Gender, fillcolor:UIColor, mat:Matrix, geom:Geometry, moves:[Movement]) {
    super.init(number: number, number_couple: number_couple, gender: gender, fillcolor: fillcolor, mat: mat, geom: geom, moves: moves)
  }
  
  func computeMatrix(beat:CGFloat)->Matrix {
    let savetx = Matrix(tx)
    super.animate(beat)
    let computetx = Matrix(tx)
    tx = savetx
    return computetx
  }
  
  override func animateComputed(beat: CGFloat) {
    super.animate(beat)
  }
  
  override func animate(beat: CGFloat) {
    fillcolor = beat <= 0 || onTrack ? drawcolor.veryBright() : UIColor.grayColor()
    if (beat <= -2.0) {
      tx = Matrix(starttx)
    } else {
      //  Apply any additional movement and angle from the user
      //  This processes left and right touches
      if (primaryUITouch != nil) {
        let dx = -(primaryMove.y - primaryTouch.y) * LEFTSENSITIVITY
        let dy = -(primaryMove.x - primaryTouch.x) * LEFTSENSITIVITY
        tx = tx.postTranslate(dx, y: dy)
        primaryTouch = primaryMove
        if (secondaryUITouch == nil) {
          //  Right finger is up - rotation follows movement
          if (primaryDirection.isZero) {
            primaryDirection = Vector3D(x: dx,y: dy)
          } else {
            primaryDirection = Vector3D(
              x: DIRECTIONALPHA * primaryDirection.x + (1-DIRECTIONALPHA) * dx,
              y: DIRECTIONALPHA * primaryDirection.y + (1-DIRECTIONALPHA) * dy )
          }
          if (primaryDirection.length >= DIRECTIONTHRESHOLD) {
            let a1 = tx.angle
            let a2 = primaryDirection.angle
            tx = tx.preRotate(a2-a1)
          }
        }
      }
      if (secondaryUITouch != nil) {
        //  Rotation follow right finger
        //  Get the vector of the user's finger
        let dx = -(secondaryMove.y - secondaryTouch.y) * RIGHTSENSITIVITY;
        let dy = -(secondaryMove.x - secondaryTouch.x) * RIGHTSENSITIVITY;
        let vf = Vector3D(x: dx, y: dy)
        //  Get the vector the dancer is facing
        let vu = tx.direction
        //  Amount of rotation is z of the cross product of the two
        let da = vu.cross(vf).z
        tx = tx.preRotate(da)
        secondaryTouch = secondaryMove
      }
    }
    
  }
  
  func doTouch(m:UITouch, inView:UIView) {
    let action = m.phase
    let s = 500.0 / inView.bounds.size.height
    if (action == .Began) {
      //  Touch down event
      //  Figure out if touching left or right side, and remember the point
      //  Also need to remember the Touch to correlate future move events
      let controller = NSUserDefaults.standardUserDefaults().integerForKey("primarycontroller")
      let xy = m.locationInView(inView)
      if ((xy.x > inView.bounds.size.width/2.0) ^ (controller == 0)) {
        primaryTouch.x = xy.x * s
        primaryTouch.y = xy.y * s
        primaryMove = primaryTouch
        primaryUITouch = m
        primaryDirection = Vector3D(x: 0, y: 0)
      } else {
        secondaryTouch.x = xy.x * s
        secondaryTouch.y = xy.y * s
        secondaryMove = secondaryTouch
        secondaryUITouch = m
      }
    }
    else if (action == .Ended) {
      //  Touch up event
      //  Stop moving and rotating
      if (m == primaryUITouch) {
        primaryUITouch = nil
      } else {
        secondaryUITouch = nil
      }
    }
    else if (action == .Moved) {
      //  MOvements
      let xy = m.locationInView(inView)
      if (m == primaryUITouch) {
        primaryMove.x = xy.x * s
        primaryMove.y = xy.y * s
      } else {
        secondaryMove.x = xy.x * s
        secondaryMove.y = xy.y * s
      }
    }
  }
  
}
