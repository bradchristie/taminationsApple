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

class Spread : Action {
  
  override var name:String { get { return "and Spread" } }
  
  /*
   * 1. If only some of the dancers are directed to Spread (e.g., from a
   * static square, Heads Star Thru & Spread), they slide apart sideways to
   * become ends, as the inactive dancers step forward between them.
   *
   * 2. If the (Anything) call finishes in lines or waves (e.g., Follow Your Neighbor),
   * the centers anticipate the Spread action by sliding apart sideways to
   * become the new ends, while the original ends anticipate the Spread action
   * by moving into the nearest center position.
   *
   * 3. If the (Anything) call finishes in tandem couples
   *  (e.g., Wheel & Deal from a line of four), the lead dancers slide apart sideways,
   *  while the trailing dancers step forward between them.
   */
  
  override func performCall(_ ctx:CallContext, index:Int) throws {
  //  Is this spread from waves, tandem, actives?
    var spreader: Action?
    if (ctx.actives.count == ctx.dancers.count/2) {
      if (CallContext(source: ctx.actives).isLine) {
        spreader = Case2()  //  Case 2: Active dancers in line or wave spread among themselves
      } else {
        spreader = Case1()  //  Case 1: Active dancers spread and let in the others
      }
    } else if (ctx.isLines()) {
      spreader = Case2()  //  Case 2
    }
    else if (ctx.dancers.every { d in ctx.isInTandem(d) } ) {
      spreader = Case3()  // case 3
    }
    if (spreader != nil) {
      try spreader!.perform(ctx)
     }
    else {
      throw CallError("Can not figure out how to Spread")
    }
  }
  
  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    //  This is for waves only TODO tandem couples, single dancers (C-1)
    let v = Vector3D(x: 0, y: d.data.belle ? 2 : d.data.beau ? -2 : 0)
    let m = d.path.pop()
    let tx = m.rotate()
    let v2 = v.concatenate(tx)
    d.path.add(m.skew(v2.x,v2.y).useHands(Hands.nohands))
    return Path()   // empty path for return value
  }
}

class Case1 : Action {
  
  override func perform(_ ctx:CallContext, index:Int) throws {
    ctx.levelBeats()
    try ctx.dancers.forEach { d in
      if (d.data.active) {
        //  Active dancers spread apart
        var m:String
        if (ctx.dancersToRight(d).count == 0) {
          m = "Dodge Right"
        } else if (ctx.dancersToLeft(d).count == 0) {
          m = "Dodge Left"
        } else {
          throw CallError("Can not figure out how to Spread")
        }
        d.path.add(TamUtils.getMove(m).changebeats(2.0))
      } else {
        //  Inactive dancers move forward
        let d2 = ctx.dancerInFront(d)
        if (d2 != nil) {
          let dist = CallContext.distance(d,d2!)
          d.path.add(TamUtils.getMove("Forward").scale(dist,1.0).changebeats(2.0))
        }
      }
    }
  }
  
}

class Case2 : Action {
  
  override func performOne(_ d:Dancer,_ ctx:CallContext) throws -> Path {
    let p = d.path
    //  This is for waves only TODO tandem couples, single dancers (C-1)
    var v = Vector3D()
    if (d.data.belle) {
      v = Vector3D(x:0.0,y:2.0)
    } else if (d.data.beau) {
      v = Vector3D(x:0.0,y:-2.0)
    }
    let m = p.pop()
    let tx = m.rotate()
    v = v.concatenate(tx)
    p.add(m.skew(v.x,v.y).useHands(Hands.nohands))
    return Path()
  }
  
}

class Case3 : Case1 {
  
  override func perform(_ ctx:CallContext, index:Int) throws {
    //  Mark the leaders as active
    ctx.dancers.forEach { d in d.data.active = d.data.leader  }
    //  And forward to Case1, actives spread
    try super.perform(ctx,index:index)
  }
  
}

