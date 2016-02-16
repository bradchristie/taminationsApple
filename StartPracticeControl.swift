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

class StartPracticeControl {
 
  var genderAction:()->Void = { }
  var primaryAction:()->Void = { }
  var speedAction:()->Void = { }
  
  func reset(layout:StartPracticeLayout) {
    
    //  Set the switches to the current saved values
    let settings = NSUserDefaults.standardUserDefaults()
    switch settings.integerForKey("practicegender") {
    case Gender.GIRL.rawValue :
      layout.genderControl.selectedSegmentIndex = 1
    default :
      layout.genderControl.selectedSegmentIndex = 0
    }
    switch settings.integerForKey("primarycontroller") {
    case 0 :
      layout.primaryControl.selectedSegmentIndex = 0  // left
    default :
      layout.primaryControl.selectedSegmentIndex = 1  // right
    }
    switch settings.integerForKey("practicespeed") {
    case Speed.SLOW.rawValue :
      layout.speedControl.selectedSegmentIndex = Speed.SLOW.rawValue
    case Speed.NORMAL.rawValue :
      layout.speedControl.selectedSegmentIndex = Speed.NORMAL.rawValue
    default :
      layout.speedControl.selectedSegmentIndex = Speed.MODERATE.rawValue
    }
    
    //  Hook up controllers
    layout.genderControl.addTarget(self, action: "genderSelector", forControlEvents: .ValueChanged)
    layout.primaryControl.addTarget(self, action: "primarySelector", forControlEvents: .ValueChanged)
    layout.speedControl.addTarget(self, action: "speedSelector", forControlEvents: .ValueChanged)

    speedAction = {
      let s:Speed
      switch layout.speedControl.selectedSegmentIndex {
      case 2 : s = .NORMAL
      case 0 : s = . SLOW
      default : s = .MODERATE
      }
      NSUserDefaults.standardUserDefaults().setInteger(s.rawValue, forKey: "practicespeed")
    }
    
    genderAction = {
      NSUserDefaults.standardUserDefaults().setInteger(layout.genderControl.selectedSegmentIndex==Gender.GIRL.rawValue ? 1 : 0, forKey: "practicegender")
    }
    
    primaryAction = {
      NSUserDefaults.standardUserDefaults().setInteger(layout.primaryControl.selectedSegmentIndex, forKey: "primarycontroller")
    }
    //  Make sure they have a value
    genderAction()
    primaryAction()
    speedAction()
    
  }
  
  @objc func genderSelector() { genderAction() }
  @objc func primarySelector() { primaryAction() }
  @objc func speedSelector() { speedAction() }

}
