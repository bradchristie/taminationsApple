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

class LevelLayoutBase : UIView {

  var labelheight:CGFloat = 0
  var labelwidth:CGFloat = 0
  var leftmargin:CGFloat = 0
  var selectedLabel:LevelView? = nil
  var top:CGFloat = 0

  class LevelView : UIView {
    
    var label:UILabel
    var layout:LevelLayoutBase
    var color:UIColor
    
    init(_ layout:LevelLayoutBase, _ text:String, top:CGFloat, height:CGFloat, indent:CGFloat, color: UIColor) {
      self.layout = layout
      self.color = color
      //  Add a text view
      label = UILabel(frame: CGRect(x: layout.leftmargin/2,y: 0,width: layout.labelwidth-indent-layout.leftmargin/2,height: layout.labelheight))
      //  This is the background view
      super.init(frame:CGRect(x: indent, y: top, width: layout.labelwidth-indent, height: height+1))
      isUserInteractionEnabled = true
      backgroundColor = color
      layer.borderWidth = 1
      layer.borderColor = UIColor.black.cgColor
      label.text = text
      label.font = UIFont(name:"Helvetica Bold", size: layout.frame.size.height/40)
      addSubview(label)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {  }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {  }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {  }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      Callouts.LevelButtonAction(label.text ?? "")
    }
    func select() {
      backgroundColor = UIColor.blue
      label.textColor = UIColor.white
      layout.selectedLabel = self
    }
    func unselect() {
      backgroundColor = color
      label.textColor = UIColor.black
    }
    
  }
  
  override init(frame: CGRect) {
    labelheight = frame.size.height / 16
    labelwidth = frame.size.width
    leftmargin = labelwidth/10
    super.init(frame: frame)
  }
  
  func addStandardButtons(_ rowOffset:Int) {
    let indexcolor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1)
    addSubview(LevelView(self,"Practice", top: top+labelheight*CGFloat(rowOffset), height: labelheight, indent: 0, color: indexcolor))
    addSubview(LevelView(self,"Sequencer", top: top+labelheight*CGFloat(rowOffset), height: labelheight, indent: labelwidth/2, color: indexcolor))
    addSubview(LevelView(self,"About", top: top+labelheight*CGFloat(rowOffset+1), height: labelheight, indent: 0, color: indexcolor))
    addSubview(LevelView(self,"Settings", top: top+labelheight*CGFloat(rowOffset+1), height: labelheight, indent: labelwidth/2, color: indexcolor))
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  func selectLevel(_ level:String) {
    if let data = LevelData.find(level) {
      for v in subviews {
        if let levelView = v as? LevelView {
          if levelView.label.text! == data.name {
            unselect()
            levelView.select()
            selectedLabel = levelView
          }
        }
      }
    }
  }
  
  func unselect(isLandscape:Bool = false) {
    if let label = selectedLabel {
      if (!isLandscape || label.label.text!.matches("(Practice|Sequencer)")) {
        label.unselect()
      }
    }
  }
  
  
}
