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


class SettingsView: UIScrollView {

  let speedControl:UISegmentedControl
  let speedHint:UILabel
  let loopControl:UISwitch
  let gridControl:UISwitch
  let pathControl:UISwitch
  let numbersControl:UISegmentedControl
  let numbersHint:UILabel
  let phantomsControl:UISwitch
  let geometryControl:UISegmentedControl
  
  override init(frame: CGRect) {
    let speedPanel = UIView(frame:CGRect(x: 0,y: 0,width: frame.width,height: 76))
    speedPanel.backgroundColor = UIColor.white
    let speedLabel = UILabel(frame:CGRect(x: 20,y: 0,width: frame.width,height: 20))
    speedLabel.text = "Dancer Speed"
    speedLabel.font = UIFont.systemFont(ofSize: 17)
    speedControl = UISegmentedControl(frame:CGRect(x: 20, y: 26, width: 280, height: 30))
    speedControl.insertSegment(withTitle: "Slow", at: 0, animated: false)
    speedControl.insertSegment(withTitle: "Normal", at: 1, animated: false)
    speedControl.insertSegment(withTitle: "Fast", at: 2, animated: false)
    speedHint = UILabel(frame:CGRect(x: 20,y: 54,width: 280,height: 21))
    speedHint.text = "Dancers move at a Normal pace"
    speedHint.font = UIFont.systemFont(ofSize: 14)
    speedPanel.addSubview(speedLabel)
    speedPanel.addSubview(speedControl)
    speedPanel.addSubview(speedHint)
    
    let loopPanel = UIView(frame:CGRect(x: 0,y: 80,width: frame.width,height: 68))
    loopPanel.backgroundColor = UIColor.white
    let loopLabel = UILabel(frame:CGRect(x: 20,y: 2,width: 96,height: 21))
    loopLabel.text = "Loop"
    loopLabel.font = UIFont.systemFont(ofSize: 17)
    loopControl = UISwitch(frame:CGRect(x: 223,y: 8,width: 0,height: 0))
    let loopHint = UILabel(frame:CGRect(x: 20,y: 20,width: 195,height: 48))
    loopHint.text = "Repeat the animation continuously"
    loopHint.font = UIFont.systemFont(ofSize: 14)
    loopHint.numberOfLines = 0
    loopPanel.addSubview(loopLabel)
    loopPanel.addSubview(loopControl)
    loopPanel.addSubview(loopHint)
    
    let gridPanel = UIView(frame:CGRect(x: 0,y: 152,width: frame.width,height: 44))
    gridPanel.backgroundColor = UIColor.white
    let gridLabel = UILabel(frame:CGRect(x: 20,y: 2,width: 96,height: 21))
    gridLabel.text = "Grid"
    gridLabel.font = UIFont.systemFont(ofSize: 17)
    gridControl = UISwitch(frame:CGRect(x: 223,y: 0,width: 0,height: 0))
    let gridHint = UILabel(frame:CGRect(x: 20,y: 20,width: 195,height: 21))
    gridHint.text = "Show a dancer-sized grid"
    gridHint.font = UIFont.systemFont(ofSize: 14)
    gridPanel.addSubview(gridLabel)
    gridPanel.addSubview(gridControl)
    gridPanel.addSubview(gridHint)
    
    let pathPanel = UIView(frame:CGRect(x: 0,y: 200,width: frame.width,height: 64))
    pathPanel.backgroundColor = UIColor.white
    let pathLabel = UILabel(frame:CGRect(x: 20,y: 2,width: 96,height: 21))
    pathLabel.text = "Paths"
    pathLabel.font = UIFont.systemFont(ofSize: 17)
    pathControl = UISwitch(frame:CGRect(x: 223,y: 8,width: 0,height: 0))
    let pathHint = UILabel(frame:CGRect(x: 20,y: 20,width: 195,height: 48))
    pathHint.text = "Draw a line for each dancer's route"
    pathHint.font = UIFont.systemFont(ofSize: 14)
    pathHint.numberOfLines = 0
    pathPanel.addSubview(pathLabel)
    pathPanel.addSubview(pathControl)
    pathPanel.addSubview(pathHint)
    
    let numbersPanel = UIView(frame:CGRect(x: 0,y: 268,width: frame.width,height: 76))
    numbersPanel.backgroundColor = UIColor.white
    let numbersLabel = UILabel(frame:CGRect(x: 20,y: 0,width: frame.width,height: 20))
    numbersLabel.text = "Numbers"
    numbersLabel.font = UIFont.systemFont(ofSize: 17)
    numbersControl = UISegmentedControl(frame:CGRect(x: 20, y: 26, width: 280, height: 30))
    numbersControl.insertSegment(withTitle: "None", at: 0, animated: false)
    numbersControl.insertSegment(withTitle: "Dancers", at: 1, animated: false)
    numbersControl.insertSegment(withTitle: "Couples", at: 2, animated: false)
    numbersHint = UILabel(frame:CGRect(x: 20,y: 54,width: 280,height: 21))
    numbersHint.text = "Dancers not numbered"
    numbersHint.font = UIFont.systemFont(ofSize: 14)
    numbersPanel.addSubview(numbersLabel)
    numbersPanel.addSubview(numbersControl)
    numbersPanel.addSubview(numbersHint)

    let phantomsPanel = UIView(frame:CGRect(x: 0,y: 348,width: frame.width,height: 64))
    phantomsPanel.backgroundColor = UIColor.white
    let phantomsLabel = UILabel(frame:CGRect(x: 20,y: 2,width: 96,height: 21))
    phantomsLabel.text = "Phantoms"
    phantomsLabel.font = UIFont.systemFont(ofSize: 17)
    phantomsControl = UISwitch(frame:CGRect(x: 223,y: 8,width: 0,height: 0))
    let phantomsHint = UILabel(frame:CGRect(x: 20,y: 20,width: 195,height: 48))
    phantomsHint.text = "Show phantom dancers where used for Challenge"
    phantomsHint.font = UIFont.systemFont(ofSize: 14)
    phantomsHint.numberOfLines = 0
    phantomsPanel.addSubview(phantomsLabel)
    phantomsPanel.addSubview(phantomsControl)
    phantomsPanel.addSubview(phantomsHint)
    
    let geometryPanel = UIView(frame:CGRect(x: 0,y: 416,width: frame.width,height: 68))
    geometryPanel.backgroundColor = UIColor.white
    let geometryLabel = UILabel(frame:CGRect(x: 20,y: 0,width: frame.width,height: 20))
    geometryLabel.text = "Special Geometry"
    geometryLabel.font = UIFont.systemFont(ofSize: 17)
    geometryControl = UISegmentedControl(frame:CGRect(x: 20, y: 26, width: 280, height: 30))
    geometryControl.insertSegment(withTitle: "None", at: 0, animated: false)
    geometryControl.insertSegment(withTitle: "Hexagon", at: 1, animated: false)
    geometryControl.insertSegment(withTitle: "Bi-Gon", at: 2, animated: false)
    geometryPanel.addSubview(geometryLabel)
    geometryPanel.addSubview(geometryControl)
    
    super.init(frame:frame)
    backgroundColor = UIColor.gray
    addSubview(speedPanel)
    addSubview(loopPanel)
    addSubview(gridPanel)
    addSubview(pathPanel)
    addSubview(numbersPanel)
    addSubview(phantomsPanel)
    addSubview(geometryPanel)
    
    //  This is needed to enable scrolling on smaller devices (iPhone 4s)
    contentSize = CGSize(width: frame.width, height: geometryPanel.frame.origin.y + geometryPanel.bounds.height)
  }

  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
}



