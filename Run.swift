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

class Run : Action {
  
  override var name:String { get { return "Run" } }
  
  override func perform(_ ctx: CallContext, index: Int) throws {
    //  We need to look at all the dancers, not just actives
    //  because partners of the runners need to dodge
    try ctx.dancers.forEach { d in
      if (d.data.active) {
        //  Partner must be inactive
        switch d.data.partner {
        case .some(let d2) where !d2.data.active:
          d.path.add(TamUtils.getMove(d.data.beau ? "Run Right" : "Run Left"))
        default:
          throw CallError("Dancer \(d.number) has nobody to Run around") as Error
        }
      } else {
        switch d.data.partner {
        case .some(let d2) where d2.data.active:
          d.path.add(TamUtils.getMove(d.data.beau ? "Dodge Right" : "Dodge Left"))
        default:
          break  // not involved
        }
      }
    }
  }
}
