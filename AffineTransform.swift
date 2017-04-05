/*

Taminations Square Dance Animations App for iOS
Copyright (C) 2015 Brad Christie

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

class AffineTransform  {
  
  var mat:CGAffineTransform
  
  init() {
    mat = CGAffineTransformMakeTranslation(0.0, 0.0)
  }
  
  init(transform mat:CGAffineTransform) {
    self.mat = mat
  }
  
  class func makeTransform(mat:CGAffineTransform) -> AffineTransform {
    return AffineTransform(transform: mat)
  }
  
  class func makeTranslation(x:CGFloat, _ y:CGFloat) -> AffineTransform {
    return AffineTransform(transform: CGAffineTransformMakeTranslation(x, y))
  }
  
  class func makeRotation(angle:CGFloat) -> AffineTransform {
    return AffineTransform(transform:CGAffineTransformMakeRotation(angle))
  }
  
  class func makeScale(x:CGFloat, y:CGFloat) -> AffineTransform {
    return AffineTransform(transform:CGAffineTransformMakeScale(x,y))
  }
  
  func concat(aff2:AffineTransform) {
    mat = CGAffineTransformConcat(mat, aff2.mat)
  }
  
  func preConcat(aff2:AffineTransform) {
    mat = CGAffineTransformConcat(aff2.mat, mat)
  }
  
  func translate(x:CGFloat, y:CGFloat) {
    concat(AffineTransform.makeTranslation(x, y))
  }
  
  func rotate(angle:CGFloat) {
    concat(AffineTransform.makeRotation(angle))
  }
  
  func preTranslate(x:CGFloat, y:CGFloat) {
    preConcat(AffineTransform.makeTranslation(x, y))
  }
  
  func preRotate(angle:CGFloat) {
    preConcat(AffineTransform.makeRotation(angle))
  }
  
  func location() -> Vector3D {
    var pt = CGPointMake(0,0)
    pt = CGPointApplyAffineTransform(pt, mat)
    return Vector3D(pt: pt)
  }
  
  func direction() -> Vector3D {
    let mat2 = AffineTransform.makeTransform(mat)
    mat2.mat.tx = 0
    mat2.mat.ty = 0
    var pt = CGPointMake(1, 0)
    pt = CGPointApplyAffineTransform(pt, mat2.mat)
    return Vector3D(pt:pt)
  }
  
  func angle() -> CGFloat
  {
    let v = direction()
    return v.angle()
  }
  
}



