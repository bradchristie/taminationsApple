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

class BoxtheGnat : Action {
  
  override var name:String { get { return "Box the Gnat" } }
  
  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    if let d2 = ctx.dancerFacing(d) {
      let dist = CallContext.distance(d,d2)
      let cy1:CGFloat = d.gender == .boy ? 1 : 0.1
      let y4:CGFloat = d.gender == .boy ? -2 : 2
      let hands = d.gender == .boy ? Hands.gripleft : Hands.gripright
      let m = Movement(fullbeats: 4.0, hands: hands, cx1: 1, cy1: cy1, cx2: dist/2, cy2: cy1, x2: dist/2+1, y2: 0, cx3: 1.3, cx4: 1.3, cy4: y4, x4: 0, y4: y4, beats: 4.0)
      return Path(m)
    } else {
      throw CallError("Cannot find dancer to turn with \(d.number)") as Error
    }
  }
}
