//
//  EmojiBoard.swift
//  TastyImitationKeyboard
//
//  Created by Boris Bügling on 25/10/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import Emoji
import IRFEmojiCheatSheet
import UIKit

class EmojiBanner : ExtraView {
    var emojiBoard : EmojiBoard? = nil
    let scrollView : UIScrollView

    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        scrollView = UIScrollView(frame: CGRectZero)

        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
        self.addSubview(scrollView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func emojiTapped(button:UIButton) {
        let emoji = button.titleForState(UIControlState.Normal)
        emojiBoard?.deleteCurrentWord()
        emojiBoard?.insertWord(emoji!)
        update("")
    }

    func update(currentWord:String) {
        let word = currentWord.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString
        let matches = Set((IRFEmojiCheatSheet.emojisForPrefix(word) + EMOJI.findUnicodeName(word).map { "\($0)" }).flatMap { $0 as? String }.prefix(10))

        scrollView.frame = self.bounds
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }

        var x : CGFloat = 0.0

        for match in matches {
            let button : UIButton = UIButton(type: UIButtonType.Custom) as UIButton
            button.addTarget(self, action: "emojiTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            button.frame = CGRect(x: x, y: 0.0, width: 44.0, height: self.frame.size.height)
            button.setTitle(match, forState: UIControlState.Normal)
            button.titleLabel?.font = UIFont.systemFontOfSize(30)
            scrollView.addSubview(button)

            x += button.frame.size.width + 5.0
        }

        scrollView.contentOffset = CGPointZero
        scrollView.contentSize = CGSizeMake(x, self.frame.size.height)
    }
}

class EmojiBoard: KeyboardViewController {

    var currentWord : String = ""

    override func backspaceDown(sender: KeyboardKey) {
        super.backspaceDown(sender)
        deleteLastCharacter()
        updateBanner()
    }

    override func backspaceRepeatCallback() {
        super.backspaceRepeatCallback()
        deleteLastCharacter()
        updateBanner()
    }

    func deleteCurrentWord() {
        let textDocumentProxy = self.textDocumentProxy
        for _ in 0..<currentWord.characters.count {
            textDocumentProxy.deleteBackward()
        }
    }

    func deleteLastCharacter() {
        let stringLength = currentWord.characters.count

        if stringLength == 0 {
            return
        }

        let substringIndex = stringLength - 1
        currentWord = currentWord.substringToIndex(currentWord.startIndex.advancedBy(substringIndex))
    }

    func insertWord(word:String) {
        let textDocumentProxy = self.textDocumentProxy
        textDocumentProxy.insertText(word)
        textDocumentProxy.insertText(" ")

        currentWord = ""

    }

    override func keyPressed(key: Key) {
        let textDocumentProxy = self.textDocumentProxy
        let currentChar = key.outputForCase(self.shiftState.uppercase())
        textDocumentProxy.insertText(currentChar)

        if currentChar == " " {
            deleteCurrentWord()
            textDocumentProxy.deleteBackward()

            let repl = IRFEmojiCheatSheet.stringByReplacingEmojiAliasesInString(currentWord)
            insertWord(repl)
        } else {
            currentWord += currentChar
        }

        updateBanner()
    }

    func updateBanner() {
        let banner = self.bannerView as! EmojiBanner
        banner.emojiBoard = self
        banner.update(currentWord)
    }

    override func createBanner() -> ExtraView? {
        return EmojiBanner(globalColors: self.dynamicType.globalColors, darkMode: false, solidColorMode: self.solidColorMode())
    }
}
