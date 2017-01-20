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

class SlideThru : Action {
  
  override var name:String { get { return "Slide Thru" } }
  
  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    if let d2 = ctx.dancerFacing(d) {
      let dist = CallContext.distance(d,d2)
      return TamUtils.getMove("Extend Left").scale(dist/2,0.5) +
        (d.gender == .boy ? TamUtils.getMove("Lead Right").scale(dist/2,0.5) : TamUtils.getMove("Quarter Left").scale(dist/2,-0.5))
    } else {
      throw CallError("Dancer \(d.number) has nobody to Slide Thru with") as Error
    }
  }
}
