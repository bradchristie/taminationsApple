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

class DefinitionLayout: UIView {
  
  let webview:UIWebView
  let defstyle = UISegmentedControl()
  
  override init(frame: CGRect) {
    webview = UIWebView(frame:CGRect(x: 0,y: 0,width: frame.size.width,height: frame.size.height))
    super.init(frame:frame)
    addSubview(webview)
    let lang = Locale.preferredLanguages[0].replaceFirst("[-_].*", "")
    defstyle.backgroundColor = UIColor.white
    defstyle.insertSegment(withTitle: lang == "ja" ? "省略された" : "Abbreviated", at: 0, animated: false)
    defstyle.insertSegment(withTitle: lang == "ja" ? "遺漏なく" : "Full", at: 1, animated: false)
    addSubview(defstyle)
    visualConstraints("V:|[a][b]|", fillHorizontal: true)
  }
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }


}
