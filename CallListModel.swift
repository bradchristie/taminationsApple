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

protocol CallListFollower : NSObjectProtocol {
  func selectAction(level:String,link:String) -> Void
  func tableLoaded() -> Void
}


class CallListModel : NSObject, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
  
  class CallListData {
    let title:String
    let link:String
    let sublevel:String
    init(title:String, link:String, sublevel:String) {
      self.title = title
      self.link = link
      self.sublevel = sublevel
    }
    var height:CGFloat = 0
  }
  
  weak var follower:CallListFollower?
  
  let indexstr = "#ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  var calllistdata:[CallListData] = []
  var sections:[[CallListData]] = []
  var sectionIndex:[String] = []
  var previndex = -1
  var query = ""
  var searchController:UISearchController?
  
  @nonobjc func reset(_ vc:UIViewController, _ level:String) {
    searchController = UISearchController(searchResultsController: nil)
    searchController?.searchResultsUpdater = self
    let mylevel = LevelData.find(level)!
    //  Read all the data now so searching is more interactive
    let xmlpath = mylevel.selector
    let nodes = mylevel.doc.xpath(xmlpath)
    calllistdata = nodes.map{ node in CallListData(title:node["title"]!,link:node["link"]!,sublevel:node["sublevel"]!) }
    buildTable()
  }
  
  func buildTable() {
    //  Build a regex from the user query
    sections = []
    sectionIndex = []
    previndex = -1
    var work:[CallListData] = []
    let queryregex = try? NSRegularExpression(pattern: TamUtils.callnameQuery(query), options: NSRegularExpression.Options.caseInsensitive)
    for cld in calllistdata {
      //  filter based on query
      if let q = queryregex {
        if (q.numberOfMatches(in: cld.title, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0,cld.title.length)) == 0) {
          continue
        }
      }
      //  TODO arrays in Swift are passed by value - this probably could be better
      let i = max(indexstr.indexOfAsInt(cld.title.uppercased()[0]),0)
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
    follower?.tableLoaded()
  }
  
  func callFont(_ tableView:UITableView) -> UIFont {
    return UIFont.systemFont(ofSize: max(24,tableView.bounds.size.height/40))
  }
  func levelFont(_ tableView:UITableView) -> UIFont {
    return UIFont.systemFont(ofSize: max(18,tableView.bounds.size.height/60))
  }
  func levelSize(_ tableView:UITableView, _ cld:CallListData) -> CGSize {
    return cld.sublevel.size(withAttributes: [NSAttributedStringKey.font:levelFont(tableView)])
    
  }
  
  //  Calculates wrapping for a row given the strings for the call and the level
  func wrappedStringForRowAtIndexPath(_ tableView: UITableView, indexPath:IndexPath, toFitWidth:CGFloat) -> String {
    let cld = sections[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
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
      let labelSize = text.size(withAttributes: [NSAttributedStringKey.font:callFont(tableView)])
      //  Add 50+ for margins, spacing, index on right
      if (labelSize.width > toFitWidth - levelSize(tableView,cld).width - 54) {
        labeltext = labeltext + oneline + "\n"
        oneline = word
      } else {
        oneline = text
      }
    }
    return labeltext + oneline
  }
  
  //  Required data source methods
  @objc func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cld = sections[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
    let labeltext = wrappedStringForRowAtIndexPath(tableView, indexPath: indexPath, toFitWidth: tableView.bounds.width)
    var cell = tableView.dequeueReusableCell(withIdentifier: "calllisttablecell")
    if (cell == nil) {
      cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "calllisttablecell")
      let labelView = UILabel()
      labelView.text = labeltext
      labelView.font = callFont(tableView)
      labelView.numberOfLines = 0
      labelView.tag = 1
      cell?.contentView.addSubview(labelView)
  
      let levelView = UILabel()
      levelView.textAlignment = NSTextAlignment.right
      levelView.font = UIFont.systemFont(ofSize: max(18,tableView.bounds.size.height/60))
      levelView.numberOfLines = 1
      levelView.tag = 2
      cell?.contentView.addSubview(levelView)
    }
    let rowRect = tableView.rectForRow(at: indexPath)
    let labelView = cell?.contentView.viewWithTag(1) as! UILabel
    let labelSize = labeltext.size(withAttributes: [NSAttributedStringKey.font:callFont(tableView)])
    labelView.text = labeltext
    labelView.frame = CGRect(x: 12, y: 5, width: rowRect.width, height: labelSize.height)
    
    let levelView = cell?.contentView.viewWithTag(2) as! UILabel
    levelView.text = cld.sublevel
    levelView.frame = CGRect(x: 0, y: 5, width: rowRect.width-32, height: labelSize.height)
    
    cell?.backgroundColor = LevelData.find(cld.sublevel)?.color

    /*
    cell.textLabel?.text = labeltext
    cell.textLabel?.font = callFont(tableView)
    cell.textLabel?.numberOfLines = 0
    cell.detailTextLabel?.text = cld.sublevel
    cell.detailTextLabel?.font = UIFont.systemFont(ofSize: max(18,tableView.bounds.size.height/60))
    cell.detailTextLabel?.numberOfLines = 1
    cell.backgroundColor = LevelData.find(cld.sublevel)?.color
//    cell.contentView.visualConstraints("|[a][b]|",fillVertical:true)
    */
    cell?.accessibilityIdentifier = labeltext    // for testing
    return cell!
  }
  
  @objc func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections[section].count
  }
  
  @objc func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    return sectionIndex
  }
  
  @objc func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
    return index
  }
  
  @objc func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return nil
  }
  
  @objc func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return nil
  }
  
  
  //  Table view delegate
  @objc func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath) -> CGFloat {
    let cld = sections[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
    if (cld.height == 0) {
      let labeltext = wrappedStringForRowAtIndexPath(tableView, indexPath: indexPath, toFitWidth: tableView.bounds.width)
      let labelSize = labeltext.size(withAttributes: [NSAttributedStringKey.font:callFont(tableView)])
      cld.height = labelSize.height + 10
    }
    return cld.height
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cld = sections[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
    follower?.selectAction(level: cld.sublevel, link: cld.link)
  }

/*
  //  Search display delegate
  @objc func searchDisplayController(_ controller: UISearchDisplayController, shouldReloadTableForSearch searchString: String?) -> Bool {
    query = searchString ?? ""
    buildTable()
    return true
  }
 */
  @objc func updateSearchResults(for searchController: UISearchController) {
    
  }
  
  //  Search Bar delegate
  @objc func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    query = ""
    searchBar.resignFirstResponder()  // dismisses keyboard
    searchBar.text = ""
    searchBar.showsCancelButton = false
    buildTable()
  }
 
  @objc func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = query.length > 0    
  }
  
  @objc func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = false
    searchBar.resignFirstResponder()  // dismisses keyboard
  }
  
  @objc func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    query = searchText
    searchBar.showsCancelButton = query.length > 0
    buildTable()
  }
  
}




