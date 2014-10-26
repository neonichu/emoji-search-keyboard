// Playground - noun: a place where people can play

import UIKit

let miscSymsRange = 0x1F300...0x1F5FF
let emoticonRange = 0x1F600...0x1F64F
let transportRange = 0x1F680...0x1F6FF
let miscSyms2Range = 0x2600...0x26FF
let dingbats = 0x2700...0x27BF


for int in miscSymsRange {
    let char = Character(UnicodeScalar(int))
    let cfstr = NSMutableString(string: String(char)) as CFMutableString
    var range = CFRangeMake(0, CFStringGetLength(cfstr))
    CFStringTransform(cfstr, &range, kCFStringTransformToUnicodeName, 0)
    println(cfstr as NSString)
}
