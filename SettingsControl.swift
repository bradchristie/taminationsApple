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

class SettingsControl : NSObject {

  var settingsListener:()->Void = { }
  var speedAction:()->Void = { }
  var loopAction:()->Void = { }
  var gridAction:()->Void = { }
  var pathAction:()->Void = { }
  var numbersAction:()->Void = { }
  var phantomsAction:()->Void = { }
  var geometryAction:()->Void = { }
  
  func reset(_ layout:SettingsLayout) {
    //  Set the switches to the current saved values
    let settings = UserDefaults.standard
    layout.loopControl.isOn = settings.bool(forKey: "loop")
    layout.gridControl.isOn = settings.bool(forKey: "grid")
    layout.pathControl.isOn = settings.bool(forKey: "path")
    switch settings.integer(forKey: "speed") {
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
    switch settings.integer(forKey: "numbers") {
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
    switch settings.integer(forKey: "geometry") {
    case GeometryType.bigon.rawValue :
      layout.geometryControl.selectedSegmentIndex = 2
    case GeometryType.hexagon.rawValue :
      layout.geometryControl.selectedSegmentIndex = 1
    default :
      layout.geometryControl.selectedSegmentIndex = 0
    }
    
    //  Hook up controllers
    layout.speedControl.addTarget(self, action: #selector(SettingsControl.speedSelector), for: .valueChanged)
    layout.loopControl.addTarget(self, action: #selector(SettingsControl.loopSelector), for: .valueChanged)
    layout.gridControl.addTarget(self, action: #selector(SettingsControl.gridSelector), for: .valueChanged)
    layout.pathControl.addTarget(self, action: #selector(SettingsControl.pathSelector), for: .valueChanged)
    layout.numbersControl.addTarget(self, action: #selector(SettingsControl.numbersSelector), for: .valueChanged)
    layout.phantomsControl.addTarget(self, action: #selector(SettingsControl.phantomsSelector), for: .valueChanged)
    layout.geometryControl.addTarget(self, action: #selector(SettingsControl.geometrySelector), for: .valueChanged)
    speedAction = {
      let s:Speed
      switch layout.speedControl.selectedSegmentIndex {
      case 2 : s = .fast; layout.speedHint.text = "Dancers move at a Fast pace"
      case 0 : s = . slow; layout.speedHint.text = "Dancers move at a Slow pace"
      default : s = .normal; layout.speedHint.text = "Dancers move at a Normal pace"
      }
      UserDefaults.standard.set(s.rawValue, forKey: "speed")      
      self.settingsListener()
    }
    loopAction = {
      UserDefaults.standard.set(layout.loopControl.isOn, forKey: "loop")
      self.settingsListener()
    }
    gridAction = {
      UserDefaults.standard.set(layout.gridControl.isOn, forKey: "grid")
      self.settingsListener()
    }
    pathAction = {
      UserDefaults.standard.set(layout.pathControl.isOn, forKey: "path")
      self.settingsListener()
    }
    numbersAction = {
      UserDefaults.standard.set(layout.numbersControl.selectedSegmentIndex, forKey: "numbers")
      switch layout.numbersControl.selectedSegmentIndex {
      case 1: layout.numbersHint.text = "Number dancers 1-8"
      case 2: layout.numbersHint.text = "Number couples 1-4"
      default: layout.numbersHint.text = "Dancers not numbered"
      }
      self.settingsListener()
    }
    phantomsAction = {
      UserDefaults.standard.set(layout.phantomsControl.isOn, forKey: "phantoms")
      self.settingsListener()
    }
    geometryAction = {
      let g:GeometryType
      switch layout.geometryControl.selectedSegmentIndex {
      case 2 : g = .bigon
      case 1 : g = .hexagon
      default : g = .square
      }
      UserDefaults.standard.set(g.rawValue, forKey: "geometry")
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
