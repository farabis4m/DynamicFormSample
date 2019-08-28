//
//  SearchTextField.swift
//  SampleDynamicForm
//
//  Created by Jafar Khan on 6/18/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import UIKit
import Foundation

typealias VoidClosure = () -> ()

class SearchTextField: UITextField {
    
    ////////////////////////////////////////////////////////////////////////
    // Public interface
    
    var cellHeight: CGFloat = 30.0
    
    /// Maximum number of results to be shown in the suggestions list
    open var maxNumberOfResults = 0
    
    /// Maximum height of the results list
    open var maxResultsListHeight = 0
    
    /// Indicate if this field has been interacted with yet
    open var interactedWith = false
    
    /// Indicate if keyboard is showing or not
    open var keyboardIsShowing = false
    
    /// How long to wait before deciding typing has stopped
    open var typingStoppedDelay = 0.8
    
    open var shouldShowTextCount = false
    
    open var minimumItemsForDownDirection = 1
    
    open var shouldLoadDataFromServerDynamically = false
    
    /// Show the suggestions list without filter when the text field is focused
    open var startVisible = false
    
    /// Show the suggestions list without filter even if the text field is not focused
    open var startVisibleWithoutInteraction = false {
        didSet {
            if startVisibleWithoutInteraction {
                textFieldDidChange()
            }
        }
    }
    
    /// Set an array of SearchTextFieldItem's to be used for suggestions
    open func filterItems(_ items: [SearchTextFieldItem]) {
        filterDataSource = items
        
        filter(forceShowAll: forceNoFiltering)
        buildSearchTableView()
        
        if startVisibleWithoutInteraction {
            textFieldDidChange()
        }
    }
    
    /// Set an array of strings to be used for suggestions
    open func filterStrings(_ strings: [String]) {
        var items = [SearchTextFieldItem]()
        
        for value in strings {
            items.append(SearchTextFieldItem(title: value))
        }
        
        filterItems(items)
    }
    
    // set updated list if required
    open func updateList(_ strings: [String]) {
        var items = [SearchTextFieldItem]()
        
        for value in strings {
            items.append(SearchTextFieldItem(title: value))
        }
        filterDataSource = items
    }
    
    /// Closure to handle when the user pick an item
    open var itemSelectionHandler: SearchTextFieldItemHandler?
    
    open var itemStartEditingHandler: VoidClosure?
    
    /// Closure to handle when the user stops typing
    open var userStoppedTypingHandler: (() -> Void)?
    
    /// Closure to handle when the user stops typing
    open var finishEditingHandler: (() -> Void)?
    
    /// Set your custom set of attributes in order to highlight the string found in each item
    // open var highlightAttributes: [NSAttributedStringKey: AnyObject] = [.font: UIFont.boldSystemFont(ofSize: 10)]
    
    /// Start showing the default loading indicator, useful for searches that take some time.
    open func showLoadingIndicator() {
        rightView = indicator
        indicator.startAnimating()
    }
    
    /// Force the results list to adapt to RTL languages
    open var forceRightToLeft = false
    
    /// Hide the default loading indicator
    open func stopLoadingIndicator() {
        if shouldShowTextCount {
            rightView = textCountLabel
        }
        indicator.stopAnimating()
    }
    
    /// When InlineMode is true, the suggestions appear in the same line than the entered string. It's useful for email domains suggestion for example.
    open var inlineMode: Bool = false {
        didSet {
            if inlineMode == true {
                autocorrectionType = .no
                spellCheckingType = .no
            }
        }
    }
    
    /// Only valid when InlineMode is true. The suggestions appear after typing the provided string (or even better a character like '@')
    open var startFilteringAfter: String?
    
    /// Min number of characters to start filtering
    open var minCharactersNumberToStartFiltering: Int = 0
    
    /// Force no filtering (display the entire filtered data source)
    open var forceNoFiltering: Bool = false
    
    /// If startFilteringAfter is set, and startSuggestingInmediately is true, the list of suggestions appear inmediately
    open var startSuggestingInmediately = false
    
    open var shouldShowLoadingIndicator = false
    
    /// Allow to decide the comparision options
    open var comparisonOptions: NSString.CompareOptions = [.caseInsensitive]
    
    /// Set the results list's header
    open var resultsListHeader: UIView?
    
    open var textCount: Int? {
        didSet {
            setUpMaxLengthLabel()
        }
    }
    
    // Move the table around to customize for your layout
    open var tableXOffset: CGFloat = 0.0
    open var tableYOffset: CGFloat = 0.0
    open var tableCornerRadius: CGFloat = 2.0
    open var tableBottomMargin: CGFloat = 10.0
    
    var padding = UIEdgeInsets(top: 0, left: 13, bottom: 0, right: 13)
    
    ////////////////////////////////////////////////////////////////////////
    // Private implementation
    
    fileprivate var tableView: UITableView?
    fileprivate var shadowView: UIView?
    fileprivate var direction: ListDirection = .down
    fileprivate var fontConversionRate: CGFloat = 0.7
    fileprivate var keyboardFrame: CGRect?
    fileprivate var timer: Timer? = nil
    fileprivate var placeholderLabel: UILabel?
    fileprivate static let cellIdentifier = "APSearchTextFieldCell"
    fileprivate let indicator = UIActivityIndicatorView(style: .gray)
    fileprivate var maxTableViewSize: CGFloat = 0
    fileprivate var textCountLabel = UILabel()
    
    fileprivate var filteredResults = [SearchTextFieldItem]()
    open var filterDataSource = [SearchTextFieldItem]()
    
    fileprivate var currentInlineItem = ""
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        tableView?.removeFromSuperview()
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        self.addTarget(self, action: #selector(SearchTextField.textFieldDidChange), for: .editingChanged)
        self.addTarget(self, action: #selector(SearchTextField.textFieldDidBeginEditing), for: .editingDidBegin)
        self.addTarget(self, action: #selector(SearchTextField.textFieldDidEndEditing), for: .editingDidEnd)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchTextField.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchTextField.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchTextField.keyboardDidChangeFrame(_:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if inlineMode {
            buildPlaceholderLabel()
        } else {
            buildSearchTableView()
        }
        
        // Create the loading indicator
        indicator.hidesWhenStopped = true
        
        if shouldShowLoadingIndicator {
            indicator.frame = CGRect(x: indicator.frame.origin.x - 10, y: indicator.frame.origin.y, width: indicator.bounds.width, height: indicator.bounds.height)
        }
    }
    
    private func setUpMaxLengthLabel() {
        guard shouldShowTextCount else { return }
        
        let labelFont = UIFont.systemFont(ofSize: 12)
        
        textCountLabel.font = labelFont
        
        let remainingCount = (textCount ?? 0) - (text?.count ?? 0)
        textCountLabel.text = "\(remainingCount)"
        
        let width = textCountLabel.text?.sizeOfText(font:  UIFont(name: labelFont.fontName , size: labelFont.pointSize)).width ?? 30
        textCountLabel.frame.size = CGSize(width: width + 10, height: 30)
        
        rightView = textCountLabel
        rightViewMode = .always
    }
    
    // Create the filter table and shadow view
    fileprivate func buildSearchTableView() {
        if let tableView = tableView, let shadowView = shadowView {
            tableView.layer.masksToBounds = true
            tableView.layer.borderWidth = 2
            tableView.dataSource = self
            tableView.delegate = self
            delegate = self
            tableView.separatorInset = UIEdgeInsets.zero
            tableView.tableHeaderView = resultsListHeader
            if forceRightToLeft {
                tableView.semanticContentAttribute = .forceRightToLeft
            }
            
            shadowView.backgroundColor = UIColor.lightText
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowOffset = CGSize.zero
            shadowView.layer.shadowOpacity = 1
            
            self.window?.addSubview(tableView)
        } else {
            tableView = UITableView(frame: CGRect.zero)
            shadowView = UIView(frame: CGRect.zero)
        }
        
        redrawSearchTableView()
    }
    
    fileprivate func buildPlaceholderLabel() {
        var newRect = self.placeholderRect(forBounds: self.bounds)
        var caretRect = self.caretRect(for: self.beginningOfDocument)
        let textRect = self.textRect(forBounds: self.bounds)
        
        if let range = textRange(from: beginningOfDocument, to: endOfDocument) {
            caretRect = self.firstRect(for: range)
        }
        
        newRect.origin.x = caretRect.origin.x + caretRect.size.width + textRect.origin.x
        newRect.size.width = newRect.size.width - newRect.origin.x
        
        if let placeholderLabel = placeholderLabel {
            placeholderLabel.font = self.font
            placeholderLabel.frame = newRect
        } else {
            placeholderLabel = UILabel(frame: newRect)
            placeholderLabel?.font = self.font
            placeholderLabel?.backgroundColor = UIColor.clear
            placeholderLabel?.lineBreakMode = .byClipping
            placeholderLabel?.textColor = UIColor ( red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0 )
            placeholderLabel?.frame.origin.x = (placeholderLabel?.frame.origin.x ?? 0)
            
            self.addSubview(placeholderLabel!)
        }
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    // Re-set frames and theme colors
    fileprivate func redrawSearchTableView() {
        if inlineMode {
            tableView?.isHidden = true
            return
        }
        
        if let tableView = tableView {
            guard let frame = self.superview?.convert(self.frame, to: nil) else { return }
            
            //TableViews use estimated cell heights to calculate content size until they
            //  are on-screen. We must set this to the theme cell height to avoid getting an
            //  incorrect contentSize when we have specified non-standard fonts and/or
            //  cellHeights in the theme. We do it here to ensure updates to these settings
            //  are recognized if changed after the tableView is created
            tableView.estimatedRowHeight = cellHeight
            if self.direction == .down {
                
                var tableHeight: CGFloat = 0
                if keyboardIsShowing, let keyboardHeight = keyboardFrame?.size.height {
                    tableHeight = min((tableView.contentSize.height), (UIScreen.main.bounds.size.height - frame.origin.y - frame.height - keyboardHeight))
                } else {
                    tableHeight = min((tableView.contentSize.height), (UIScreen.main.bounds.size.height - frame.origin.y - frame.height))
                }
                
                if maxResultsListHeight > 0 {
                    tableHeight = min(tableHeight, CGFloat(maxResultsListHeight))
                }
                
                // Set a bottom margin of 10p
                if tableHeight < tableView.contentSize.height {
                    tableHeight -= tableBottomMargin
                }
                
                var tableViewFrame = CGRect(x: 0, y: 0, width: frame.size.width - 4, height: tableHeight)
                tableViewFrame.origin = self.convert(tableViewFrame.origin, to: nil)
                tableViewFrame.origin.x += 2 + tableXOffset
                tableViewFrame.origin.y += frame.size.height + 2 + tableYOffset
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.tableView?.frame = tableViewFrame
                })
                
                var shadowFrame = CGRect(x: 0, y: 0, width: frame.size.width - 6, height: 1)
                shadowFrame.origin = self.convert(shadowFrame.origin, to: nil)
                shadowFrame.origin.x += 3
                shadowFrame.origin.y = tableView.frame.origin.y
                shadowView!.frame = shadowFrame
            } else {
                let tableHeight = min((tableView.contentSize.height), (UIScreen.main.bounds.size.height - frame.origin.y - (cellHeight)))
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.tableView?.frame = CGRect(x: frame.origin.x + 2, y: (frame.origin.y - tableHeight), width: frame.size.width - 4, height: tableHeight)
                    self?.shadowView?.frame = CGRect(x: frame.origin.x + 3, y: (frame.origin.y + 3), width: frame.size.width - 6, height: 1)
                })
            }
            
            superview?.bringSubviewToFront(tableView)
            superview?.bringSubviewToFront(shadowView!)
            
            if self.isFirstResponder {
                superview?.bringSubviewToFront(self)
            }
            
            tableView.layer.cornerRadius = tableCornerRadius
            
            tableView.reloadData()
        }
    }
    
    // Handle keyboard events
    @objc open func keyboardWillShow(_ notification: Notification) {
        if !keyboardIsShowing && isEditing {
            keyboardIsShowing = true
            keyboardFrame = ((notification as NSNotification).userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            interactedWith = true
            prepareDrawTableResult()
        }
    }
    
    @objc open func keyboardWillHide(_ notification: Notification) {
        if keyboardIsShowing {
            keyboardIsShowing = false
            direction = .down
            redrawSearchTableView()
        }
    }
    
    @objc open func keyboardDidChangeFrame(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.keyboardFrame = ((notification as NSNotification).userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            self?.prepareDrawTableResult()
        }
    }
    
    @objc open func typingDidStop() {
        self.userStoppedTypingHandler?()
    }
    
    // Handle text field changes
    @objc open func textFieldDidChange() {
        
        if shouldLoadDataFromServerDynamically {
            if hasStartedTypingFromBegining() && !startVisibleWithoutInteraction{
                clearResults()
                return
            }
        }
        
        if !inlineMode && tableView == nil {
            buildSearchTableView()
        }
        
        interactedWith = true
        
        // Detect pauses while typing
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: typingStoppedDelay, target: self, selector: #selector(SearchTextField.typingDidStop), userInfo: self, repeats: false)
        
        if text!.isEmpty {
            
            clearResults()
            tableView?.reloadData()
            
            
            if startVisible || startVisibleWithoutInteraction {
                filter(forceShowAll: true)
            }
            self.placeholderLabel?.text = ""
            itemStartEditingHandler?()
            
        } else {
            filter(forceShowAll: forceNoFiltering)
            prepareDrawTableResult()
        }
        
        buildPlaceholderLabel()
    }
    
    @objc open func hasStartedTypingFromBegining() -> Bool {
        return text?.count == 1
    }
    
    @objc open func textFieldDidBeginEditing() {
        
        layer.borderWidth = 1.0
        startVisibleWithoutInteraction = minCharactersNumberToStartFiltering == 0
        if (startVisible || startVisibleWithoutInteraction) && text!.isEmpty {
            clearResults()
            filter(forceShowAll: true)
        }
        placeholderLabel?.attributedText = nil
    }
    
    @objc open func textFieldDidEndEditing() {
        
        
        clearResults()
        tableView?.reloadData()
        placeholderLabel?.attributedText = nil
        finishEditingHandler?()
        
        //At the end of editing we check whether the textfield text count is greater than expected count then we'll set the textcountLabel text to 0
        guard shouldShowTextCount else { return }
        if (text?.count ?? 0) > (textCount ?? 0) {
            textCountLabel.text = "0"
        }
    }
    
    open func hideResultsList() {
        if let tableFrame:CGRect = tableView?.frame {
            let newFrame = CGRect(x: tableFrame.origin.x, y: tableFrame.origin.y, width: tableFrame.size.width, height: 0.0)
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.tableView?.frame = newFrame
            })
            
        }
    }
    
    fileprivate func filter(forceShowAll addAll: Bool) {
        clearResults()
        
        if text!.count < minCharactersNumberToStartFiltering {
            return
        }
        
        for i in 0 ..< filterDataSource.count {
            
            let item = filterDataSource[i]
            
            if !inlineMode {
                // Find text in title and subtitle
                let titleFilterRange = (item.title as NSString).range(of: text!, options: comparisonOptions)
                let subtitleFilterRange = item.subtitle != nil ? (item.subtitle! as NSString).range(of: text!, options: comparisonOptions) : NSMakeRange(NSNotFound, 0)
                
                if titleFilterRange.location != NSNotFound || subtitleFilterRange.location != NSNotFound || addAll {
                    item.attributedTitle = NSMutableAttributedString(string: item.title)
                    item.attributedSubtitle = NSMutableAttributedString(string: (item.subtitle != nil ? item.subtitle! : ""))
                    
                    filteredResults.append(item)
                }
            } else {
                var textToFilter = text!.lowercased()
                
                if inlineMode, let filterAfter = startFilteringAfter {
                    if let suffixToFilter = textToFilter.components(separatedBy: filterAfter).last, (suffixToFilter != "" || startSuggestingInmediately == true), textToFilter != suffixToFilter {
                        textToFilter = suffixToFilter
                    } else {
                        placeholderLabel?.text = ""
                        return
                    }
                }
                
                if item.title.lowercased().hasPrefix(textToFilter) {
                    let indexFrom = textToFilter.index(textToFilter.startIndex, offsetBy: textToFilter.count)
                    let itemSuffix = item.title[indexFrom...]
                    
                    item.attributedTitle = NSMutableAttributedString(string: String(itemSuffix))
                    filteredResults.append(item)
                }
            }
        }
        
        tableView?.reloadData()
        
        if inlineMode {
            handleInlineFiltering()
        }
    }
    
    // Clean filtered results
    fileprivate func clearResults() {
        filteredResults.removeAll()
        tableView?.removeFromSuperview()
    }
    
    // Look for Font attribute, and if it exists, adapt to the subtitle font size
    fileprivate func highlightAttributesForSubtitle() -> [NSAttributedString.Key: AnyObject] {
        
        // this needs to be optimized // no need of this method
        return [NSAttributedString.Key: AnyObject]()
    }
    
    // Handle inline behaviour
    func handleInlineFiltering() {
        if let text = self.text {
            if text == "" {
                self.placeholderLabel?.attributedText = nil
            } else {
                if let firstResult = filteredResults.first {
                    self.placeholderLabel?.attributedText = firstResult.attributedTitle
                } else {
                    self.placeholderLabel?.attributedText = nil
                }
            }
        }
    }
    
    // MARK: - Prepare for draw table result
    
    fileprivate func prepareDrawTableResult() {
        guard let frame = self.superview?.convert(self.frame, to: UIApplication.shared.keyWindow) else { return }
        if let keyboardFrame = keyboardFrame {
            var newFrame = frame
            newFrame.size.height += CGFloat(minimumItemsForDownDirection) * cellHeight
            
            if keyboardFrame.intersects(newFrame) {
                direction = .up
            } else {
                direction = .down
            }
            
            redrawSearchTableView()
        } else {
            if self.center.y + cellHeight > UIApplication.shared.keyWindow!.frame.size.height {
                direction = .up
            } else {
                direction = .down
            }
        }
    }
}

extension SearchTextField: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.isHidden = !interactedWith || (filteredResults.count == 0)
        shadowView?.isHidden = !interactedWith || (filteredResults.count == 0)
        
        if maxNumberOfResults > 0 {
            return min(filteredResults.count, maxNumberOfResults)
        } else {
            return filteredResults.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: SearchTextField.cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: SearchTextField.cellIdentifier)
        }
        
        cell!.backgroundColor = UIColor.clear
        cell!.layoutMargins = UIEdgeInsets.zero
        cell!.preservesSuperviewLayoutMargins = false
        cell!.textLabel?.numberOfLines = 0
        
        cell!.textLabel?.text = filteredResults[(indexPath as NSIndexPath).row].title
        cell!.detailTextLabel?.text = filteredResults[(indexPath as NSIndexPath).row].subtitle
        cell!.textLabel?.attributedText = filteredResults[(indexPath as NSIndexPath).row].attributedTitle
        cell!.detailTextLabel?.attributedText = filteredResults[(indexPath as NSIndexPath).row].attributedSubtitle
        
        cell!.imageView?.image = filteredResults[(indexPath as NSIndexPath).row].image
        
      
        
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight 
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if itemSelectionHandler == nil {
            self.text = filteredResults[(indexPath as NSIndexPath).row].title
        } else {
            let index = indexPath.row
            itemSelectionHandler!(filteredResults, index)
        }
        if let count = textCount {
            let remainingCount = count - (text?.count ?? 0)
            textCountLabel.text = "\(remainingCount)"
        }
        
        // remove results from tableview on selecting an item from the list
        clearResults()
        
        // dismiss keyboard
        resignFirstResponder()
    }
}

extension SearchTextField: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string.isASCII else { return false }
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if let count = textCount {
            if updatedText.count <= count {
                let remainingCount = count - updatedText.count
                textCountLabel.text = "\(remainingCount)"
            } else if updatedText.count < currentText.count {
                return true
            }
            else {
                return false
            }
        }
        return true
    }
}

////////////////////////////////////////////////////////////////////////
// Filter Item

open class SearchTextFieldItem {
    // Private vars
    fileprivate var attributedTitle: NSMutableAttributedString?
    fileprivate var attributedSubtitle: NSMutableAttributedString?
    
    // Public interface
    public var title: String
    public var subtitle: String?
    public var image: UIImage?
    
    public init(title: String, subtitle: String?, image: UIImage?) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
    
    public init(title: String, subtitle: String?) {
        self.title = title
        self.subtitle = subtitle
    }
    
    public init(title: String) {
        self.title = title
    }
}

public typealias SearchTextFieldItemHandler = (_ filteredResults: [SearchTextFieldItem], _ index: Int) -> Void

////////////////////////////////////////////////////////////////////////
// Suggestions List Direction

enum ListDirection {
    case down
    case up
}

