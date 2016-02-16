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


class SettingsLayout: UIScrollView {

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
    let speedPanel = UIView(frame:CGRectMake(0,0,frame.width,76))
    speedPanel.backgroundColor = UIColor.whiteColor()
    let speedLabel = UILabel(frame:CGRectMake(20,0,frame.width,20))
    speedLabel.text = "Dancer Speed"
    speedLabel.font = UIFont.systemFontOfSize(17)
    speedControl = UISegmentedControl(frame:CGRectMake(20, 26, 280, 30))
    speedControl.insertSegmentWithTitle("Slow", atIndex: 0, animated: false)
    speedControl.insertSegmentWithTitle("Normal", atIndex: 1, animated: false)
    speedControl.insertSegmentWithTitle("Fast", atIndex: 2, animated: false)
    speedHint = UILabel(frame:CGRectMake(20,54,280,21))
    speedHint.text = "Dancers move at a Normal pace"
    speedHint.font = UIFont.systemFontOfSize(14)
    speedPanel.addSubview(speedLabel)
    speedPanel.addSubview(speedControl)
    speedPanel.addSubview(speedHint)
    
    let loopPanel = UIView(frame:CGRectMake(0,80,frame.width,68))
    loopPanel.backgroundColor = UIColor.whiteColor()
    let loopLabel = UILabel(frame:CGRectMake(20,2,96,21))
    loopLabel.text = "Loop"
    loopLabel.font = UIFont.systemFontOfSize(17)
    loopControl = UISwitch(frame:CGRectMake(223,8,0,0))
    let loopHint = UILabel(frame:CGRectMake(20,20,195,48))
    loopHint.text = "Repeat the animation continuously"
    loopHint.font = UIFont.systemFontOfSize(14)
    loopHint.numberOfLines = 0
    loopPanel.addSubview(loopLabel)
    loopPanel.addSubview(loopControl)
    loopPanel.addSubview(loopHint)
    
    let gridPanel = UIView(frame:CGRectMake(0,152,frame.width,44))
    gridPanel.backgroundColor = UIColor.whiteColor()
    let gridLabel = UILabel(frame:CGRectMake(20,2,96,21))
    gridLabel.text = "Grid"
    gridLabel.font = UIFont.systemFontOfSize(17)
    gridControl = UISwitch(frame:CGRectMake(223,0,0,0))
    let gridHint = UILabel(frame:CGRectMake(20,20,195,21))
    gridHint.text = "Show a dancer-sized grid"
    gridHint.font = UIFont.systemFontOfSize(14)
    gridPanel.addSubview(gridLabel)
    gridPanel.addSubview(gridControl)
    gridPanel.addSubview(gridHint)
    
    let pathPanel = UIView(frame:CGRectMake(0,200,frame.width,64))
    pathPanel.backgroundColor = UIColor.whiteColor()
    let pathLabel = UILabel(frame:CGRectMake(20,2,96,21))
    pathLabel.text = "Paths"
    pathLabel.font = UIFont.systemFontOfSize(17)
    pathControl = UISwitch(frame:CGRectMake(223,8,0,0))
    let pathHint = UILabel(frame:CGRectMake(20,20,195,48))
    pathHint.text = "Draw a line for each dancer's route"
    pathHint.font = UIFont.systemFontOfSize(14)
    pathHint.numberOfLines = 0
    pathPanel.addSubview(pathLabel)
    pathPanel.addSubview(pathControl)
    pathPanel.addSubview(pathHint)
    
    let numbersPanel = UIView(frame:CGRectMake(0,268,frame.width,76))
    numbersPanel.backgroundColor = UIColor.whiteColor()
    let numbersLabel = UILabel(frame:CGRectMake(20,0,frame.width,20))
    numbersLabel.text = "Numbers"
    numbersLabel.font = UIFont.systemFontOfSize(17)
    numbersControl = UISegmentedControl(frame:CGRectMake(20, 26, 280, 30))
    numbersControl.insertSegmentWithTitle("None", atIndex: 0, animated: false)
    numbersControl.insertSegmentWithTitle("Dancers", atIndex: 1, animated: false)
    numbersControl.insertSegmentWithTitle("Couples", atIndex: 2, animated: false)
    numbersHint = UILabel(frame:CGRectMake(20,54,280,21))
    numbersHint.text = "Dancers not numbered"
    numbersHint.font = UIFont.systemFontOfSize(14)
    numbersPanel.addSubview(numbersLabel)
    numbersPanel.addSubview(numbersControl)
    numbersPanel.addSubview(numbersHint)

    let phantomsPanel = UIView(frame:CGRectMake(0,348,frame.width,64))
    phantomsPanel.backgroundColor = UIColor.whiteColor()
    let phantomsLabel = UILabel(frame:CGRectMake(20,2,96,21))
    phantomsLabel.text = "Phantoms"
    phantomsLabel.font = UIFont.systemFontOfSize(17)
    phantomsControl = UISwitch(frame:CGRectMake(223,8,0,0))
    let phantomsHint = UILabel(frame:CGRectMake(20,20,195,48))
    phantomsHint.text = "Show phantom dancers where used for Challenge"
    phantomsHint.font = UIFont.systemFontOfSize(14)
    phantomsHint.numberOfLines = 0
    phantomsPanel.addSubview(phantomsLabel)
    phantomsPanel.addSubview(phantomsControl)
    phantomsPanel.addSubview(phantomsHint)
    
    let geometryPanel = UIView(frame:CGRectMake(0,416,frame.width,68))
    geometryPanel.backgroundColor = UIColor.whiteColor()
    let geometryLabel = UILabel(frame:CGRectMake(20,0,frame.width,20))
    geometryLabel.text = "Special Geometry"
    geometryLabel.font = UIFont.systemFontOfSize(17)
    geometryControl = UISegmentedControl(frame:CGRectMake(20, 26, 280, 30))
    geometryControl.insertSegmentWithTitle("None", atIndex: 0, animated: false)
    geometryControl.insertSegmentWithTitle("Hexagon", atIndex: 1, animated: false)
    geometryControl.insertSegmentWithTitle("Bi-Gon", atIndex: 2, animated: false)
    geometryPanel.addSubview(geometryLabel)
    geometryPanel.addSubview(geometryControl)
    
    super.init(frame:frame)
    backgroundColor = UIColor.grayColor()
    addSubview(speedPanel)
    addSubview(loopPanel)
    addSubview(gridPanel)
    addSubview(pathPanel)
    addSubview(numbersPanel)
    addSubview(phantomsPanel)
    addSubview(geometryPanel)
  }

  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
}



