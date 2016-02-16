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

class CrossRun : Action {
  
  override var name:String { get { return "Cross Run" } }
  
  override func perform(ctx: CallContext, index: Int) throws {
    //  Centers and ends cannot both cross run
    if (ctx.dancers.exists { $0.data.active && $0.data.center } &&
        ctx.dancers.exists { $0.data.active && $0.data.center } ) {
      throw CallError("Centers and ends cannot both Cross Run")
    }
    //  We need to look at all the dancers, not just actives
    //  because partners of the runners need to dodge
    try ctx.dancers.forEach { d in
      if (d.data.active) {
        //  Must be in a 4-dancer wave or line
        if (!d.data.center && !d.data.end) {
          throw CallError("General line required for Cross Run")
        }
        //  Partner must be inactive
        if let d2 = d.data.partner {
          if (d2.data.active) {
            throw CallError("Dancer and partner cannot both Cross Run")
          }
          //  Center beaus and end belles run left
          let isright = d.data.beau ^ d.data.center
          //  TODO check for runners crossing paths
          let m = isright ? "Run Right" : "Run Left"
          d.path = TamUtils.getMove(m).scale(1,2)
        } else {
          throw CallError("Nobody to Cross Run around")
        }
      } else {
        //  Not an active dancer
        //  If partner is active then this dancer needs to dodge
        if let d2 = d.data.partner {
          if (d2.data.active) {
            d.path = TamUtils.getMove(d.data.beau ? "Dodge Right" : "Dodge Left")
          }
        }
      }
    }
  }
  
}