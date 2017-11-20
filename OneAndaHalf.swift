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

class OneAndaHalf : CodedCall {
  
  override var name:String { get { return "Once and a Half" } }
  
  override func performCall(_ ctx: CallContext, index: Int) throws {
    //  At this point the call has already been done once
    //  So just do half of it again
    try ctx.applyCalls("half "+ctx.callstack.head.name)
  }
  
}
