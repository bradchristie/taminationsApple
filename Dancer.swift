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

import UIKit

enum Gender:Int {
  case boy=1
  case girl=2
  case phantom=3
}

enum ShowNumbers:Int {
  case numbers_OFF = 0
  case numbers_DANCERS = 1
  case numbers_COUPLES = 2
}

struct DancerData {
  var active = true
  var beau = false
  var belle = false
  var leader = false
  var trailer = false
  var center = false
  var verycenter = false
  var end = false
  weak var partner:Dancer? = nil
}

class Dancer {
  
  var hidden = false
  var showPath = false
  let number:String
  let number_couple:String
  let drawcolor:UIColor
  var fillcolor:UIColor  // need to be var for InteractiveDancer
  var starttx:Matrix     // only changed by sequencer
  var path:Path      // only changed by sequencer
  var hands = Hands.nohands
  let pathpath:CGMutablePath
  let body:UIBezierPath
  var tx:Matrix
  let gender:Gender
  let geom:Geometry
  var showNumber:ShowNumbers = .numbers_OFF
  
  //  vars for computing handholds
  weak var leftdancer:Dancer?
  weak var rightdancer:Dancer?
  weak var leftgrip:Dancer?
  weak var rightgrip:Dancer?
  var rightHandVisibility = false
  var leftHandVisibility = false
  var rightHandNewVisibility = false
  var leftHandNewVisibility = false
  
  //  for sequencer
  var data = DancerData()
  weak var clonedFrom:Dancer?
  
  init(number:String, number_couple:String, gender:Gender, fillcolor:UIColor, mat:Matrix, geom:Geometry, moves:[Movement]) {
    self.number = number
    self.number_couple = number_couple
    self.fillcolor = fillcolor
    self.gender = gender
    self.geom = geom
    drawcolor = fillcolor.darker()
    starttx = geom.startMatrix(mat)
    tx = Matrix()
    path = Path(moves)
    clonedFrom = nil
    //  Create path for drawing body, specific for the gender
    func makeBody() -> UIBezierPath {
        let rect = CGRect(x: -0.5,y: -0.5,width: 1,height: 1)
        switch gender {
        case .boy : return UIBezierPath(rect: rect)
        case .girl : return UIBezierPath(ovalIn: rect)
        case .phantom : return UIBezierPath(roundedRect: rect, cornerRadius: 0.3)
        }
    }
    body = makeBody()
    
    // Compute points of path for drawing path
    pathpath = CGMutablePath()
    animateComputed(0)
    pathpath.move(to: CGPoint(x:location.x, y:location.y))
    //CGPathMoveToPoint(pathpath, nil, location.x, location.y)
    for beat in 0...Int(beats*10) {
      animateComputed(CGFloat(beat)/10)
      pathpath.addLine(to: CGPoint(x:location.x, y:location.y))
      //CGPathAddLineToPoint(pathpath, nil, location.x, location.y)
    }
    animateComputed(-2.0)
  }
  
  convenience init(from:Dancer) {
    self.init(number:from.number, number_couple:from.number_couple, gender:from.gender, fillcolor:from.fillcolor, mat:from.tx,
      //  Already geometrically rotated so don't do it again
         geom:GeometryMaker.makeOne(from.geom.geometry()),moves:[Movement]())
    clonedFrom = from
  }
  
  func animate(_ beat:CGFloat) {
    hands = path.hands(beat)
    tx = Matrix(starttx)
    tx = tx.preConcat(path.animate(beat))
    tx = tx.postConcat(geom.pathMatrix(starttx,tx: tx,beat: beat))
  }

  func animateToEnd() {
    animate(path.beats)
  }
  
  func animateComputed(_ beat:CGFloat) {
    animate(beat)
  }
  
  func rotateStartAngle(_ angle:CGFloat) {
    starttx = starttx.preRotate(angle.toRadians)
    tx = Matrix(starttx)
  }
  
  var beats:CGFloat {
    return path.beats
  }
  
  var location:Vector3D {
    return Vector3D(pt:CGPoint(x: tx.mat.tx,y: tx.mat.ty))
  }
  
  var inCenter:Bool {
    let loc = location
    return sqrt(loc.x*loc.x+loc.y*loc.y) < 1.1
  }
  
  var isPhantom:Bool {
    return gender == .phantom
  }
  
  func draw(_ ctx:CGContext) {
    //  draw the head
    ctx.setFillColor(drawcolor.cgColor)
    ctx.fillEllipse(in: CGRect(x:0.17,y:-0.33,width:0.67,height:0.67))
    //  draw the body
    let bodycolor = showNumber == ShowNumbers.numbers_OFF || gender == .phantom ? fillcolor : fillcolor.veryBright()
    ctx.setFillColor(bodycolor.cgColor)
    ctx.addPath(body.cgPath)
    ctx.fillPath()
    //  draw body border
    ctx.setLineWidth(0.1)
    ctx.setStrokeColor(drawcolor.cgColor)
    ctx.addPath(body.cgPath)
    ctx.strokePath()
    //  Draw number if on
    if (showNumber != .numbers_OFF) {
      //  The dancer is rotated relative to the display, but of course
      //  the dancer number should not be rotated.
      //  So the number needs to be transformed back
      let angle = atan2(tx.mat.c,tx.mat.d)
      let txtext = Matrix.makeRotation(CG_PI/2+angle)
      ctx.concatenate(txtext.mat)
      ctx.setFillColor(UIColor.black.cgColor)
      ctx.textMatrix = Matrix.makeScale(-0.06, y: -0.06).mat
      ctx.setFont(CGFont("Helvetica" as NSString)!)
      ctx.setFontSize(14)
      ctx.setTextDrawingMode(.fill)
      ctx.textPosition = CGPoint(x:0.2, y:0.3)
      let attstr = NSAttributedString(string: showNumber == .numbers_COUPLES ? number_couple : number)
      let line = CTLineCreateWithAttributedString(attstr)
      CTLineDraw(line, ctx)
    }
  }
  
  func drawPath(_ ctx:CGContext) {
    //  The path color is a partly transparent version of the draw color
    var red:CGFloat = 0
    var green:CGFloat = 0
    var blue:CGFloat = 0
    var alpha:CGFloat = 1
    drawcolor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    let pathcolor = UIColor(red: red, green: green, blue: blue, alpha: 0.31)
    ctx.setStrokeColor(pathcolor.cgColor)
    ctx.setLineWidth(0.1)
    ctx.addPath(pathpath)
    ctx.strokePath()
  }
  
  func compare(_ d:Dancer) -> Int {
    return number.compare(d.number).rawValue
  }
  
}

func ==(d1:Dancer, d2:Dancer) -> Bool {
  return d1.number == d2.number
}
func !=(d1:Dancer, d2:Dancer) -> Bool { return d1.number != d2.number }
func ==(d1:Dancer?, d2:Dancer) -> Bool {
  return d1 != nil && d1! == d2
}

