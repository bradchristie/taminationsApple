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

import UIKit

struct LevelData {
  
  let name:String
  let dir:String
  let selector:String
  let color:UIColor
  
  init(_ name:String, _ dir:String, _ selector:String, _ color:UIColor) {
    self.name = name
    self.dir = dir
    self.selector = selector
    self.color = color
  }
  
  static func find(s:String) -> LevelData? {
    let slower = s.lowercaseString
    return data.filter({ $0.name.lowercaseString==slower || $0.dir.lowercaseString==slower }).first
  }
  
  static let data = [LevelData("Basic and Mainstream","bms","level='Basic and Mainstream' and @sublevel!='Styling'",UIColor(red:0.88, green:0.88, blue:1.00, alpha:1.0)),
    LevelData("Basic 1","b1","sublevel='Basic 1'",UIColor(red:0.88, green:0.88, blue:1.00, alpha:1.0)),
    LevelData("Basic 2","b2","sublevel='Basic 2'",UIColor(red:0.88, green:0.88, blue:1.00, alpha:1.0)),
    LevelData("Mainstream","ms","sublevel='Mainstream'",UIColor(red:0.88, green:0.88, blue:1.00, alpha:1.0)),
    LevelData("Plus","plus","level='Plus'",UIColor(red:0.75, green:1.00, blue:0.75, alpha:1.0)),
    LevelData("Advanced","adv","level='Advanced'",UIColor(red:1.00, green:0.88, blue:0.50, alpha:1.0)),
    LevelData("A-1","a1","sublevel='A-1'",UIColor(red:1.00, green:0.94, blue:0.75, alpha:1.0)),
    LevelData("A-2","a2","sublevel='A-2'",UIColor(red:1.00, green:0.94, blue:0.75, alpha:1.0)),
    LevelData("Challenge","cha","level='Challenge'",UIColor(red:1.00, green:0.75, blue:0.75, alpha:1.0)),
    LevelData("C-1","c1","sublevel='C-1'",UIColor(red:1.00, green:0.88, blue:0.88, alpha:1.0)),
    LevelData("C-2","c2","sublevel='C-2'",UIColor(red:1.00, green:0.88, blue:0.88, alpha:1.0)),
    LevelData("C-3A","c3a","sublevel='C-3A'",UIColor(red:1.00, green:0.88, blue:0.88, alpha:1.0)),
    LevelData("C-3B","c3b","sublevel='C-3B'",UIColor(red:1.00, green:0.88, blue:0.88, alpha:1.0)),
    LevelData("All Calls","all","level!='Info' and @sublevel!='Styling'",UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.0)),
    LevelData("Index of All Calls","all","level!='Info' and @sublevel!='Styling'",UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.0)) ]
  
}