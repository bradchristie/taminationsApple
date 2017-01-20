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

class WheelAround : Action {
  
  override var name:String { get { return "Wheel Around" } }
  
  override func performOne(_ d: Dancer, _ ctx: CallContext) throws -> Path {
    if let d2 = d.data.partner {
      if (!d2.data.active) {
        throw CallError("Dancer \(d.number) must Wheel Around with partner") as Error
      }
      if ((d.data.beau ^ d2.data.beau) && (d.data.belle ^ d2.data.belle)) {
        return TamUtils.getMove(d.data.beau ? "Beau Wheel" : "Belle Wheel")
      } else {
        throw CallError("Dancer \(d.number) is not part of a Facing Couple") as Error
      }
    } else {
      throw CallError("Dancer \(d.number) is not part of a Facing Couple") as Error
    }
  }
  
}
