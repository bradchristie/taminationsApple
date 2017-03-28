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

class QuarterTurns : Action {
  
  func select(_ ctx:CallContext, _ d:Dancer) -> String { return "" }
  
  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    var offsetX:CGFloat = 0
    let move = select(ctx,d)
    //  If leader or trailer, make sure to adjust quarter turn
    //  so handhold is possible
    if (move != "Stand") {
      if (d.data.leader) {
        let d2 = ctx.dancerInBack(d)!
        let dist = CallContext.distance(d,d2)
        if (dist > 2) {
          offsetX = -(dist-2)/2
        }
      }
      if (d.data.trailer) {
        let d2 = ctx.dancerInFront(d)!
        let dist = CallContext.distance(d,d2)
        if (dist > 2) {
          offsetX = (dist-2)/2
        }
      }
    }
    return TamUtils.getMove(move).skew(offsetX, 0.0)
  }
  
}
