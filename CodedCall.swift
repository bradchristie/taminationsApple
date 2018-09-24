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

class CodedCall : Call {
  
  static func getCodedCall(_ callname:String) -> CodedCall? {
    
    return When (callname.lowercased()) { Is, Like, Else in
      Is ("allemande left") { AllemandeLeft() }
      Is ("and roll") { Roll() }
      Is ("and spread") { Spread() }
      Is ("beaus") { Beaus() }
      Is ("belles") { Belles() }
      Is ("box counter rotate") { BoxCounterRotate() }
      Is ("box the gnat") { BoxtheGnat() }
      Is ("boys") { Boys() }
      Like ("centers?") { Centers($0) }
      Is ("circulate") { Circulate() }
      Is ("cross run") { CrossRun() }
      Is ("ends") { Ends() }
      Is ("explode and") { ExplodeAnd() }
      Is ("face in") { FaceIn() }
      Is ("face left") { FaceLeft() }
      Is ("face out") { FaceOut() }
      Is ("face right") { FaceRight() }
      Is ("facing dancers") { FacingDancers() }
      Is ("girls") { Girls() }
      Like ("^(half)|(1/2)$") { x in Half() }
      Is ("half sashay") { HalfSashay() }
      Is ("heads") { Heads() }
      Is ("hinge") { Hinge() }
      Is ("leaders") { Leaders() }
      Is ("left touch a quarter") { LeftTouchAQuarter() }
      Like ("(onc?e and a half)|(1 1/2)") { x in OneAndaHalf() }
      Is ("pass thru") { PassThru() }
      Like ("quarter (in|out)") { QuarterIn($0) }
      Is ("quarter out") { QuarterOut() }
      Is ("run") { Run() }
      Is ("sides") { Sides() }
      Is ("slide thru") {SlideThru() }
      Is ("slip") { Slip() }
      Is ("star thru") { StarThru() }
      Is ("trailers") { Trailers() }
      Like ("(left )?touch a quarter") { TouchAQuarter($0) }
      Is ("trade") { Trade() }
      Is ("turn back") { TurnBack() }
      Is ("turn thru") { TurnThru() }
      Is ("very centers") { VeryCenters() }
      Is ("wheel around") { WheelAround() }
      Like ("z[ai]g") { Zig($0) }
      Like ("z[ai]g z[ai]g") { ZigZag($0) }
      Is ("zoom") { Zoom() }
      Else (nil)
    }
  }

}
