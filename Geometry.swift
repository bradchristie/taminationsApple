
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

enum GeometryType:Int {
  case BIGON = 1
  case SQUARE = 2
  case HEXAGON = 3
}

protocol Geometry {
  
  func startMatrix(mat:Matrix) -> Matrix;
  func pathMatrix(starttx:Matrix, tx:Matrix, beat:CGFloat) -> Matrix;
  func drawGrid(ctx:CGContextRef)
  func geometry() -> GeometryType
  func clone() -> Geometry
  
}

class GeometryMaker {
  
  static func makeAll(type:GeometryType) -> [Geometry] {
    switch type {
      case .BIGON : return [BigonGeometry(0)]
      case .SQUARE : return [SquareGeometry(0),SquareGeometry(1)]
      case .HEXAGON : return [HexagonGeometry(0),HexagonGeometry(1),HexagonGeometry(2)]
    }
  }
  
  static func makeOne(g:GeometryType, r:Int=0) -> Geometry {
    switch g {
      case .BIGON : return BigonGeometry(r)
      case .SQUARE : return SquareGeometry(r)
      case .HEXAGON : return HexagonGeometry(r)
    }
  }
  
  static func makeOne(gstr:String, r:Int=0) -> Geometry {
    switch gstr {
      case "Bigon" : return BigonGeometry(r)
      case "Hexagon" : return HexagonGeometry(r)
      default : return SquareGeometry(r)
    }
  }
  
  
  
}
///////////////////////////////////////////////////////////////////////////
class BigonGeometry : Geometry {
  let rotnum:Int
  var prevangle:CGFloat = 0
  init(_ rotnum:Int) { self.rotnum = rotnum }
  func geometry() -> GeometryType { return .BIGON }
  func clone() -> Geometry { return BigonGeometry(rotnum) }
  
  func startMatrix(mat: Matrix) -> Matrix {
    let x = mat.mat.tx
    let y = mat.mat.ty
    let r = sqrt(x*x+y*y)
    let startangle = atan2(mat.mat.b,mat.mat.d)
    let angle = atan2(y,x)+CG_PI
    let bigangle = angle*2-CG_PI
    let x2 = r*cos(bigangle)
    let y2 = r*sin(bigangle)
    let startangle2 = startangle + angle
    return Matrix().postRotate(startangle2).postTranslate(x2, y: y2)
  }

  func pathMatrix(starttx: Matrix, tx: Matrix, beat: CGFloat) -> Matrix {
    let a0 = atan2(starttx.mat.ty,starttx.mat.tx)
    let a1 = atan2(tx.mat.ty,tx.mat.tx)
    if (beat <= 0) {
      prevangle = a1
    }
    let wrap = round((a1-prevangle)/(CG_PI*2))
    let a2 = a1 - wrap*CG_PI*2
    let a3 = a2 - a0
    prevangle = a2
    return Matrix().postRotate(a3)
  }
  
  func drawGrid(ctx: CGContextRef) {
    //
  }
  
}
///////////////////////////////////////////////////////////////////////////
class SquareGeometry : Geometry {
  let rotnum:Int
  init(_ rotnum:Int) { self.rotnum = rotnum }
  func geometry() -> GeometryType { return .SQUARE }
  func clone() -> Geometry { return SquareGeometry(rotnum) }
  
  func startMatrix(mat:Matrix) -> Matrix {
    return Matrix(mat).postRotate(CGFloat(M_PI*Double(rotnum)))
  }
  
  func pathMatrix(starttx: Matrix, tx: Matrix, beat: CGFloat) -> Matrix {
    //  No transform needed
    return Matrix()
  }
  
  func drawGrid(ctx: CGContextRef) {
    CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
    CGContextSetLineWidth(ctx, 0.01)
    for var x:CGFloat = -7.5; x <= 7.5; x += 1 {
      CGContextMoveToPoint(ctx, x, -7.5)
      CGContextAddLineToPoint(ctx, x, 7.5)
    }
    for var y:CGFloat = -7.5; y <= 7.5; y += 1 {
      CGContextMoveToPoint(ctx, -7.5, y)
      CGContextAddLineToPoint(ctx, 7.5, y)
    }
    CGContextStrokePath(ctx)
  }
  
}
///////////////////////////////////////////////////////////////////////////
class HexagonGeometry : Geometry {
  let rotnum:Int
  var prevangle:CGFloat = 0
  init(_ rotnum:Int) { self.rotnum = rotnum }
  func geometry() -> GeometryType { return .HEXAGON }
  func clone() -> Geometry { return HexagonGeometry(rotnum) }

  func startMatrix(mat: Matrix) -> Matrix {
    let a = (CG_PI*2/3)*CGFloat(rotnum)
    let x = mat.mat.tx
    let y = mat.mat.ty
    let r = sqrt(x*x+y*y)
    let startangle = atan2(mat.mat.b, mat.mat.d)
    let angle = atan2(y,x)
    let dangle = angle < 0 ? -(CG_PI+angle)/3 : (CG_PI-angle)/3
    let x2 = r * cos(angle+dangle+a)
    let y2 = r * sin(angle+dangle+a)
    let startangle2 = startangle + a + dangle
    return Matrix().postRotate(startangle2).postTranslate(x2,y:y2)
  }
  
  func pathMatrix(starttx: Matrix, tx: Matrix, beat: CGFloat) -> Matrix {
    let a0 = atan2(starttx.mat.ty,starttx.mat.tx)
    let a1 = atan2(tx.mat.ty,tx.mat.tx)
    //  Correct for wrapping around +/- pi
    if (beat <= 0) {
      prevangle = a1
    }
    let wrap = round((a1-prevangle)/(CG_PI*2))
    let a2 = a1 - wrap*CG_PI*2
    let a3 = -(a2-a0)/3
    prevangle = a2
    return Matrix().postRotate(a3)
  }
  
  func drawGrid(ctx: CGContextRef) {
    //
  }
  
}


