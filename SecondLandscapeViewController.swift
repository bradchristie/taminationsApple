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
  
  var animListView:AnimListView!
  var animationLayout:AnimationLayout!
  var definitionLayout:DefinitionLayout!
  var settingsView:SettingsView!
  var topview:UIView!
  var background1:BackgroundPanel!
  var background2:BackgroundPanel!
  weak var rightview:UIView!
  
  let animListModel = AnimListModel()
  let animationControl = AnimationControl()
  let animationPanelControl = AnimationPanelControl()
  let definitionControl = DefinitionControl()
  let settingsModel = SettingsModel()
  
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
    animListView = AnimListView(frame:leftframe)
    animListView.table.dataSource = animListModel
    animListView.table.delegate = animListModel
    topview.addSubview(animListView)
    view = topview
    title = animListModel.title
    setLevelButton(level)
    
    animationLayout = AnimationLayout(frame: middleframe)
    animationLayout.layer.borderWidth = 1
    animationLayout.layer.borderColor = UIColor.black.cgColor
    topview.addSubview(animationLayout)
    background1 = BackgroundPanel(frame: middleframe)
    topview.addSubview(background1)
    
    settingsView = SettingsView(frame:rightframe)
    settingsModel.reset(settingsView)
    settingsModel.settingsListener = self
    topview.addSubview(settingsView)
    definitionLayout = DefinitionLayout(frame:rightframe)
    topview.addSubview(definitionLayout)
    definitionControl.reset(definitionLayout, link: link)
    background2 = BackgroundPanel(frame:rightframe)
    topview.addSubview(background2)
    rightview = definitionLayout

    //  Hook up controls
    animListModel.selectListener = self
    
    animationLayout.settingsButton.addTarget(self, action: #selector(SecondLandscapeViewController.settingsSelector), for: .touchUpInside)
    animationLayout.definitionButton.addTarget(self, action: #selector(SecondLandscapeViewController.definitionSelector), for: .touchUpInside)
    animationControl.reset(animationLayout, animationLayout.animationView, link: link)
    animationLayout.animationView.animationPartListener = self

    animListModel.reset(link, level: level, call:call)
    title = animListModel.title

    if (animListModel.currentrow >= 0) {
      animListView.table.selectRow(at: IndexPath(row:animListModel.selectanim,section:0), animated: false, scrollPosition: UITableViewScrollPosition.none)
      selectAnimation(data: animListModel.animlistdata[animListModel.currentrow])
    }
    
  }
  
  func selectAnimation(data:AnimListModel.AnimListData)->Void {
    animationControl.reset(animationLayout, animationLayout.animationView, link:self.link, animnum: data.xmlindex)
    title = data.title
    animationPanelControl.reset(animationLayout.animationPanel, v: animationLayout.animationView)
    definitionControl.setTitle(self.animListModel.animtitle)  // for definition highlighting
    setShareButton("http://www.tamtwirlers.org/tamination/"+link+".html?"+data.fullname)
  }
  
  func settingsChanged() {
    animationControl.readSettings(animationLayout.animationView)
  }
  
  func animationPart(part: Int) {
    definitionControl.setPart(part)
  }
  
  func hideDifficulty() {
    animListView.hideDifficulty()
  }
  
  func selectAction(level: String, link: String, data: AnimListModel.AnimListData, xmlcount: Int) {
    self.background1.animate(fromView: self.animationLayout, toView: self.animationLayout, callback: {
      self.selectAnimation(data: data)
    } )
  }
    
  @objc func settingsSelector() {
    if rightview != settingsView {
      background2.animate(fromView: definitionLayout, toView: settingsView, callback: { } )
      rightview = settingsView
    }
  }

  @objc func definitionSelector() {
    if rightview != definitionLayout {
      background2.animate(fromView: settingsView, toView: definitionLayout, callback: { } )
      rightview = definitionLayout
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    self.definitionControl.defstyleAction()
  }
  
}

