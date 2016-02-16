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

class LevelLayout: UIView {

  var labelheight:CGFloat = 0
  var labelwidth:CGFloat = 0
  var leftmargin:CGFloat = 0
  
  var selectAction:(String)->Void = { arg in }
  var selectedLabel:LevelView? = nil
  
  class LevelView : UIView {

    var label:UILabel
    var layout:LevelLayout
    var color:UIColor
    
    init(_ layout:LevelLayout, _ text:String, top:CGFloat, height:CGFloat, indent:CGFloat, color: UIColor /* , selectAction:(String)->Void  */ ) {
      self.layout = layout
      self.color = color
      //  Add a text view
      label = UILabel(frame: CGRectMake(layout.leftmargin/2,0,layout.labelwidth-indent-layout.leftmargin/2,layout.labelheight))
      //  This is the background view
      super.init(frame:CGRectMake(indent, top, layout.labelwidth-indent, height+1))
      userInteractionEnabled = true
      backgroundColor = color
      layer.borderWidth = 1
      layer.borderColor = UIColor.blackColor().CGColor
      label.text = text
      label.font = UIFont(name:"Helvetica Bold", size: layout.frame.size.height/40)
      addSubview(label)
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
      backgroundColor = color
      label.textColor = UIColor.blackColor()
    }
    
  }
  
  override init(frame: CGRect) {
    labelheight = frame.size.height / 16
    labelwidth = frame.size.width
    leftmargin = labelwidth/10
    super.init(frame:frame)
    let top = frame.origin.y
    
    let bmscolor = UIColor(red: 0.75, green: 0.75, blue: 1, alpha: 1)
    let basiccolor = UIColor(red: 0.875, green: 0.875, blue: 1, alpha: 1)
    let pluscolor = UIColor(red: 0.75, green: 1, blue: 0.75, alpha: 1)
    let advcolor = UIColor(red: 1, green: 0.875, blue: 0.5, alpha: 1)
    let a1color = UIColor(red: 1, green: 0.9375, blue: 0.75, alpha: 1)
    let challengecolor = UIColor(red: 1, green: 0.75, blue: 0.75, alpha: 1)
    let c1color = UIColor(red: 1, green: 0.875, blue: 0.875, alpha: 1)
    let indexcolor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1)
    
    addSubview(LevelView(self,"Basic and Mainstream", top: top, height: labelheight*4, indent: 0, color: bmscolor))
    addSubview(LevelView(self,"Basic 1", top: top+labelheight, height: labelheight, indent: leftmargin, color: basiccolor))
    addSubview(LevelView(self,"Basic 2", top: top+labelheight*2, height: labelheight, indent: leftmargin, color: basiccolor))
    addSubview(LevelView(self,"Mainstream", top: top+labelheight*3, height: labelheight, indent: leftmargin, color: basiccolor))
    addSubview(LevelView(self,"Plus", top: top+labelheight*4, height: labelheight, indent: 0, color: pluscolor))
    addSubview(LevelView(self,"Advanced", top: top+labelheight*5, height: labelheight*3, indent: 0, color: advcolor))
    addSubview(LevelView(self,"A-1", top: top+labelheight*6, height: labelheight, indent: leftmargin, color: a1color))
    addSubview(LevelView(self,"A-2", top: top+labelheight*7, height: labelheight, indent: leftmargin, color: a1color))
    addSubview(LevelView(self,"Challenge", top: top+labelheight*8, height: labelheight*5, indent: 0, color: challengecolor))
    addSubview(LevelView(self,"C-1", top: top+labelheight*9, height: labelheight, indent: leftmargin, color: c1color))
    addSubview(LevelView(self,"C-2", top: top+labelheight*10, height: labelheight, indent: leftmargin, color: c1color))
    addSubview(LevelView(self,"C-3A", top: top+labelheight*11, height: labelheight, indent: leftmargin, color: c1color))
    addSubview(LevelView(self,"C-3B", top: top+labelheight*12, height: labelheight, indent: leftmargin, color: c1color))
    addSubview(LevelView(self,"Index of All Calls", top: top+labelheight*13, height: labelheight, indent: 0, color: indexcolor))
    addSubview(LevelView(self,"Practice", top: top+labelheight*14, height: labelheight, indent: 0, color: indexcolor))
    addSubview(LevelView(self,"Sequencer", top: top+labelheight*14, height: labelheight, indent: labelwidth/2, color: indexcolor))
    addSubview(LevelView(self,"About", top: top+labelheight*15, height: labelheight, indent: 0, color: indexcolor))
    addSubview(LevelView(self,"Settings", top: top+labelheight*15, height: labelheight, indent: labelwidth/2, color: indexcolor))
  }

  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  func unselect(isLandscape isLandscape:Bool = false) {
    if let label = selectedLabel {
      if (!isLandscape || label.label.text!.matches("(Practice|Sequencer)")) {
        label.unselect()
      }
    }
  }
  
}

