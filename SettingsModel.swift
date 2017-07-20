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

protocol SettingsListener : NSObjectProtocol {
  func settingsChanged() -> Void
}

class SettingsModel : NSObject {

  weak var settingsListener:SettingsListener?
  
  weak var view:SettingsView!
  
  func reset(_ lay:SettingsView) {
    view = lay
    //  Set the switches to the current saved values
    let settings = UserDefaults.standard
    view.loopControl.isOn = settings.bool(forKey: "loop")
    view.gridControl.isOn = settings.bool(forKey: "grid")
    view.pathControl.isOn = settings.bool(forKey: "path")
    view.phantomsControl.isOn = settings.bool(forKey: "phantoms")
    switch settings.integer(forKey: "speed") {
    case 2 :
      view.speedControl.selectedSegmentIndex = 2
      view.speedHint.text = "Dancers move at a Fast pace"
    case 1 :
      view.speedControl.selectedSegmentIndex = 0
      view.speedHint.text = "Dancers move at a Slow pace"
    default :
      view.speedControl.selectedSegmentIndex = 1
      view.speedHint.text = "Dancers move at a Normal pace"
    }
    switch settings.integer(forKey: "numbers") {
    case 2 :
      view.numbersControl.selectedSegmentIndex = 2
      view.numbersHint.text = "Number couples 1-4"
    case 1 :
      view.numbersControl.selectedSegmentIndex = 1
      view.numbersHint.text = "Number dancers 1-8"
    default :
      view.numbersControl.selectedSegmentIndex = 0
      view.numbersHint.text = "Dancers not numbered"
    }
    switch settings.integer(forKey: "geometry") {
    case GeometryType.bigon.rawValue :
      view.geometryControl.selectedSegmentIndex = 2
    case GeometryType.hexagon.rawValue :
      view.geometryControl.selectedSegmentIndex = 1
    default :
      view.geometryControl.selectedSegmentIndex = 0
    }
    
    //  Hook up controllers
    view.speedControl.addTarget(self, action: #selector(SettingsModel.speedSelector), for: .valueChanged)
    view.loopControl.addTarget(self, action: #selector(SettingsModel.loopSelector), for: .valueChanged)
    view.gridControl.addTarget(self, action: #selector(SettingsModel.gridSelector), for: .valueChanged)
    view.pathControl.addTarget(self, action: #selector(SettingsModel.pathSelector), for: .valueChanged)
    view.numbersControl.addTarget(self, action: #selector(SettingsModel.numbersSelector), for: .valueChanged)
    view.phantomsControl.addTarget(self, action: #selector(SettingsModel.phantomsSelector), for: .valueChanged)
    view.geometryControl.addTarget(self, action: #selector(SettingsModel.geometrySelector), for: .valueChanged)
    
  }
  
  

  @objc func speedSelector() {
    let s:Speed
    switch view.speedControl.selectedSegmentIndex {
    case 2 : s = .fast; view.speedHint.text = "Dancers move at a Fast pace"
    case 0 : s = . slow; view.speedHint.text = "Dancers move at a Slow pace"
    default : s = .normal; view.speedHint.text = "Dancers move at a Normal pace"
    }
    UserDefaults.standard.set(s.rawValue, forKey: "speed")
    settingsListener?.settingsChanged()
  }
  @objc func loopSelector() {
    UserDefaults.standard.set(view.loopControl.isOn, forKey: "loop")
    settingsListener?.settingsChanged()
  }
  @objc func gridSelector() {
    UserDefaults.standard.set(view.gridControl.isOn, forKey: "grid")
    settingsListener?.settingsChanged()
  }
  @objc func pathSelector() {
    UserDefaults.standard.set(view.pathControl.isOn, forKey: "path")
    settingsListener?.settingsChanged()
  }
  @objc func numbersSelector() {
    UserDefaults.standard.set(view.numbersControl.selectedSegmentIndex, forKey: "numbers")
    switch view.numbersControl.selectedSegmentIndex {
    case 1: view.numbersHint.text = "Number dancers 1-8"
    case 2: view.numbersHint.text = "Number couples 1-4"
    default: view.numbersHint.text = "Dancers not numbered"
    }
    settingsListener?.settingsChanged()
  }
  @objc func phantomsSelector() {
    UserDefaults.standard.set(view.phantomsControl.isOn, forKey: "phantoms")
    settingsListener?.settingsChanged()
  }
  @objc func geometrySelector() {
    let g:GeometryType
    switch view.geometryControl.selectedSegmentIndex {
    case 2 : g = .bigon
    case 1 : g = .hexagon
    default : g = .square
    }
    UserDefaults.standard.set(g.rawValue, forKey: "geometry")
    settingsListener?.settingsChanged()
  }
  

}
