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

class TouchAQuarter : Action {
  
  override var name:String { get { return "Touch a Quarter" } }
  
  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    if let d2 = ctx.dancerFacing(d) {
      return TamUtils.getMove("Extend Left").scale(CallContext.distance(d,d2)/2,1) + TamUtils.getMove("Hinge Right")
    } else {
      throw CallError("Dancer \(d.number) cannot Touch a Quarter") as Error
    }
  }
}
