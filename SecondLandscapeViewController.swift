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

class SecondLandscapeViewController: TamViewController {

  let level:String
  let link:String
  let call:String?
  let animListControl = AnimListControl()
  let animationControl = AnimationControl()
  let animationPanelControl = AnimationPanelControl()
  let definitionControl = DefinitionControl()
  let settingsControl = SettingsControl()
  
  var settingsAction:()->Void = { }
  var definitionAction:()->Void = { }
  var selectAnimation:(AnimListControl.AnimListData)->Void = { arg in }
  
  override init(_ intent:[String:String]) {
    level = intent["level"]!
    link = intent["link"]!
    call = intent["call"]
    super.init(intent)
  }
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func loadView() {
    //  Create frames for three panels
    var f = contentFrame
    f.size.width = f.size.width/3
    let panelbounds = f
    let leftframe = f
    f.origin.x = panelbounds.width
    let middleframe = f
    f.origin.x = panelbounds.width*2
    let rightframe = f
    
    //  Create the views for all the panels
    let topview = UIView(frame: contentFrame)
    let animListLayout = AnimListLayout(frame: leftframe)
    animListLayout.table.dataSource = animListControl
    animListLayout.table.delegate = animListControl
    animListControl.hideDifficulty = {
      animListLayout.hideDifficulty();
    }
    topview.addSubview(animListLayout)
    view = topview
    title = animListControl.title
    setLevelButton(level)
    
    let animationLayout = AnimationLayout(frame: middleframe)
    animationLayout.layer.borderWidth = 1
    animationLayout.layer.borderColor = UIColor.black.cgColor
    topview.addSubview(animationLayout)
    let background1 = BackgroundPanel(frame: middleframe)
    topview.addSubview(background1)
    
    let settingsLayout = SettingsLayout(frame:rightframe)
    settingsControl.reset(settingsLayout)
    topview.addSubview(settingsLayout)
    let definitionLayout = DefinitionLayout(frame:rightframe)
    topview.addSubview(definitionLayout)
    definitionControl.reset(definitionLayout, link: link)
    let background2 = BackgroundPanel(frame:rightframe)
    topview.addSubview(background2)
    var rightview:UIView = definitionLayout

    //  Hook up controls
    animListControl.selectAction = { (level:String,link:String,item:AnimListControl.AnimListData, animcount:Int)->Void in
      background1.animate(fromView: animationLayout, toView: animationLayout, callback: {
        self.selectAnimation(item)
      } )
    }
    
    animationLayout.settingsButton.addTarget(self, action: #selector(SecondLandscapeViewController.settingsSelector), for: .touchUpInside)
    settingsAction = {
      if rightview != settingsLayout {
        background2.animate(fromView: definitionLayout, toView: settingsLayout, callback: { } )
        rightview = settingsLayout
      }
    }
    animationLayout.definitionButton.addTarget(self, action: #selector(SecondLandscapeViewController.definitionSelector), for: .touchUpInside)
    definitionAction = {
      if rightview != definitionLayout {
        background2.animate(fromView: settingsLayout, toView: definitionLayout, callback: { } )
        rightview = definitionLayout
      }
    }
    settingsControl.settingsListener = {
      self.animationControl.readSettings(animationLayout.animationView)
    }
    animationControl.reset(animationLayout, animationLayout.animationView, link: link)
    animationLayout.animationView.partCallback = { (part:Int) in
      self.definitionControl.setPart(part)
    }

    animListControl.reset(link, level: level, call:call)
    title = animListControl.title

    selectAnimation = { item in
      self.animationControl.reset(animationLayout, animationLayout.animationView, link:self.link, animnum: item.xmlindex)
      self.title = item.title
      self.animationPanelControl.reset(animationLayout.animationPanel, view: animationLayout.animationView)
      self.definitionControl.setTitle(self.animListControl.animtitle)  // for definition highlighting
      self.setShareButton("http://www.tamtwirlers.org/tamination/"+self.link+".html?"+item.fullname)
    }
    if (animListControl.currentrow >= 0) {
      selectAnimation(animListControl.animlistdata[animListControl.currentrow])
    }
    
  }
  
  @objc func settingsSelector() {
    settingsAction()
  }
  @objc func definitionSelector() {
    definitionAction()
  }

  override func viewDidAppear(_ animated: Bool) {
    self.definitionControl.defstyleAction()
  }
  
}

