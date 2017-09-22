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

class TipViewController : UIViewController {
  
  var panel:UIView!
  static var showed = false
  static let tips = [
    "You can move an animation manually by dragging the slider with your finger.",
    "Swipe an animation left or right to view the next or previous animation.",
    "Tap a dancer to display its path.",
    "Looking for a call but don't know the level? Go to the Index and enter a search.",
    "Tap the level at the upper right to jump back to the list of calls.",
    "The square dancers are boys, and the round dancers girls.  But most square " +
    "dance calls are not gender-specific.  So study all dancers in a call " +
    "to be proficient in all-position dancing."
  ]
  
  let showswitch = UISwitch()

  override func loadView() {
    panel = UIView()
    let topview = UIView()
    let bottomview = UIView()
    let middleview = UIView()
    let leftview = UIView()
    let rightview = UIView()
    panel.addSubview(topview)
    panel.addSubview(middleview)
    panel.addSubview(bottomview)
    middleview.addSubview(leftview)

    let tippanel = UIView()
    let titlepanel = UIView()
    titlepanel.backgroundColor = UIColor.green.darker()
    let titletext = UILabel()
    titletext.text = "Tip of the Day"
    titletext.textColor = UIColor.white
    titletext.textAlignment = .center
    titletext.font = UIFont.boldSystemFont(ofSize: 20)
    titletext.shadowColor = UIColor.black
    titletext.shadowOffset = CGSize(width: 1,height: 1)
    titlepanel.addSubview(titletext)
    titlepanel.visualConstraints("",fillHorizontal: true, fillVertical: true)
    
    let tiptext = UILabel();
    tiptext.numberOfLines = 0
    let days = Date.timeIntervalSinceReferenceDate / (60*60*24)
    tiptext.text = TipViewController.tips[Int(days) % TipViewController.tips.count]
    
    let lineview = UIView()
    lineview.backgroundColor = UIColor.gray
    let showpanel = UIView()
    let showtext = UILabel()
    showtext.text = "Show tips at startup"
    showtext.font = UIFont.systemFont(ofSize: 14)
    showpanel.addSubview(showtext)
    showpanel.addSubview(showswitch)
    showswitch.isOn = true
    showpanel.visualConstraints("|-[a]-[b]-|",fillVertical:true)
    let okpanel = UIView()
    let okleft = UIView()
    let okright = UIView()
    let ok = TamButton()
    okpanel.addSubview(okleft)
    okpanel.addSubview(ok)
    okpanel.addSubview(okright)
    okpanel.visualConstraints("|[a][b(==100)][c(==a)]|",fillVertical:true)
    tippanel.addSubview(titlepanel)
    tippanel.addSubview(tiptext)
    tippanel.addSubview(lineview)
    tippanel.addSubview(showpanel)
    tippanel.addSubview(okpanel)
    tippanel.visualConstraints("V:|[a]-[b]-[c(==4)]-[d]-[e]-| |[a]| |-[b]-| |[c]| |-[d]-| |[e]|")
    tippanel.backgroundColor = UIColor.white
    middleview.addSubview(tippanel)
    
    middleview.addSubview(rightview)
    let bgcolor = UIColor(white: 0.5, alpha: 0.5)
    panel.backgroundColor = bgcolor
    topview.backgroundColor = bgcolor
    bottomview.backgroundColor = bgcolor
    middleview.backgroundColor = bgcolor
    leftview.backgroundColor = UIColor.clear
    rightview.backgroundColor = UIColor.clear
    view = panel
    ok.setTitle("OK", for: .normal)
    ok.addTarget(self, action: #selector(TipViewController.dismissMe), for: .touchUpInside)
    let mybounds = UIScreen.main.bounds
    let istablet = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    let islandscape = mybounds.width > mybounds .height
    if (istablet && islandscape) {
      middleview.visualConstraints("|[a][b(==a)][c(==a)]|",fillVertical:true)
    } else {
      middleview.visualConstraints("|[a][b][c(==a)]|",fillVertical:true)
    }
    panel.visualConstraints("V:|[a][b][c(==a)]|",fillHorizontal: true)
    TipViewController.showed = true
  }
  
  @objc func dismissMe() {
    UserDefaults.standard.set(!showswitch.isOn, forKey: "hidetips")
    dismiss(animated: true)
  }
  
}
