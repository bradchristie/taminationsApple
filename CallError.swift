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

class CallError : Error {
  
  let msg:String
  init(_ msg:String) { self.msg = msg }
  
}

class FormationNotFoundError : CallError {
  
  override init(_ call:String) {
    super.init("No animation for \(call) from that formation")
  }
  
}

class CallNotFoundError : CallError {
  
  override init(_ call:String) {
    super.init("Call \(call) not found")
  }

}
