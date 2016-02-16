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

func ieeeRemainder(x:CGFloat,_ y:CGFloat) -> CGFloat {
  return x - round(x/y)*y
}

struct Handhold {
  
  let dancer1:Dancer
  let dancer2:Dancer
  let hold1:Hands
  let hold2:Hands
  let angle1:CGFloat
  let angle2:CGFloat
  let distance:CGFloat
  let score:CGFloat
  
  func inCenter() -> Bool {
    return dancer1.inCenter && dancer2.inCenter
  }
  
  static func apply(d1:Dancer, _ d2:Dancer, geometry:GeometryType) -> Handhold? {
    guard !d1.hidden && !d2.hidden else {
      return nil
    }
    //  Turn off grips if not specified in current movement
    if ((d1.hands & Hands.GRIPRIGHT) != Hands.GRIPRIGHT) {
      d1.rightgrip = nil
    }
    if ((d1.hands & Hands.GRIPLEFT) != Hands.GRIPLEFT) {
      d1.leftgrip = nil
    }
    if ((d2.hands & Hands.GRIPRIGHT) != Hands.GRIPRIGHT) {
      d2.rightgrip = nil
    }
    if ((d2.hands & Hands.GRIPLEFT) != Hands.GRIPLEFT) {
      d2.leftgrip = nil
    }

    //  Check distance
    let x1 = d1.tx.mat.tx
    let y1 = d1.tx.mat.ty
    let x2 = d2.tx.mat.tx
    let y2 = d2.tx.mat.ty
    let dx = x2 - x1
    let dy = y2 - y1
    let dfactor1:CGFloat = 0.1  // for distance up to 2.0
    let dfactor2:CGFloat = 2.0  // for distance past 2.0
    let cutover:CGFloat = geometry==GeometryType.HEXAGON ? 2.5 : geometry==GeometryType.BIGON ? 3.7 : 2.0
    let d = sqrt(dx*dx + dy*dy)
    let dfactor0:CGFloat = geometry==GeometryType.HEXAGON ? 1.15 : 1.0
    let d0 = d * dfactor0
    var score1 = d0 > cutover ? (d0-cutover)*dfactor2+2*dfactor1 : d0*dfactor1
    var score2 = score1
    //  Angle between dancers
    let a0 = atan2(dy,dx)
    //  Angle each dancer is facing
    let a1 = atan2(d1.tx.mat.b,d1.tx.mat.d)
    let a2 = atan2(d2.tx.mat.b,d2.tx.mat.d)
    //  For each dancer, try left and right hands
    var h1 = Hands.NOHANDS
    var h2 = Hands.NOHANDS
    var ah1:CGFloat = 0
    var ah2:CGFloat = 0
    let afactor1:CGFloat = 0.2
    let afactor2:CGFloat = geometry == GeometryType.BIGON ? 0.6 : 1.0
    
    //  Dancer 1
    var a = abs(ieeeRemainder(abs(a1-a0+CG_PI*3/2),CG_PI*2))
    var ascore = a > CG_PI/6 ? (a-CG_PI/6)*afactor2+CG_PI/6*afactor1 : a*afactor1
    if (score1+ascore < 1.0 && (d1.hands & Hands.RIGHTHAND) != Hands.NOHANDS && d1.rightgrip==nil || d1.rightgrip == d2) {
      score1 = d1.rightgrip == d2 ? 0 : score1 + ascore
      h1 = Hands.RIGHTHAND
      ah1 = a1 - a0 + CG_PI*3/2
    } else {
      a = abs(ieeeRemainder(abs(a1-a0+CG_PI/2),CG_PI*2))
      ascore = a > CG_PI/6 ? (a-CG_PI/6)*afactor2+CG_PI/6*afactor1 : a*afactor1
      if (score1+ascore < 1.0 && (d1.hands & Hands.LEFTHAND) != Hands.NOHANDS && d1.leftgrip==nil || d1.leftgrip==d2) {
        score1 = d1.leftgrip==d2 ? 0.0 : score1 + ascore
        h1 = Hands.LEFTHAND
        ah1 = a1 - a0 + CG_PI/2
      } else {
        score1 = 10.0
      }
    }
    
    //  Dancer 2
    a = abs(ieeeRemainder(abs(a2-a0+CG_PI/2),CG_PI*2))
    ascore = a > CG_PI/6 ? (a-CG_PI/6)*afactor2+CG_PI/6*afactor1 : a*afactor1
    if (score2+ascore < 1.0 && (d2.hands & Hands.RIGHTHAND) != Hands.NOHANDS && d2.rightgrip==nil || d2.rightgrip == d1) {
      score2 = d2.rightgrip == d1 ? 0 : score2 + ascore
      h2 = Hands.RIGHTHAND
      ah2 = a2 - a0 + CG_PI/2
    } else {
      a = abs(ieeeRemainder(abs(a2-a0+CG_PI*3/2),CG_PI*2))
      ascore = a > CG_PI/6 ? (a-CG_PI/6)*afactor2+CG_PI/6*afactor1 : a*afactor1
      if (score2+ascore < 1.0 && (d2.hands & Hands.LEFTHAND) != Hands.NOHANDS && d2.leftgrip==nil || d2.leftgrip==d1) {
        score2 = d2.leftgrip==d1 ? 0.0 : score2 + ascore
        h2 = Hands.LEFTHAND
        ah2 = a2 - a0 + CG_PI*3/2
      } else {
        score2 = 10.0
      }
    }
    
    //  Generate return value
    if (d1.rightgrip == d2 && d2.rightgrip == d1) {
      return Handhold(dancer1: d1, dancer2: d2, hold1: Hands.RIGHTHAND, hold2: Hands.RIGHTHAND, angle1: ah1, angle2: ah2, distance: d, score: 0)
    } else if (d1.rightgrip == d2 && d2.leftgrip == d1) {
      return Handhold(dancer1: d1, dancer2: d2, hold1: Hands.RIGHTHAND, hold2: Hands.LEFTHAND, angle1: ah1, angle2: ah2, distance: d, score: 0)
    } else if (d1.leftgrip == d2 && d2.rightgrip == d1) {
      return Handhold(dancer1: d1, dancer2: d2, hold1: Hands.LEFTHAND, hold2: Hands.RIGHTHAND, angle1: ah1, angle2: ah2, distance: d, score: 0)
    } else if (d1.leftgrip == d2 && d2.leftgrip == d1) {
      return Handhold(dancer1: d1, dancer2: d2, hold1: Hands.LEFTHAND, hold2: Hands.LEFTHAND, angle1: ah1, angle2: ah2, distance: d, score: 0)
    } else if (score1 > 1 || score2 > 1 || score1 + score2 > 1.2) {
      return nil
    }
    return Handhold(dancer1: d1, dancer2: d2, hold1: h1, hold2: h2, angle1: ah1, angle2: ah2, distance: d, score: score1+score2)
  }
  
}