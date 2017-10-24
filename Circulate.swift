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

class Circulate : Action {
  
  override var name:String { get { return "Circulate" } }
  
  override func perform(_ ctx: CallContext, index: Int) throws {
    //  If just 4 dancers, try Box Circulate
    if (ctx.actives.count == 4) {
      if (ctx.actives.every { d in d.data.center } ) {
        do {
          try ctx.applyCalls("box circulate")
        } catch is CallError {
          //  That didn't work, try to find a circulate path for each dancer
          try super.perform(ctx,index: index)
        }
      }
      else {
        try super.perform(ctx,index:index)
      }
    }
      //  If two-faced lines, do Couples Circulate
    else if (ctx.isTwoFacedLines()) {
      try ctx.applyCalls("couples circulate")
    }
    //  If in waves or lines, then do All 8 Circulate
    else if (ctx.isLines()) {
      try ctx.applyCalls("all 8 circulate")
    }
    else if (ctx.isColumns()) {
      try ctx.applyCalls("column circulate")
    }
    else {
      throw CallError("Cannot figure out how to circulate")
    }
  }
  
  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    if (d.data.leader) {
      //  Find another active dancer in the same line and move to that spot
      if let d2 = ctx.dancerClosest(d, { dx in dx.data.active && (CallContext.isRight(d)(dx) || CallContext.isLeft(d)(dx)) } ) {
        let dist = CallContext.distance(d,d2)
        return TamUtils.getMove(CallContext.isRight(d)(d2) ? "Run Right" : "Run Left").scale(dist/3,dist/2).changebeats(4.0)
      }
    } else if (d.data.trailer) {
      //  Looking at active leader?  Then take its place
      //  TODO maybe allow diagonal circulate?
      if let d2 = ctx.dancerInFront(d) {
        if (d2.data.active) {
          let dist = CallContext.distance(d,d2)
          return TamUtils.getMove("Forward").scale(dist,1.0).changebeats(4.0)
        }
      }
    }
    throw CallError("Cannot figure out how to Circulate.")
  }
  
  
}
