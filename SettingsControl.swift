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

class SettingsControl {

  var settingsListener:()->Void = { }
  var speedAction:()->Void = { }
  var loopAction:()->Void = { }
  var gridAction:()->Void = { }
  var pathAction:()->Void = { }
  var numbersAction:()->Void = { }
  var phantomsAction:()->Void = { }
  var geometryAction:()->Void = { }
  
  func reset(layout:SettingsLayout) {
    //  Set the switches to the current saved values
    let settings = NSUserDefaults.standardUserDefaults()
    layout.loopControl.on = settings.boolForKey("loop")
    layout.gridControl.on = settings.boolForKey("grid")
    layout.pathControl.on = settings.boolForKey("path")
    switch settings.integerForKey("speed") {
    case 2 :
      layout.speedControl.selectedSegmentIndex = 2
      layout.speedHint.text = "Dancers move at a Fast pace"
    case 1 :
      layout.speedControl.selectedSegmentIndex = 0
      layout.speedHint.text = "Dancers move at a Slow pace"
    default :
      layout.speedControl.selectedSegmentIndex = 1
      layout.speedHint.text = "Dancers move at a Normal pace"
    }
    switch settings.integerForKey("numbers") {
    case 2 :
      layout.numbersControl.selectedSegmentIndex = 2
      layout.numbersHint.text = "Number couples 1-4"
    case 1 :
      layout.numbersControl.selectedSegmentIndex = 1
      layout.numbersHint.text = "Number dancers 1-8"
    default :
      layout.numbersControl.selectedSegmentIndex = 0
      layout.numbersHint.text = "Dancers not numbered"
    }
    switch settings.integerForKey("geometry") {
    case GeometryType.BIGON.rawValue :
      layout.geometryControl.selectedSegmentIndex = 2
    case GeometryType.HEXAGON.rawValue :
      layout.geometryControl.selectedSegmentIndex = 1
    default :
      layout.geometryControl.selectedSegmentIndex = 0
    }
    
    //  Hook up controllers
    layout.speedControl.addTarget(self, action: "speedSelector", forControlEvents: .ValueChanged)
    layout.loopControl.addTarget(self, action: "loopSelector", forControlEvents: .ValueChanged)
    layout.gridControl.addTarget(self, action: "gridSelector", forControlEvents: .ValueChanged)
    layout.pathControl.addTarget(self, action: "pathSelector", forControlEvents: .ValueChanged)
    layout.numbersControl.addTarget(self, action: "numbersSelector", forControlEvents: .ValueChanged)
    layout.phantomsControl.addTarget(self, action: "phantomsSelector", forControlEvents: .ValueChanged)
    layout.geometryControl.addTarget(self, action: "geometrySelector", forControlEvents: .ValueChanged)
    speedAction = {
      let s:Speed
      switch layout.speedControl.selectedSegmentIndex {
      case 2 : s = .FAST
      case 0 : s = . SLOW
      default : s = .NORMAL
      }
      NSUserDefaults.standardUserDefaults().setInteger(s.rawValue, forKey: "speed")      
      self.settingsListener()
    }
    loopAction = {
      NSUserDefaults.standardUserDefaults().setBool(layout.loopControl.on, forKey: "loop")
      self.settingsListener()
    }
    gridAction = {
      NSUserDefaults.standardUserDefaults().setBool(layout.gridControl.on, forKey: "grid")
      self.settingsListener()
    }
    pathAction = {
      NSUserDefaults.standardUserDefaults().setBool(layout.pathControl.on, forKey: "path")
      self.settingsListener()
    }
    numbersAction = {
      NSUserDefaults.standardUserDefaults().setInteger(layout.numbersControl.selectedSegmentIndex, forKey: "numbers")
      self.settingsListener()
    }
    phantomsAction = {
      NSUserDefaults.standardUserDefaults().setBool(layout.phantomsControl.on, forKey: "phantoms")
      self.settingsListener()
    }
    geometryAction = {
      let g:GeometryType
      switch layout.geometryControl.selectedSegmentIndex {
      case 2 : g = .BIGON
      case 1 : g = .HEXAGON
      default : g = .SQUARE
      }
      NSUserDefaults.standardUserDefaults().setInteger(g.rawValue, forKey: "geometry")
      self.settingsListener()
    }
  }
  
  @objc func speedSelector() {
    speedAction()
  }
  @objc func loopSelector() {
    loopAction()
  }
  @objc func gridSelector() {
    gridAction()
  }
  @objc func pathSelector() {
    pathAction()
  }
  @objc func numbersSelector() {
    numbersAction()
  }
  @objc func phantomsSelector() {
    phantomsAction()
  }
  @objc func geometrySelector() {
    geometryAction()
  }
  

}