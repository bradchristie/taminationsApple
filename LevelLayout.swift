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

protocol LevelSelectionListener : NSObjectProtocol {
  func levelSelected(_ level:String) -> Void
}

class LevelLayout : UIView {

  var labelheight:CGFloat = 0
  var labelwidth:CGFloat = 0
  var leftmargin:CGFloat = 0
  var selectedLabel:LevelView? = nil
  var top:CGFloat = 0
  var viewIndex = [String:LevelView]()

  weak var levelSelectionListener:LevelSelectionListener?

  class LevelView : UIView {
    
    var label:UILabel
    var layout:LevelLayout
    var color:UIColor
    
    init(_ layout:LevelLayout, _ text:String, color: UIColor) {
      self.layout = layout
      self.color = color
      //  Add a text view
      label = UILabel()
      super.init(frame:layout.frame)
      //  This is the background view
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
      layout.levelSelectionListener?.levelSelected(label.text ?? "")
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
    
  }  // end of LevelView
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  override init(frame: CGRect) {
    labelheight = frame.size.height / 16
    labelwidth = frame.size.width
    leftmargin = labelwidth/10
    super.init(frame: frame)
    top = frame.origin.y
    
    let bmscolor = UIColor(red: 0.75, green: 0.75, blue: 1, alpha: 1)
    let basiccolor = UIColor(red: 0.875, green: 0.875, blue: 1, alpha: 1)
    let pluscolor = UIColor(red: 0.75, green: 1, blue: 0.75, alpha: 1)
    let advcolor = UIColor(red: 1, green: 0.875, blue: 0.5, alpha: 1)
    let a1color = UIColor(red: 1, green: 0.9375, blue: 0.75, alpha: 1)
    let challengecolor = UIColor(red: 1, green: 0.75, blue: 0.75, alpha: 1)
    let c1color = UIColor(red: 1, green: 0.875, blue: 0.875, alpha: 1)
    let indexcolor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1)
    
    //  Build Basic and Mainstream section
    let bms = addBigLevelView("Basic and Mainstream", color: bmscolor, to:self)
    addLevelView("Basic 1", color: basiccolor, to:bms)
    addLevelView("Basic 2", color: basiccolor, to:bms)
    addLevelView("Mainstream", color: basiccolor, to:bms)
    bms.visualConstraints("V:|[a][b(==a)][c(==a)][d(==a)]| |-\(leftmargin/2)-[a] |-\(leftmargin)-[b]| |-\(leftmargin)-[c]| |-\(leftmargin)-[d]|")
    
    //  Build Plus section
    addLevelView("Plus", color: pluscolor, to:self)
    
    //  Build Advanced section
    let adv = addBigLevelView("Advanced",color:advcolor,to:self)
    addLevelView("A-1",color:a1color,to:adv)
    addLevelView("A-2",color:a1color,to:adv)
    adv.visualConstraints("V:|[a][b(==a)][c(==a)]| |-\(leftmargin/2)-[a] |-\(leftmargin)-[b]| |-\(leftmargin)-[c]|")

    //  Build Challenge section
    let challenge = addBigLevelView("Challenge",color:challengecolor,to:self)
    addLevelView("C-1",color:c1color,to:challenge)
    addLevelView("C-2",color:c1color,to:challenge)
    addLevelView("C-3A",color:c1color,to:challenge)
    addLevelView("C-3B",color:c1color,to:challenge)
    challenge.visualConstraints("V:|[a][b(==a)][c(==a)][d(==a)][e(==a)]| |-\(leftmargin/2)-[a] |-\(leftmargin)-[b]| |-\(leftmargin)-[c]| |-\(leftmargin)-[d]| |-\(leftmargin)-[e]|")

    //  Build index section
    addLevelView("Index of All Calls", color: indexcolor, to:self)
    let index1 = UIView()
    addLevelView("Practice", color: indexcolor, to:index1)
    addLevelView("Sequencer", color: indexcolor, to:index1)
    index1.visualConstraints("|[a][b(==a)]|",fillVertical: true)
    addSubview(index1)
    let index2 = UIView()
    addLevelView("About", color: indexcolor, to:index2)
    addLevelView("Settings", color: indexcolor, to:index2)
    index2.visualConstraints("|[a][b(==a)]|",fillVertical: true)
    addSubview(index2)

    //  Set constraints for sections
    visualConstraints("V:|[a][b][c][d][e(==b)][f(==b)][g(==b)]|",fillHorizontal: true)
    //  BMS is 4x size of one line
    let con1 = NSLayoutConstraint(item: bms, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: index1, attribute: NSLayoutAttribute.height, multiplier: 4.0, constant: 0.0)
    addConstraint(con1)
    //  Adv is 3x size of one line
    let con2 = NSLayoutConstraint(item: adv, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: index1, attribute: NSLayoutAttribute.height, multiplier: 3.0, constant: 0.0)
    addConstraint(con2)
    //  Challenge is 5x size of one  line
    let con3 = NSLayoutConstraint(item: challenge, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: index1, attribute: NSLayoutAttribute.height, multiplier: 5.0, constant: 0.0)
    addConstraint(con3)
  }
  
  
  @discardableResult func addBigLevelView(_ name:String, color:UIColor, to:UIView) -> LevelView {
    let v = LevelView(self,name,color:color)
    viewIndex[name] = v
    to.addSubview(v)
    return v
  }
  @discardableResult func addLevelView(_ name:String, color:UIColor, to:UIView) -> LevelView {
    let v = addBigLevelView(name,color:color,to:to)
    v.visualConstraints("|-\(leftmargin/2)-[a]", fillVertical:true)
    return v
  }
  
  func selectLevel(_ level:String) {
    if let levelView = viewIndex[level] {
      unselect()
      levelView.select()
      selectedLabel = levelView
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
