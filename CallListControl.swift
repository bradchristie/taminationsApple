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

class CallListControl : NSObject, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate {
  
  class CallListData {
    let title:String
    let link:String
    let level:String
    let sublevel:String
    init(title:String, link:String, level:String, sublevel:String) {
      self.title = title
      self.link = link
      self.level = level
      self.sublevel = sublevel
    }
    var height:CGFloat = 0
  }
  
  var selectAction:(String,String)->Void = { arg in }
  var reloadTable:()->Void = { }

  let indexstr = "#ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  var calllistdata:[CallListData] = []
  var sections:[[CallListData]] = []
  var sectionIndex:[String] = []
  var previndex = -1
  var query = ""
    
  func reset(level:String) {
    let mylevel = LevelData.find(level)!
    //  Load the xml file with the list of calls
    let menuxml = TamUtils.getXMLAsset(mylevel.selector.containsString("Index") ? "src/callindex.xml" : "src/calls.xml")
    //  Read all the data now so searching is more interactive
    let xmlpath = "/calls/call[@\(mylevel.selector)]"
    let nodes = menuxml.xPath(xmlpath)!
    calllistdata = nodes.map{ node in CallListData(title:node["title"]!,link:node["link"]!,level:node["level"]!,sublevel:node["sublevel"]!) }
    buildTable()
  }
  
  func buildTable() {
    //  Build a regex from the user query
    sections = []
    sectionIndex = []
    previndex = -1
    var work:[CallListData] = []
    let queryregex = try? NSRegularExpression(pattern: TamUtils.callnameQuery(query), options: NSRegularExpressionOptions.CaseInsensitive)
    for cld in calllistdata {
      //  filter based on query
      if let q = queryregex {
        if (q.numberOfMatchesInString(cld.title, options: NSMatchingOptions(), range: NSMakeRange(0,cld.title.length)) == 0) {
          continue
        }
      }
      //  TODO arrays in Swift are passed by value - this probably could be better
      let i = max(indexstr.indexOf(cld.title.uppercaseString[0]),0)
      if (i != previndex) {
        if (work.count > 0) {
          sections.append(work)
        }
        work = []
        previndex = i
        sectionIndex.append(indexstr[i])
      }
      work.append(cld)
    }
    if (work.count > 0) {
      sections.append(work)
    }
    reloadTable()
  }
  
  func callFont(tableView:UITableView) -> UIFont {
    return UIFont.systemFontOfSize(max(24,tableView.bounds.size.height/40))
  }
  func levelFont() -> UIFont { return UIFont.systemFontOfSize(14) }
  func levelSize(cld:CallListData) -> CGSize { return cld.sublevel.sizeWithAttributes([NSFontAttributeName:levelFont()]) }
  
  //  Calculates wrapping for a row given the strings for the call and the level
  func wrappedStringForRowAtIndexPath(tableView: UITableView, indexPath:NSIndexPath, toFitWidth:CGFloat) -> String {
    let cld = sections[indexPath.section][indexPath.row]
    // iOS seems unable to wrap text into a table cell without clobbering the subtitle
    // So we will do this the hard way
    let words = cld.title.split()
    var labeltext = ""
    var oneline = ""
    for word in words {
      if (oneline.length == 0) {
        oneline = word
        continue
      }
      let text = oneline + " " + word
      let labelSize = text.sizeWithAttributes([NSFontAttributeName:callFont(tableView)])
      //  Add 50+ for margins, spacing, index on right
      if (labelSize.width > toFitWidth - levelSize(cld).width - 54) {
        labeltext = labeltext + oneline + "\n"
        oneline = word
      } else {
        oneline = text
      }
    }
    return labeltext + oneline
  }
  
  //  Required data source methods
  @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("calllisttablecell") ?? UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "calllisttablecell")
    let cld = sections[indexPath.section][indexPath.row]
    let labeltext = wrappedStringForRowAtIndexPath(tableView, indexPath: indexPath, toFitWidth: tableView.bounds.width)
    cell.textLabel?.text = labeltext
    cell.textLabel?.font = UIFont.systemFontOfSize(max(24,tableView.bounds.size.height/40))
    cell.textLabel?.numberOfLines = 0
    cell.detailTextLabel?.text = cld.sublevel
    cell.backgroundColor = LevelData.find(cld.sublevel)?.color
    return cell
  }
  
  @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return sections.count
  }
  
  @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections[section].count
  }
  
  @objc func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
    return sectionIndex
  }
  
  @objc func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
    return index
  }
  
  @objc func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return nil
  }
  
  @objc func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return nil
  }
  
  
  //  Table view delegate
  @objc func tableView(tableView:UITableView, heightForRowAtIndexPath indexPath:NSIndexPath) -> CGFloat {
    let cld = sections[indexPath.section][indexPath.row]
    if (cld.height == 0) {
      let labeltext = wrappedStringForRowAtIndexPath(tableView, indexPath: indexPath, toFitWidth: tableView.bounds.width)
      let labelSize = labeltext.sizeWithAttributes([NSFontAttributeName:callFont(tableView)])
      cld.height = labelSize.height + 10
    }
    return cld.height
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cld = sections[indexPath.section][indexPath.row]
    selectAction(cld.sublevel,cld.link)
  }

  
  //  Search display delegate
  @objc func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
    query = searchString ?? ""
    buildTable()
    return true
  }
  
  //  Search Bar delegate
  @objc func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    query = ""
    searchBar.resignFirstResponder()  // dismisses keyboard
    searchBar.text = ""
    searchBar.showsCancelButton = false
    buildTable()
  }
 
  @objc func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    searchBar.showsCancelButton = query.length > 0    
  }
  
  @objc func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchBar.showsCancelButton = false
    searchBar.resignFirstResponder()  // dismisses keyboard
  }
  
  @objc func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    query = searchText
    searchBar.showsCancelButton = query.length > 0
    buildTable()
  }
  
}




