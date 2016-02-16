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

class QuarterTurns : BoxCall {
  
  func select(ctx:CallContext, _ d:Dancer) -> String { return "" }
  
  override func performOne(d: Dancer, _ ctx: CallContext) throws -> Path {
    var offsetX:CGFloat = 0
    var offsetY:CGFloat = 0
    let move = select(ctx,d)
    if (move != "Stand" && !d.location.x.isApprox(0) && !d.location.y.isApprox(0)) {
      if (CallContext.isFacingIn(d)) {
        offsetX = 1
      } else if (CallContext.isFacingOut(d)) {
        offsetX = -1
      }
      if (d.data.beau) {
        offsetY = 1
      } else if (d.data.belle) {
        offsetY = -1
      }
    }
    return TamUtils.getMove(move).skew(offsetX, offsetY)
  }
  
}