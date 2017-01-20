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

import UIKit

struct LevelData {
  
  let name:String
  let dir:String
  let selector:String
  let doc:Ji
  let color:UIColor
  
  init(_ name:String, _ dir:String, _ selector:String, _ doc:Ji, _ color:UIColor) {
    self.name = name
    self.dir = dir
    self.selector = selector
    self.doc = doc
    self.color = color
  }
  
  static let tamdoc = TamUtils.getXMLAsset("src/calls.xml")
  static let indexdoc = TamUtils.getXMLAsset("src/callindex.xml")
  static let customCallList = UserDefaults.standard.string(forKey: "customCallList") ?? "<none>"
  
  static func find(_ s:String) -> LevelData? {
    let slower = s.lowercased()
    return data.filter({ $0.name.lowercased()==slower || $0.dir.lowercased()==slower }).first
  }
  
  static func findLevel(_ s:String) -> String {
    return data.filter({ $0.dir.lowercased() == s.lowercased() }).first!.name
  }
  
  static let data = [LevelData("Basic and Mainstream","bms","/calls/call[@level='Basic and Mainstream' and @sublevel!='Styling']",tamdoc,UIColor(red:0.88, green:0.88, blue:1.00, alpha:1.0)),
    LevelData("Basic 1","b1","/calls/call[@sublevel='Basic 1']",tamdoc,UIColor(red:0.88, green:0.88, blue:1.00, alpha:1.0)),
    LevelData("Basic 2","b2","/calls/call[@sublevel='Basic 2']",tamdoc,UIColor(red:0.88, green:0.88, blue:1.00, alpha:1.0)),
    LevelData("Mainstream","ms","/calls/call[@sublevel='Mainstream']",tamdoc,UIColor(red:0.88, green:0.88, blue:1.00, alpha:1.0)),
    LevelData("Plus","plus","/calls/call[@level='Plus']",tamdoc,UIColor(red:0.75, green:1.00, blue:0.75, alpha:1.0)),
    LevelData("Advanced","adv","/calls/call[@level='Advanced']",tamdoc,UIColor(red:1.00, green:0.88, blue:0.50, alpha:1.0)),
    LevelData("A-1","a1","/calls/call[@sublevel='A-1']",tamdoc,UIColor(red:1.00, green:0.94, blue:0.75, alpha:1.0)),
    LevelData("A-2","a2","/calls/call[@sublevel='A-2']",tamdoc,UIColor(red:1.00, green:0.94, blue:0.75, alpha:1.0)),
    LevelData("Challenge","cha","/calls/call[@level='Challenge']",tamdoc,UIColor(red:1.00, green:0.75, blue:0.75, alpha:1.0)),
    LevelData("C-1","c1","/calls/call[@sublevel='C-1']",tamdoc,UIColor(red:1.00, green:0.88, blue:0.88, alpha:1.0)),
    LevelData("C-2","c2","/calls/call[@sublevel='C-2']",tamdoc,UIColor(red:1.00, green:0.88, blue:0.88, alpha:1.0)),
    LevelData("C-3A","c3a","/calls/call[@sublevel='C-3A']",tamdoc,UIColor(red:1.00, green:0.88, blue:0.88, alpha:1.0)),
    LevelData("C-3B","c3b","/calls/call[@sublevel='C-3B']",tamdoc,UIColor(red:1.00, green:0.88, blue:0.88, alpha:1.0)),
    LevelData("All Calls","all","/calls/call",indexdoc,UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.0)),
    LevelData("Index of All Calls","all","/calls/call",indexdoc,UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.0)) ]
  
}
