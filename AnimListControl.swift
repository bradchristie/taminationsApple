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

class AnimListControl : NSObject, UITableViewDataSource, UITableViewDelegate {
  
  enum CellType:String {
    case Header = "Header"
    case Separator = "Separator"
    case Indented = "Indented"
    case Plain = "Plain"
  }
  
  class AnimListData {
    let celltype:CellType
    let text:String
    let title:String
    let group:String
    let fullname:String
    let xmlindex:Int
    let difficulty:Int
    var wasSelected:Bool = false
    
    init(celltype:CellType, text:String, title:String, group:String, fullname:String, xmlindex:Int, difficulty:Int) {
      self.celltype = celltype
      self.text = text
      self.title = title
      self.group = group
      self.fullname = fullname
      self.xmlindex = xmlindex
      self.difficulty = difficulty
    }
  }
  
  var currentrow = -1
  var title = ""
  var animtitle = ""
  var animlistdata:[AnimListData] = []
  var selectAction:(String,String,AnimListData,Int)->Void = { arg in }
  var hideDifficulty:()->Void = { }
  var link:String = ""
  var level:String = ""
  var xmlcount = 0
  var firstanim = -1

  func reset(link:String, level:String, call:String?) {
    self.link = link
    self.level = level
    //  Get the xml file listing the animations
    let tamxml = TamUtils.getXMLAsset(link)
    //  Get the title from the xml file
    title = tamxml.rootNode!["title"] ?? "Title Missing !!"
    //  If we came from the master index, the user clicked call could be
    //  something different than the main title of this call
    //  TODO "clickedfullname"
    
    //  Get the list of animations
    let tams = TamUtils.tamList(tamxml).filter{$0["display"] != "none"}
    var prevtitle = ""
    var prevgroup = ""
    var diffsum = 0
    var selectanim = -1
    var xmlindex = 0
    for tam in tams {
      let tamtitle = tam["title"]!
      var from = TamUtils.tamXref(tam)["from"] ?? ""
      var fullname = tamtitle + "from" + (from ?? "")  // for matching search request
      let group = tam["group"] ?? ""
      let difficulty = Int(tam["difficulty"] ?? "0") ?? 0
      diffsum += difficulty
      xmlcount += 1
      if (group.length > 0) {
        fullname = tamtitle
        //  Add header for new group as needed
        if (group != prevgroup) {
          if (group.replaceAll(" ", "").length == 0) {
            //  Blank group, for calls with no commmon starting phrase
            //  Add a separator unless it's the first group
            if (animlistdata.count > 0) {
              animlistdata.append(AnimListData(celltype:CellType.Separator, text: "", title:"", group: "", fullname: "", xmlindex: -1, difficulty: 0))
            }
          } else {
            //  Named group e.g. "As Couples"
            //  Add a header with the group name, which starts
            //  each call in the group
            animlistdata.append(AnimListData(celltype: CellType.Header, text: group, title:"", group: "", fullname: "", xmlindex: -1, difficulty: 0))
          }
        }
        from = tamtitle.replaceAll(group, " ").trim()
      }
      else if (tamtitle != prevtitle) {
        //  Not a group but a different call
        //  Put out a header with this call
        animlistdata.append(AnimListData(celltype: CellType.Header, text: tamtitle+" from", title:"", group: "", fullname: "", xmlindex: -1, difficulty: 0))
      }
      prevtitle = tamtitle
      prevgroup = group

      //  Remember where the first real animation is in the list
      if (currentrow < 0) {
        currentrow = animlistdata.count
      }

      //  Also remember where the first animation that matches the user
      //  selection from the master index or link
      if (call != nil) {
        if (selectanim < 0 && tamtitle == call) {
          selectanim = animlistdata.count
        }
        let webtarget = group.length > 0 ? tamtitle : tamtitle + "from" + from
        if call?.lowercaseString == webtarget.lowercaseString.replaceAll("\\W", "") {
          selectanim = animlistdata.count
        }
      }

      //  Now add an item for this call
      if (group.length > 0 && group.replaceAll(" ", "").length == 0) {
        animlistdata.append(AnimListData(celltype: CellType.Plain, text: from, title:tamtitle, group: "", fullname: fullname, xmlindex: xmlindex, difficulty: difficulty))
      } else if (group.length > 0) {
        animlistdata.append(AnimListData(celltype: CellType.Plain, text: from, title:tamtitle, group: group, fullname: fullname, xmlindex: xmlindex, difficulty: difficulty))
      } else {
        animlistdata.append(AnimListData(celltype: CellType.Indented, text: from, title:tamtitle, group: tamtitle+" from", fullname: fullname, xmlindex: xmlindex, difficulty: difficulty))
      }
      
      xmlindex += 1
    }  // end of loop over animations defined in xml file
   
    //  Show or hide difficulty legend
    if (diffsum == 0) {
      hideDifficulty()
    }
    
    //  Go to a requested animation
    if (selectanim >= 0) {
      firstanim = selectanim
      animtitle = animlistdata[selectanim].title
      selectAction(level,link,animlistdata[selectanim],xmlcount)
    }
    else if (currentrow >= 0) {
      animtitle = animlistdata[currentrow].title
    }
    
/*
    //  List of all animations completed
    //  If a requested animation is not found, it must have been from a bad url
    if (clickedfullname != nil && [[NSUserDefaults standardUserDefaults] objectForKey:@"ShowAnimationController"]) {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error loading Taminations link"
    message:[@"Incorrect animation: " concat:clickedfullname] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [alert show];
    
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"fullname"];
    //  User selection from master index supercedes default 1st animation
    if (selectanim >= 0)
    currentrow = selectanim;
    //  Tell the user if there are no animations
    if (tams.count == 0) {
    NSString *noanim = @"Sorry, there are no animations for this call.";
    [animlistdata addObject:[[AnimListData alloc] init:header text:noanim group:nil fullname:nil xmlindex:-1 difficulty:0]];
    }

*/
    
  }
  
  func cellFont(tableView:UITableView) -> UIFont { return UIFont.systemFontOfSize(max(24,tableView.bounds.size.height/40)) }
  
  //  Required data source methods
  @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let data = animlistdata[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier("animlisttablecell", forIndexPath:indexPath)
    if (data.celltype != CellType.Separator) {
      cell.textLabel?.text = data.text
      cell.textLabel?.font = cellFont(tableView)
      cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
      cell.textLabel?.numberOfLines = 0
    }
    if (data.celltype == CellType.Indented || data.celltype == CellType.Plain) {
      let bgColorView = UIView()
      bgColorView.backgroundColor = UIColor.clearColor()
      bgColorView.layer.borderColor = UIColor.blueColor().CGColor
      bgColorView.layer.borderWidth = 3
      cell.selectedBackgroundView = bgColorView
      cell.textLabel?.textColor = data.wasSelected ? UIColor(red: 0, green: 0, blue: 0.5, alpha: 1) : UIColor.blackColor()
      switch data.difficulty {
      case 3 : cell.backgroundColor = UIColor(red: 1, green: 0.75, blue: 0.75, alpha: 1)
      case 2 : cell.backgroundColor = UIColor(red: 1, green: 1, blue: 0.75, alpha: 1)
      case 1 : cell.backgroundColor = UIColor(red: 0.75, green: 0.875, blue: 0.75, alpha: 1)
      default : cell.backgroundColor = UIColor.whiteColor()
      }
      cell.indentationLevel = data.celltype == CellType.Indented ? 2 : 0
      cell.userInteractionEnabled = true
    } else {
      cell.userInteractionEnabled = false
      cell.backgroundColor = UIColor(red: 0.5, green: 0.25, blue: 0.5, alpha: 1)
      cell.textLabel?.textColor = UIColor.whiteColor()
    }
    return cell
  }

  
  @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return animlistdata.count
  }
  
  
  //  Table view delegate
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    let data = animlistdata[indexPath.row]
    if (data.celltype == CellType.Separator) {
      return 16
    } else {
      //  Need to subtract a bit from the width to allow for '>' indicator or indentation
      let wd = data.celltype == CellType.Indented ? 60 : data.celltype == CellType.Plain ? 40 : 10
      let constraintSize = CGSizeMake(tableView.bounds.width-CGFloat(wd), CGFloat(MAXFLOAT))
      let labelSize = data.text.boundingRectWithSize(constraintSize,options:[NSStringDrawingOptions.UsesLineFragmentOrigin],
        attributes:[NSFontAttributeName:cellFont(tableView)],context:nil)
      return labelSize.height + 10
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let data = animlistdata[indexPath.row]
    animtitle = data.title
    selectAction(level,link,data,xmlcount)
  }
  
  
  
}