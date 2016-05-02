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

class StartPracticeLayout: UIView {
  
  let genderControl = UISegmentedControl(items: ["Boy","Girl"])
  let primaryControl = UISegmentedControl(items: ["Left Finger","Right Finger"])
  let speedControl = UISegmentedControl(items: ["Slow","Moderate","Normal"])
  var selectAction:(String)->Void = { arg in }
  var selectedLabel:LevelView? = nil
  
  //  TODO extract and merge with same class from LevelLayout
  class LevelView : UIView {
    var label = UILabel()
    var data:LevelData
    var layout:StartPracticeLayout
    init(layout: StartPracticeLayout, level:String, font:UIFont, text:String="") {
      self.layout = layout
      data = LevelData.find(level)!
      super.init(frame:CGRect())
      label.text = text.length > 0 ? text : data.name
      label.font = font
      label.textAlignment = .Center
      addSubview(UIView())
      addSubview(label)
      addSubview(UIView())
      backgroundColor = data.color
      visualConstraints("V:|[a][b][c(==a)]|", fillHorizontal: true)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {  }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {  }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {  }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
      backgroundColor = UIColor.blueColor()
      label.textColor = UIColor.whiteColor()
      layout.selectAction(label.text ?? "")
      layout.selectedLabel = self
    }
    func unselect() {
      backgroundColor = data.color
      label.textColor = UIColor.blackColor()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame:frame)
    
    //  Build left side panel with a few settings
    let settingsPanel = UIView()
    settingsPanel.backgroundColor = UIColor.whiteColor()
    let levelPanel = UIView()
    levelPanel.backgroundColor = UIColor.grayColor()
    let genderLabel = UILabel()
    genderLabel.text = "Choose a Gender"
    settingsPanel.addSubview(genderLabel)
    settingsPanel.addSubview(genderControl)
    let primaryLabel = UILabel()
    primaryLabel.text = "Primary Control"
    settingsPanel.addSubview(primaryLabel)
    settingsPanel.addSubview(primaryControl)
    let speedLabel = UILabel()
    speedLabel.text = "Speed for Practice"
    settingsPanel.addSubview(speedLabel)
    settingsPanel.addSubview(speedControl)
    settingsPanel.visualConstraints("V:|-[a][b]-[c][d]-[e][f] |-[a] |-[b] |-[c] |-[d] |-[e] |-[f]")
    
    //  Build right side panel with buttons for Tutorial and all the levels
    let font = UIFont(name:"Helvetica Bold", size: frame.size.height/30)!
    levelPanel.addSubview(LevelView(layout:self, level:"all", font:font, text:"Tutorial"))
    let row1 = UIView()
    row1.addSubview(LevelView(layout:self, level:"b1", font:font))
    row1.addSubview(LevelView(layout:self, level:"b2", font:font))
    row1.visualConstraints("|[a]-[b(==a)]|", fillVertical: true, spacing: 1)
    levelPanel.addSubview(row1)
    let row2 = UIView()
    row2.addSubview(LevelView(layout:self, level:"ms", font:font))
    row2.addSubview(LevelView(layout:self, level: "plus", font: font))
    row2.visualConstraints("|[a]-[b(==a)]|", fillVertical: true, spacing: 1)
    levelPanel.addSubview(row2)
    let row3 = UIView()
    row3.addSubview(LevelView(layout:self, level: "a1", font: font))
    row3.addSubview(LevelView(layout:self, level: "a2", font: font))
    row3.visualConstraints("|[a]-[b(==a)]|", fillVertical: true, spacing: 1)
    levelPanel.addSubview(row3)
    let row4 = UIView()
    row4.addSubview(LevelView(layout:self, level: "c1", font: font))
    row4.addSubview(LevelView(layout:self, level: "c2", font: font))
    row4.visualConstraints("|[a]-[b(==a)]|", fillVertical: true, spacing: 1)
    levelPanel.addSubview(row4)
    let row5 = UIView()
    row5.addSubview(LevelView(layout:self, level: "c3a", font: font))
    row5.addSubview(LevelView(layout:self, level: "c3b", font: font))
    row5.visualConstraints("|[a]-[b(==a)]|", fillVertical: true, spacing: 1)
    levelPanel.addSubview(row5)
    levelPanel.visualConstraints("V:|[a]-[b(==a)]-[c(==a)]-[d(==a)]-[e(==a)]-[f(==a)]|", fillHorizontal: true, spacing: 1)
    
    //  Put it together
    addSubview(settingsPanel)
    addSubview(levelPanel)
    visualConstraints("|[a]-[b(==a)]|", fillVertical: true, spacing: 1)
  }
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  func unselect() {
    if let label = selectedLabel {
      label.unselect()
    }
  }
  
}