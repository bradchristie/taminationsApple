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
    switch callname.lowercased() {
    case "allemande left" : return AllemandeLeft()
    case "and roll" : return Roll()
    case "and spread" : return Spread()
    case "beaus" : return Beaus()
    case "belles" : return Belles()
    case "box counter rotate" : return BoxCounterRotate()
    case "box the gnat" : return BoxtheGnat()
    case "boys" : return Boys()
    case let c where c.matches("centers?") : return Centers(c)
    case "circulate" : return Circulate()
    case "cross run" : return CrossRun()
    case "ends" : return Ends()
    case "explode and" : return ExplodeAnd()
    case "face in" : return FaceIn()
    case "face left" : return FaceLeft()
    case "face out" : return FaceOut()
    case "face right" : return FaceRight()
    case "facing dancers" : return FacingDancers()
    case "girls" : return Girls()
    case "half" : return Half()
    case "half sashay" : return HalfSashay()
    case "heads" : return Heads()
    case "hinge" : return Hinge()
    case "leaders" : return Leaders()
    case "left touch a quarter" : return LeftTouchAQuarter()
    case "one and a half" : return OneAndaHalf()
    case "pass thru" : return PassThru()
    case let c where c.matches("quarter (in|out)") : return QuarterIn(c)
    case "quarter out" : return QuarterOut()
    case "run" : return Run()
    case "sides" : return Sides()
    case "slide thru" : return SlideThru()
    case "slip" : return Slip()
    case "star thru" : return StarThru()
    case "trailers" : return Trailers()
    case let c where c.matches("(left )?touch a quarter") : return TouchAQuarter(c)
    case "trade" : return Trade()
    case "turn back" : return TurnBack()
    case "turn thru" : return TurnThru()
    case "very centers" : return VeryCenters()
    case "wheel around" : return WheelAround()
    case let c where c.matches("z[ai]g") : return Zig(c)
    case let c where c.matches("z[ai]g z[ai]g") : return ZigZag(c)
    case "zoom" : return Zoom()
    default : return nil
    }
  }

  
}
