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
a    b     0          MSCALE_X(0)   MSKEW_Y(3)    MPERSP_0(6)
c    d     0          MSKEW_X(1)    MSCALE_Y(4)    MPERSP_1(7)
tx   ty    1          MTRANS_X(2)   MTRANS_Y(5)    MPERSP_2(8)

*/

import UIKit


import Foundation
import QuartzCore

class Matrix {
  
  var mat:CGAffineTransform
  
  init() {
    mat = CGAffineTransformMakeTranslation(0.0, 0.0)
  }
  
  init(_ mat:CGAffineTransform) {
    self.mat = mat
  }
  
  init(_ mat:Matrix) {
    self.mat = mat.mat
  }
  
  class func makeTransform(mat:CGAffineTransform) -> Matrix {
    return Matrix(mat)
  }
  
  class func makeTranslation(x:CGFloat, _ y:CGFloat) -> Matrix {
    return Matrix(CGAffineTransformMakeTranslation(x, y))
  }
  
  class func makeRotation(angle:CGFloat) -> Matrix {
    return Matrix(CGAffineTransformMakeRotation(angle))
  }
  
  class func makeScale(x:CGFloat, y:CGFloat) -> Matrix {
    return Matrix(CGAffineTransformMakeScale(x,y))
  }
  
  func postConcat(aff2:Matrix) -> Matrix {
    return Matrix(CGAffineTransformConcat(mat, aff2.mat))
  }
  
  func preConcat(aff2:Matrix) -> Matrix {
    return Matrix(CGAffineTransformConcat(aff2.mat, mat))
  }
  
  func postTranslate(x:CGFloat, y:CGFloat) -> Matrix {
    return postConcat(Matrix.makeTranslation(x, y))
  }
  
  func postRotate(angle:CGFloat) -> Matrix {
    return postConcat(Matrix.makeRotation(angle))
  }
  
  func preTranslate(x:CGFloat, y:CGFloat) -> Matrix {
    return preConcat(Matrix.makeTranslation(x, y))
  }
  
  func preRotate(angle:CGFloat) -> Matrix {
    return preConcat(Matrix.makeRotation(angle))
  }
  
  var location:Vector3D { get {
    var pt = CGPointMake(0,0)
    pt = CGPointApplyAffineTransform(pt, mat)
    return Vector3D(pt: pt)
    } }
  
  var direction:Vector3D { get {
    let mat2 = Matrix.makeTransform(mat)
    mat2.mat.tx = 0
    mat2.mat.ty = 0
    var pt = CGPointMake(1, 0)
    pt = CGPointApplyAffineTransform(pt, mat2.mat)
    return Vector3D(pt:pt)
    } }
  
  var angle:CGFloat { get {
    let v = direction
    return v.angle
    } }
  
  //  Compute and return the inverse matrix - only for affine transform matrix
  func inverse() -> Matrix {
    let det = mat.a*mat.d - mat.c*mat.b
    let m2 = Matrix()
    m2.mat.a = mat.d/det
    m2.mat.c = -mat.c/det
    m2.mat.tx = (mat.c*mat.ty - mat.d*mat.tx) / det
    m2.mat.b = -mat.b/det
    m2.mat.d = mat.a/det
    m2.mat.ty = (mat.b*mat.tx - mat.a*mat.ty) / det
    return m2
  }
  
}



