import UIKit

extension String {
    func range(of strings: [String], options: NSString.CompareOptions, range: NSRange? = nil) -> (range: NSRange?, foundString: String?) {
        guard !strings.isEmpty else { return (nil, nil) }
        var i = 0
        var foundRange: NSRange?
        var string = ""
        repeat {
            string = strings[i]
            if let range = range {
                foundRange = (self as NSString).range(of: string, options: options, range: range)
            } else {
                foundRange = (self as NSString).range(of: string, options: options)
            }
            i += 1
        } while foundRange?.location == NSNotFound && i < strings.count
        
        return (foundRange, string)
    }
}
