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

class StartPracticeControl {
   
  weak var layout:StartPracticeLayout!
  
  func reset(_ lay:StartPracticeLayout) {
    layout = lay
    //  Set the switches to the current saved values
    let settings = UserDefaults.standard
    layout.genderControl.selectedSegmentIndex = settings.integer(forKey: "practicegender")
    layout.primaryControl.selectedSegmentIndex = settings.integer(forKey: "primarycontroller")
    switch settings.integer(forKey: "practicespeed") {
    case Speed.slow.rawValue :
      layout.speedControl.selectedSegmentIndex = 0
    case Speed.normal.rawValue :
      layout.speedControl.selectedSegmentIndex = 2
    default :
      layout.speedControl.selectedSegmentIndex = 1
    }
    
    //  Hook up controllers
    layout.genderControl.addTarget(self, action: #selector(StartPracticeControl.genderSelector), for: .valueChanged)
    layout.primaryControl.addTarget(self, action: #selector(StartPracticeControl.primarySelector), for: .valueChanged)
    layout.speedControl.addTarget(self, action: #selector(StartPracticeControl.speedSelector), for: .valueChanged)

    //  Make sure they have a value
    genderSelector()
    primarySelector()
    speedSelector()
    
  }
  
  @objc func genderSelector() {
    UserDefaults.standard.set(layout.genderControl.selectedSegmentIndex==1 ? 1 : 0, forKey: "practicegender")
  }
  @objc func primarySelector() {
    UserDefaults.standard.set(layout.primaryControl.selectedSegmentIndex, forKey: "primarycontroller")
  }
  @objc func speedSelector() {
      let s:Speed
      switch layout.speedControl.selectedSegmentIndex {
      case 2 : s = .normal
      case 0 : s = . slow
      default : s = .moderate
      }
      UserDefaults.standard.set(s.rawValue, forKey: "practicespeed")
  }

}
