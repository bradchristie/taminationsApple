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

import Foundation
import QuartzCore

class Vector3D {
  

  var x:CGFloat = 0.0
  var y:CGFloat = 0.0
  var z:CGFloat = 0.0
  
  init() { }
  
  init(x: CGFloat, y: CGFloat) {
    self.x = x
    self.y = y
  
  }
  
  init(x: CGFloat, y: CGFloat, z:CGFloat) {
    self.x = x
    self.y = y
    self.z = z
  }
  
  init(pt: CGPoint) {
    self.x = pt.x
    self.y = pt.y
  }
  
  
  var length:CGFloat { get { return sqrt(x*x + y*y + z*z) } }
  
  var angle:CGFloat { get { return atan2(y,x) } }
  
  var isZero:Bool { get { return x==0.0 && y==0.0 && z==0.0 } }

  //  Rotate by a given angle
  func rotate(_ th:CGFloat) -> Vector3D {
    let d = length
    let a = angle + th
    return Vector3D(x: d*cos(a), y: d*sin(a))
  }
  
  func cross(_ v: Vector3D) -> Vector3D {
    return Vector3D(x: y*v.z - z*v.y,
      y: z*v.x - x*v.z,
      z: x*v.y - y*v.x)
  }
  
  func vectorTo(_ v: Vector3D) -> Vector3D {
    return Vector3D(x:v.x-x, y:v.y-y, z:v.z-z)
  }
  
  func angleDiff(_ v: Vector3D) -> CGFloat {
    return Vector3D.angleDiff(self.angle,a2:v.angle)
  }
  
  func concatenate(_ tx:Matrix) -> Vector3D {
    return Matrix().preTranslate(x, y: y).postConcat(tx).location
  }
  
  func preConcatenate(_ tx:Matrix) -> Vector3D {
    return Matrix().preTranslate(x, y: y).preConcat(tx).location
  }
  
  class func angleDiff(_ a1:CGFloat, a2:CGFloat) -> CGFloat {
    return ((a1-a2 + CG_PI*3.0).truncatingRemainder(dividingBy: CG_PI*2.0)) - CG_PI
  }
  
}

func +(v1:Vector3D, v2:Vector3D) -> Vector3D {
  return Vector3D(x: v1.x+v2.x, y: v1.y+v2.y, z: v1.z+v2.z)
}

func -(v1:Vector3D, v2:Vector3D) -> Vector3D {
  return Vector3D(x: v1.x-v2.x, y: v1.y-v2.y, z: v1.z-v2.z)
}

func *(v1:Vector3D, s:CGFloat) -> Vector3D {
  return Vector3D(x: v1.x*s, y: v1.y*s, z: v1.z*s)
}

