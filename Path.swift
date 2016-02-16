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

infix operator ++ { associativity left }
func ++(p1:Path,p2:Path) -> Path { return p1.add(p2) }

class Path {
  
  var movelist:[Movement] = []
  var transformlist:[Matrix] = []
  
  init() { }
  
  //  Create a path from a list of movements
  init(_ move:[Movement]) {
    movelist = [] + move
    recalculate()
  }
  
  //  Create a path from a single movement
  init(_ m:Movement) {
    movelist = [m]
    recalculate()
  }
  
  //  Create a path by copying another path
  init(_ p:Path) {
    movelist = [] + p.movelist
    recalculate()
  }
  
  func recalculate() {
    var tx = Matrix()
    transformlist = movelist.map {
      tx = tx.preConcat($0.translate()).preConcat($0.rotate())
      return Matrix(tx)
      }
  }
  
  func clear() {
    movelist = []
    transformlist = []
  }
  
  func add(p:Path) -> Path {
    movelist += p.movelist
    recalculate()
    return self
  }
  
  func add(m:Movement) -> Path {
    movelist.append(m)
    recalculate()
    return self
  }
  
  func pop() -> Movement {
    let m = movelist.removeLast()
    recalculate()
    return m
  }
  
  func reflect() {
    movelist = movelist.map{$0.reflect()}
  }
  
  var beats:CGFloat { get {
    return movelist.reduce(0.0, combine:{ $0 + $1.beats})
    } }
  
  func changebeats(newbeats:CGFloat) -> Path {
    let factor = newbeats / beats
    movelist = movelist.map { m in m.time(m.beats*factor) }
    return self
  }
  
  func changehands(hands:Hands) -> Path {
    movelist = movelist.map{$0.useHands(hands)}
    return self
  }
  
  func scale(x:CGFloat, _ y:CGFloat) -> Path {
    movelist = movelist.map{$0.scale(x,y)}
    recalculate()
    return self
  }
  
  func skew(x:CGFloat, _ y:CGFloat) -> Path {
    //  Apply the skew to just the last movement
    movelist.append(movelist.removeLast().skew(x,y))
    recalculate()
    return self
  }
  
  /**
  * Return a transform for a specific point of time
  */
  func animate(b:CGFloat) -> Matrix {
    var bv = b
    var tx = Matrix()
    //  Apply all completed movements
    var m:Movement? = nil
    movelist.indices.forEach { (i:Int) -> () in
      if (m == nil) {
        m = movelist[i]
        if (bv >= m!.beats) {
          tx = transformlist[i]
          bv = bv - m!.beats
          m = nil
        }
      }
    }
    //  Apply movement in progress
    if (m != nil) {
      tx = tx.preConcat(m!.translate(bv)).preConcat(m!.rotate(bv))
    }
    return tx
  }
  
  /**
  * Return the current hand at a specific point in time
  */
  func hands(b:CGFloat) -> Hands {
    if (b < 0 || b > beats) {
      return .BOTHHANDS
    }
    var bv = b
    return movelist.reduce(.BOTHHANDS) { (h:Hands,m:Movement) -> Hands in
      if (bv < 0) {
        return h
      }
      bv = bv - m.beats
      return m.hands
    }
  }
  
}
