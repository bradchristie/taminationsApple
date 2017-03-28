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

class SecondLandscapeViewController: TamViewController,
                                     AnimListSelectListener, AnimListDifficultyHider, AnimationPartListener,
                                     SettingsListener {

  let level:String
  let link:String
  let call:String?
  
  var animListLayout:AnimListLayout!
  var animationLayout:AnimationLayout!
  var definitionLayout:DefinitionLayout!
  var settingsLayout:SettingsLayout!
  var topview:UIView!
  var background1:BackgroundPanel!
  var background2:BackgroundPanel!
  weak var rightview:UIView!
  
  let animListControl = AnimListControl()
  let animationControl = AnimationControl()
  let animationPanelControl = AnimationPanelControl()
  let definitionControl = DefinitionControl()
  let settingsControl = SettingsControl()
  
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
    topview = UIView(frame: contentFrame)
    animListLayout = AnimListLayout(frame:leftframe)
    animListLayout.table.dataSource = animListControl
    animListLayout.table.delegate = animListControl
    topview.addSubview(animListLayout)
    view = topview
    title = animListControl.title
    setLevelButton(level)
    
    animationLayout = AnimationLayout(frame: middleframe)
    animationLayout.layer.borderWidth = 1
    animationLayout.layer.borderColor = UIColor.black.cgColor
    topview.addSubview(animationLayout)
    background1 = BackgroundPanel(frame: middleframe)
    topview.addSubview(background1)
    
    settingsLayout = SettingsLayout(frame:rightframe)
    settingsControl.reset(settingsLayout)
    settingsControl.settingsListener = self
    topview.addSubview(settingsLayout)
    definitionLayout = DefinitionLayout(frame:rightframe)
    topview.addSubview(definitionLayout)
    definitionControl.reset(definitionLayout, link: link)
    background2 = BackgroundPanel(frame:rightframe)
    topview.addSubview(background2)
    rightview = definitionLayout

    //  Hook up controls
    animListControl.selectListener = self
    
    animationLayout.settingsButton.addTarget(self, action: #selector(SecondLandscapeViewController.settingsSelector), for: .touchUpInside)
    animationLayout.definitionButton.addTarget(self, action: #selector(SecondLandscapeViewController.definitionSelector), for: .touchUpInside)
    animationControl.reset(animationLayout, animationLayout.animationView, link: link)
    animationLayout.animationView.animationPartListener = self

    animListControl.reset(link, level: level, call:call)
    title = animListControl.title

    if (animListControl.currentrow >= 0) {
      selectAnimation(data: animListControl.animlistdata[animListControl.currentrow])
    }
    
  }
  
  func selectAnimation(data:AnimListControl.AnimListData)->Void {
    animationControl.reset(animationLayout, animationLayout.animationView, link:self.link, animnum: data.xmlindex)
    title = data.title
    animationPanelControl.reset(animationLayout.animationPanel, v: animationLayout.animationView)
    definitionControl.setTitle(self.animListControl.animtitle)  // for definition highlighting
    setShareButton("http://www.tamtwirlers.org/tamination/"+link+".html?"+data.fullname)
  }
  
  func settingsChanged() {
    animationControl.readSettings(animationLayout.animationView)
  }
  
  func animationPart(part: Int) {
    definitionControl.setPart(part)
  }
  
  func hideDifficulty() {
    animListLayout.hideDifficulty()
  }
  
  func selectAction(level: String, link: String, data: AnimListControl.AnimListData, xmlcount: Int) {
    self.background1.animate(fromView: self.animationLayout, toView: self.animationLayout, callback: {
      self.selectAnimation(data: data)
    } )
  }
    
  @objc func settingsSelector() {
    if rightview != settingsLayout {
      background2.animate(fromView: definitionLayout, toView: settingsLayout, callback: { } )
      rightview = settingsLayout
    }
  }

  @objc func definitionSelector() {
    if rightview != definitionLayout {
      background2.animate(fromView: settingsLayout, toView: definitionLayout, callback: { } )
      rightview = definitionLayout
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    self.definitionControl.defstyleAction()
  }
  
}

