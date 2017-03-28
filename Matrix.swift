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
    for i in 0...5 {
      self[i] = a[i/3][i%3]
    }
  }
  
  func getArray() -> Array<Array<CGFloat>> {
    return (0...2).map { [self[$0*3],self[$0*3+1],self[$0*3+2]] }
  }
  
  class func transpose(_ a:Array<Array<CGFloat>>) -> Array<Array<CGFloat>> {
    return (0...2).map { [a[0][$0],a[1][$0],a[2][$0]] }
  }
  
  class func SVD(_ u: inout Array<Array<CGFloat>>) -> (Array<Array<CGFloat>>,Array<CGFloat>,Array<Array<CGFloat>>) {
    //  Compute the thin SVD from G. H. Golub and C. Reinsch, Numer. Math. 14, 403-420 (1970)
    let epsilon:CGFloat = 2.220446049250313e-16
    var prec:CGFloat = epsilon //Math.pow(2,-52) // assumes double prec
    let tolerance:CGFloat = (1.0e-64)/prec
    let itmax = 50
    var c:CGFloat
    var l=0
    
    let m = 3  // this is fixed for 3x3 arrays
    let n = 3
    
    var e:[CGFloat] = [0,0,0]
    var q:[CGFloat] = [0,0,0]
    var v:Array<Array<CGFloat>> = [[0,0,0],[0,0,0],[0,0,0]]
    
    func pythag(_ aa:CGFloat, _ bb:CGFloat) -> CGFloat {
      let a = abs(aa)
      let b = abs(bb)
      if (a > b) {
        return a*sqrt(1.0+(b*b/a/a))
      }
      else if (b == 0.0) {
        return a
      }
      return b*sqrt(1.0+(a*a/b/b))
    }
    
    //  Householder's reduction to bidiagonal form
    var f:CGFloat
    var g:CGFloat = 0.0
    var h:CGFloat
    var x:CGFloat = 0.0
    var y:CGFloat
    var z:CGFloat
    var s:CGFloat

    for i in 0..<n {
      e[i] = g
      l = i+1
      s = u.sumByCGFloat { $0[i]*$0[i] }
      if (s <= tolerance) {
        g = 0.0
      }
      else
      {
        f = u[i][i]
        g = sqrt(s)
        if (f >= 0.0) {
          g = -g
        }
        h = f*g-s
        u[i][i] = f-g
        for j in l..<n {
          s = u[i..<m].map{$0}.sumByCGFloat { $0[i]*$0[j] }
          f = s/h
          for k in i..<m {
            u[k][j] += f*u[k][i]
          }
        }
      }
      q[i] = g
      s = (l..<m).map{$0}.sumByCGFloat { j in u[i][j]*u[i][j] }
      if (s <= tolerance) {
        g = 0.0
      }
      else
      {
        f = u[i][i+1]
        g = sqrt(s)
        if (f >= 0.0) {
          g = -g
        }
        h = f*g - s
        u[i][i+1] = f-g
        for j in l..<n {
          e[j] = u[i][j]/h
        }
        for j in l..<m {
          s = (l..<n).map{$0}.sumByCGFloat { k in u[j][k]*u[i][k] }
          for k in l..<n {
            u[j][k] += s*e[k]
          }
        }
      }
      y = abs(q[i]) + abs(e[i])
      if (y > x) {
        x = y
      }
    }

    // accumulation of right hand transformations
//  for i in n-1 downTo 0 {
    for i in (0..<n).reversed() {
      if (g != 0.0) {
        h = g*u[i][i+1]
        for j in l..<n {
          v[j][i]=u[i][j]/h
        }
        for j in l..<n {
          s = (l..<n).map{$0}.sumByCGFloat {k in u[i][k]*v[k][j] }
          for k in l..<n {
            v[k][j] += (s*v[k][i])
          }
        }
      }
      for j in l..<n {
        v[i][j] = 0.0
        v[j][i] = 0.0
      }
      v[i][i] = 1.0
      g = e[i]
      l = i
    }

    // accumulation of left hand transformations
    for i in (0..<n).reversed() {
      l = i+1
      g = q[i]
      for j in l..<n {
        u[i][j] = 0.0
      }
      if (g != 0.0) {
        h = u[i][i]*g
        for j in l..<n {
          s = u[l..<m].map{$0}.sumByCGFloat { $0[i]*$0[j] }
          f = s/h
          for k in i..<m {
            u[k][j]+=f*u[k][i]
          }
        }
        for j in i..<m {
          u[j][i] = u[j][i]/g
        }
      }
      else {
        for j in i..<m {
          u[j][i] = 0.0
        }
      }
      u[i][i] += 1.0
    }
    
    // diagonalization of the bidiagonal form
    prec *= x
    for k in (0..<n).reversed() {
      for iteration in 0..<itmax {
        // test f splitting
        var test_convergence = false
        var el = k
        for ella in (0...k).reversed() {
          el = ella
          if (abs(e[ella]) <= prec) {
            test_convergence = true
            break
          }
          if (abs(q[ella-1]) <= prec) {
            break
          }
        }
        if (!test_convergence) {
          // cancellation of e[l] if l>0
          c = 0.0
          s = 1.0
          let l1 = el-1
          for i in el..<(k+1) {
            f = s*e[i]
            e[i] = c*e[i]
            if (abs(f) <= prec) {
              break
            }
            g = q[i]
            h = pythag(f,g)
            q[i] = h
            c = g/h
            s = -f/h
            for j in 0..<m {
              y = u[j][l1]
              z = u[j][i]
              u[j][l1] =  y*c+(z*s)
              u[j][i] = -y*s+(z*c)
            }
          }
        }
        // test f convergence
        z = q[k]
        if (el == k) {
          //convergence
          if (z < 0.0) {
            //q[k] is made non-negative
            q[k] = -z
            for j in 0 ..< n {
              v[j][k] = -v[j][k]
            }
          }
          break  //break out of iteration loop and move on to next k value
        }
        if (iteration >= itmax-1) {
          fatalError("Error: no convergence.")
        }
        // shift from bottom 2x2 minor
        x = q[el]
        y = q[k-1]
        g = e[k-1]
        h = e[k]
        f = ((y-z)*(y+z)+(g-h)*(g+h))/(2.0*h*y)
        g = pythag(f,1.0)
        if (f < 0.0) {
          f = ((x-z)*(x+z)+h*(y/(f-g)-h))/x
        } else {
          f = ((x-z)*(x+z)+h*(y/(f+g)-h))/x
        }
        // next QR transformation
        c = 1.0
        s = 1.0
        for i in (el+1) ..< (k+1) {
          g = e[i]
          y = q[i]
          h = s*g
          g *= c
          z = pythag(f,h)
          e[i-1] = z
          c = f/z
          s = h/z
          f = x*c+g*s
          g = -x*s+g*c
          h = y*s
          y *= c
          for j in 0..<n {
            x = v[j][i-1]
            z = v[j][i]
            v[j][i-1] = x*c+z*s
            v[j][i] = -x*s+z*c
          }
          z = pythag(f,h)
          q[i-1] = z
          c = f/z
          s = h/z
          f = c*g + s*y
          x = -s*g + c*y
          for j in 0..<m {
            y = u[j][i-1]
            z = u[j][i]
            u[j][i-1] = y*c+z*s
            u[j][i] = -y*s+z*c
          }
        }
        e[el] = 0.0
        e[k] = f
        q[k] = x
      }
    }

    //vt= transpose(v)
    //return (u,q,vt)
    q = q.map { ($0 < prec) ? 0.0 : $0 }
    
    //sort eigenvalues
    var i = 1
    while (i < n) {
      //writeln(q)
      for j in 0..<i {
        if (q[j] < q[i]) {
          //  writeln(i,'-',j)
          c = q[j]
          q[j] = q[i]
          q[i] = c
          for k in 0...1 {
            let temp = u[k][i]; u[k][i] = u[k][j]; u[k][j] = temp
          }
          for k in 0...1 {
            let temp = v[k][i]; v[k][i] = v[k][j]; v[k][j] = temp
          }
          //     u.swapCols(i,j)
          //     v.swapCols(i,j)
          i = j
        }
      }
      i += 1
    }
    
    return (u,q,v)
  }
  
}



