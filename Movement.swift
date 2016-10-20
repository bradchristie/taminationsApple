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

import Foundation
import QuartzCore

enum Hands:Int {
  case nohands = 0
  case lefthand = 1
  case righthand = 2
  case bothhands = 3
  case gripleft = 5
  case gripright = 6
  case gripboth = 7
  case anygrip = 8
}
func &(left:Hands, right:Hands) -> Hands {
  var raw = left.rawValue & right.rawValue
  if (raw == 4) {
    raw = 0
  }
  return Hands(rawValue: raw)!
}


class Movement {
  
  
  var beats:CGFloat
  var fullbeats:CGFloat
  var hands:Hands
  var cx1:CGFloat
  var cy1:CGFloat
  var cx2:CGFloat
  var cy2:CGFloat
  var x2:CGFloat
  var y2:CGFloat
  var cx3:CGFloat
  var cx4:CGFloat
  var cy4:CGFloat
  var x4:CGFloat
  var y4:CGFloat
  var btranslate:Bezier?
  var brotate:Bezier?
  
  init(fullbeats:CGFloat, hands:Hands,
    cx1:CGFloat, cy1:CGFloat, cx2:CGFloat, cy2:CGFloat, x2:CGFloat, y2:CGFloat,
    cx3:CGFloat, cx4:CGFloat, cy4:CGFloat, x4:CGFloat, y4:CGFloat, beats:CGFloat) {
      self.beats = beats
      self.fullbeats = fullbeats
      self.hands = hands
      self.cx1 = cx1
      self.cy1 = cy1
      self.cx2 = cx2
      self.cy2 = cy2
      self.x2 = x2
      self.y2 = y2
      self.cx3 = cx3
      self.cx4 = cx4
      self.cy4 = cy4
      self.x4 = x4
      self.y4 = y4
      recalculate()
  }
  
  convenience init(beats:CGFloat, hands:Hands,
    cx1:CGFloat, cy1:CGFloat, cx2:CGFloat, cy2:CGFloat, x2:CGFloat, y2:CGFloat) {
      self.init(fullbeats:beats, hands:hands,
        cx1:cx1, cy1:cy1, cx2:cx2, cy2:cy2, x2:x2, y2:y2,
        cx3:cx1, cx4:cx2, cy4:cy2, x4:x2, y4:y2, beats:beats)
  }
  
  init(element elem:JiNode) {
    beats = CGFloat(Double(elem["beats"]!)!)  //  Yes, needs to be unwrapped twice, first for finding the attribute, second for conversion to number
    fullbeats = beats
    hands = Movement.getHands(elem["hands"]!)
    cx1 = CGFloat(Double(elem["cx1"]!)!)
    cy1 = CGFloat(Double(elem["cy1"]!)!)
    cx2 = CGFloat(Double(elem["cx2"]!)!)
    cy2 = CGFloat(Double(elem["cy2"]!)!)
    x2 = CGFloat(Double(elem["x2"]!)!)
    y2 = CGFloat(Double(elem["y2"]!)!)
    if (elem["cx3"] != nil) {
      cx3 = CGFloat(Float(elem["cx3"]!)!)
      cx4 = CGFloat(Float(elem["cx4"]!)!)
      cy4 = CGFloat(Float(elem["cy4"]!)!)
      x4 = CGFloat(Float(elem["x4"]!)!)
      y4 = CGFloat(Float(elem["y4"]!)!)
    }
    else {
      cx3 = cx1
      cx4 = cx2
      cy4 = cy2
      x4 = x2
      y4 = y2
    }
    recalculate()
  }
  
  func recalculate() {
    btranslate = Bezier(x1: 0, y1: 0, ctrlx1: cx1, ctrly1: cy1, ctrlx2: cx2, ctrly2: cy2, x2: x2, y2: y2)
    brotate = Bezier(x1: 0, y1: 0, ctrlx1: cx3, ctrly1: 0, ctrlx2: cx4, ctrly2: cy4, x2: x4, y2: y4)
  }
  
  /**
   *   Translates a string describing hand use to one of the
   *   int constants above
   * @param h  String from XML hands parameter
   * @return   int constant used in this class
   */
  class func getHands(_ h:String) -> Hands {
    let d:[String:Hands] = ["none":.nohands, "nohands":.nohands, "left":.lefthand, "right":.righthand, "both":.bothhands,
      "anygrip":.anygrip, "gripleft":.gripleft, "gripright":.gripright, "gripboth":.gripboth]
    return d[h]!
  }
  
  
  /**
   * Return a matrix for the translation part of this movement at time t
   * @param t  Time in beats
   * @return   Matrix for using with view
   */
  func translate(_ t:CGFloat=CGFloat.greatestFiniteMagnitude) -> Matrix {
    let tt = min(max(0,t), beats)
    return btranslate!.translate(tt/beats)
  }
  
  /**
   * Return a matrix for the rotation part of this movement at time t
   * @param t  Time in beats
   * @return   Matrix for using with view
   */
  func rotate(_ t:CGFloat=CGFloat.greatestFiniteMagnitude) -> Matrix {
    let tt = min(max(0,t),beats)
    return brotate!.rotate(tt/beats)
  }
  
  /**
  * Return a new movement by changing the beats
  */
  func time(_ b:CGFloat) -> Movement {
    return Movement(fullbeats: b, hands: hands, cx1: cx1, cy1: cy1, cx2: cx2, cy2: cy2, x2: x2, y2: y2, cx3: cx3, cx4: cx4, cy4: cy4, x4: x4, y4: y4, beats: b)
  }
  
  /**
  * Return a new movement by changing the hands
  */
  func useHands(_ h:Hands) -> Movement {
    return Movement(fullbeats: fullbeats, hands: h, cx1: cx1, cy1: cy1, cx2: cx2, cy2: cy2, x2: x2, y2: y2, cx3: cx3, cx4: cx4, cy4: cy4, x4: x4, y4: y4, beats: beats)
  }
  
  /**
  * Return a new Movement scaled by x and y factors.
  * If y is negative hands are also switched.
  */
  func scale(_ x:CGFloat, _ y:CGFloat) -> Movement {
    return Movement(fullbeats: fullbeats, hands: y<0 && hands==Hands.righthand ? Hands.lefthand : y<0 && hands==Hands.lefthand ? Hands.righthand : hands, cx1: cx1*x, cy1: cy1*y, cx2: cx2*x, cy2: cy2*y, x2: x2*x, y2: y2*y, cx3: cx3*x, cx4: cx4*x, cy4: cy4*y, x4: x4*x, y4: y4*y, beats: beats)
  }
  
  /**
  * Return a new Movement with the end point shifted by x and y
  */
  func skew(_ x:CGFloat, _ y:CGFloat) -> Movement {
    return Movement(fullbeats: fullbeats, hands: hands, cx1: cx1, cy1: cy1, cx2: cx2+x, cy2: cy2+y, x2: x2+x, y2: y2+y, cx3: cx3, cx4: cx4, cy4: cy4, x4: x4, y4: y4, beats: beats)
  }
  
  func reflect() -> Movement { return scale(1,-1) }
  
  func clip(_ b:CGFloat) -> Movement {
    return Movement(fullbeats: fullbeats, hands: hands, cx1: cx1, cy1: cy1, cx2: cx2, cy2: cy2, x2: x2, y2: y2, cx3: cx3, cx4: cx4, cy4: cy4, x4: x4, y4: y4, beats: b)
  }
  
}




