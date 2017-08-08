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

/*
Table for matrix fields iOS and Java
iOS                         Java                                     Win Matrix3x2
a    b     0          MSCALE_X(0)   MSKEW_Y(3)     MPERSP_0(6)       M11    M12    0
c    d     0          MSKEW_X(1)    MSCALE_Y(4)    MPERSP_1(7)       M21    M22    0
tx   ty    1          MTRANS_X(2)   MTRANS_Y(5)    MPERSP_2(8)       M31    M32    1

*/

import UIKit


import Foundation
import QuartzCore

class Matrix {
  
  var mat:CGAffineTransform
  
  init() {
    mat = CGAffineTransform(translationX: 0.0, y: 0.0)
  }
  
  init(_ mat:CGAffineTransform) {
    self.mat = mat
  }
  
  init(_ mat:Matrix) {
    self.mat = mat.mat
  }
  
  class func makeTransform(_ mat:CGAffineTransform) -> Matrix {
    return Matrix(mat)
  }
  
  class func makeTranslation(_ x:CGFloat, _ y:CGFloat) -> Matrix {
    return Matrix(CGAffineTransform(translationX: x, y: y))
  }
  
  class func makeRotation(_ angle:CGFloat) -> Matrix {
    return Matrix(CGAffineTransform(rotationAngle: angle))
  }
  
  class func makeScale(_ x:CGFloat, y:CGFloat) -> Matrix {
    return Matrix(CGAffineTransform(scaleX: x,y: y))
  }
  
  func postConcat(_ aff2:Matrix) -> Matrix {
    return Matrix(mat.concatenating(aff2.mat))
  }
  
  func preConcat(_ aff2:Matrix) -> Matrix {
    return Matrix(aff2.mat.concatenating(mat))
  }
  
  func postTranslate(_ x:CGFloat, y:CGFloat) -> Matrix {
    return postConcat(Matrix.makeTranslation(x, y))
  }
  
  func postRotate(_ angle:CGFloat) -> Matrix {
    return postConcat(Matrix.makeRotation(angle))
  }
  
  func preTranslate(_ x:CGFloat, y:CGFloat) -> Matrix {
    return preConcat(Matrix.makeTranslation(x, y))
  }
  
  func preRotate(_ angle:CGFloat) -> Matrix {
    return preConcat(Matrix.makeRotation(angle))
  }
  
  var location:Vector3D { get {
    var pt = CGPoint(x: 0,y: 0)
    pt = pt.applying(mat)
    return Vector3D(pt: pt)
    } }
  
  var direction:Vector3D { get {
    let mat2 = Matrix.makeTransform(mat)
    mat2.mat.tx = 0
    mat2.mat.ty = 0
    var pt = CGPoint(x: 1, y: 0)
    pt = pt.applying(mat2.mat)
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
  
  //  Matrix functions for SVD
  subscript(i:Int) -> CGFloat {
    get {
      switch i {
      case 0 : return mat.a
      case 1 : return mat.c
      case 2 : return mat.tx
      case 3 : return mat.b
      case 4 : return mat.d
      case 5 : return mat.ty
      case 6 : return 0
      case 7 : return 0
      case 8 : return 1
      default : fatalError("Matrix: subscript out of range")
      }
    }
    set {
      switch i {
      case 0 : mat.a = newValue
      case 1 : mat.c = newValue
      case 2 : mat.tx = newValue
      case 3 : mat.b = newValue
      case 4 : mat.d = newValue
      case 5 : mat.ty = newValue
      case 6 : break  //  We just assume these are 0,0,1
      case 7 : break
      case 8 : break
      default : fatalError("Matrix: subscript out of range")
      }
    }
  }
  
  func putArray(_ a:Array<Array<CGFloat>>) {
    if (a.count == 2) {
      //  Handle 2x2 array returned by svd22
      self[0] = a[0][0]
      self[1] = a[0][1]
      self[3] = a[1][0]
      self[4] = a[1][1]
    } else if (a.count == 3) {
      for i in 0...5 {
        self[i] = a[i/3][i%3]
      }
    }
  }
  
  func getArray() -> Array<Array<CGFloat>> {
    return (0...2).map { [self[$0*3],self[$0*3+1],self[$0*3+2]] }
  }
  
  class func transpose(_ a:Array<Array<CGFloat>>) -> Array<Array<CGFloat>> {
    return (0..<a.count).map { (i:Int) -> Array<CGFloat> in return (0..<a.count).map { (j:Int) -> CGFloat in a[j][i] } }
  }
  
  class func svd22(_ A:Array<Array<CGFloat>>) -> (Array<Array<CGFloat>>,Array<CGFloat>,Array<Array<CGFloat>>) {
    let a = A[0][0]
    let b = A[0][1]
    let c = A[1][0]
    let d = A[1][1]
    //  Check for trivial case
    let epsilon:CGFloat = 0.0001
    if (b.Abs < epsilon && c.Abs < epsilon) {
      let V:Array<Array<CGFloat>> = [[ (a < 0.0) ? -1.0 : 1.0, 0.0],
               [0.0, (d < 0.0) ? -1.0 : 1.0]]
      let Sigma = [a.Abs,d.Abs]
      let U:Array<Array<CGFloat>> = [[1.0,0.0],[0.0,1.0]]
      return (U,Sigma,V)
    } else {
      let j = a.Sq + b.Sq
      let k = c.Sq + d.Sq
      let vc = a*c + b*d
      //  Check to see if A^T*A is diagonal
      if (vc.Abs < epsilon) {
        let s1 = j.Sqrt
        let s2 = ((j-k).Abs < epsilon) ? s1 : k.Sqrt
        let Sigma = [s1,s2]
        let V:Array<Array<CGFloat>> = [[1.0,0.0],[0.0,1.0]]
        let U = [[a/s1,b/s1],[c/s2,d/s2]]
        return (U,Sigma,V)
      } else {   //  Otherwise, solve quadratic for eigenvalues
        let atanarg1 = 2 * a * c + 2 * b * d
        let atanarg2 = a * a + b * b - c * c - d * d
        let Theta = 0.5 * atan2(atanarg1,atanarg2)
        let U = [[Theta.Cos, -Theta.Sin],
                 [Theta.Sin, Theta.Cos]]
        
        let Phi = 0.5 * atan2(2 * a * b + 2 * c * d, a.Sq - b.Sq + c.Sq - d.Sq)
        let s11 = (a * Theta.Cos + c * Theta.Sin) * Phi.Cos +
          (b * Theta.Cos + d * Theta.Sin) * Phi.Sin
        let s22 = (a * Theta.Sin - c * Theta.Cos) * Phi.Sin +
          (-b * Theta.Sin + d * Theta.Cos) * Phi.Cos
        
        let S1 = a.Sq + b.Sq + c.Sq + d.Sq;
        let S2 = ((a.Sq + b.Sq - c.Sq - d.Sq).Sq + 4 * (a * c + b * d).Sq).Sqrt
        let Sigma = [(S1 + S2).Sqrt / 2, (S1 - S2).Sqrt / 2]
        
        let V = [[s11.Sign * Phi.Cos, -s22.Sign * Phi.Sin],
                 [s11.Sign * Phi.Sin, s22.Sign * Phi.Cos]]
        return (U,Sigma,V)
      }
    }
  
  
  }
  



}



