//
//  TVAlert.swift
//  TVAlert
//
//  Copyright (c) 2016 adrum. All rights reserved.
//

import Foundation
import UIKit

private protocol TVAlertActionDelegate {
    func didChangeEnabled(action:TVAlertAction, enabled:Bool)
}

public class TVAlertAction: NSObject {
    public private(set) var title:String?
    public private(set) var handler:((TVAlertAction)->Void)?
    public private(set) var style: UIAlertActionStyle = .Default
    public var enabled:Bool = true {
        didSet {
            self.delegate?.didChangeEnabled(self, enabled: self.enabled)
        }
    }
    private var delegate:TVAlertActionDelegate?
    
    public convenience init(title: String?, style: UIAlertActionStyle, handler: ((TVAlertAction) -> Void)?) {
        self.init()
        self.title = title
        self.handler = handler
        self.style = style
    }
}

public class TVAlertController : UIViewController {
    
    // Private vars
    private var backgroundImage:UIImage?
    private var contentView:UIView?
    private var firstButtonTouched:UIButton?
    private var horizontalInset:CGFloat = 50
    
    // Colors
    private var buttonBackgroundColor: UIColor {
        get {
            return UIColor.blackColor().colorWithAlphaComponent(0.2)
        }
    }
    private var buttonTextColor: UIColor {
        get {
            return self.style == .Dark ? UIColor.whiteColor() : UIColor.blackColor().colorWithAlphaComponent(0.8)
        }
    }
    
    private var buttonHighlightedTextColor: UIColor {
        get {
            return self.style == .Dark ? UIColor.blackColor().colorWithAlphaComponent(0.8) : UIColor.whiteColor()
        }
    }
    
    // Alert vars
    public var message: String?
    public private(set) var actions: [TVAlertAction] = []
    public private(set) var textFields: [UITextField]?
    private var buttons: [UIButton] = []
    public var style: UIBlurEffectStyle = .Dark
    
    public var preferredAction: TVAlertAction?
    public private(set) var preferredStyle: UIAlertControllerStyle = .Alert
    
    // Customizations
    var autoDismiss:Bool = true
    var manageKeyboard:Bool = true
    var autosortActions:Bool = true
    var buttonShadows:Bool = true
    
    public convenience init(title: String?, message: String?, preferredStyle: UIAlertControllerStyle) {
        self.init()
        
        self.title = title
        self.message = message
        self.preferredStyle = preferredStyle
        
        self.takeScreenshot()
        self.modalPresentationStyle = .OverCurrentContext;
        self.modalTransitionStyle = .CrossDissolve
    }
    
    //MARK: View setup
    public override func loadView() {
        if let window = UIApplication.sharedApplication().keyWindow {
            self.view = UIView(frame: window.bounds)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBlurView()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setupContentView()
        self.setupObservers()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        self.removeObservers()
        super.viewWillDisappear(animated)
    }
    
    //MARK: Elements
    public func addAction(action: TVAlertAction) {
        action.delegate = self
        self.actions += [action]
    }
    
    public func addTextFieldWithConfigurationHandler(configurationHandler: ((UITextField) -> Void)?) {
        
        func configureTextField(t:UITextField) {
            let color = UIColor.blackColor().colorWithAlphaComponent(0.75)
            t.backgroundColor = self.style == .Dark ? UIColor.whiteColor().colorWithAlphaComponent(0.75) :UIColor.blackColor().colorWithAlphaComponent(0.09)
            t.textColor = color
            t.tintColor = color
            t.layer.cornerRadius = 5
        }
        
        if self.textFields == nil {
            self.textFields = []
        }
        
        let t = TVTextField()
        self.textFields! += [t]
        configureTextField(t)
        if let c = configurationHandler {
            c(t)
        }
    }
}

// MARK: - Touch interactions
extension TVAlertController {
    
    @objc private func didTapButton(sender:UIButton) {
        let a = self.actions[sender.tag]
        a.handler?(a)
        if self.autoDismiss {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func closeKeyboard() {
        self.view.endEditing(true)
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.firstButtonTouched = nil
        self.processButtonStates(touches, withEvent: event) { b, inside in
            if inside {
                self.firstButtonTouched = b
                if b.enabled {
                    b.sendActionsForControlEvents(.TouchDown)
                }
            }
        }
    }
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.processButtonStates(touches, withEvent: event) { b, inside in
            if b.enabled == false || self.firstButtonTouched == nil {
                b.highlighted = false
                return
            }
            if inside {
                b.sendActionsForControlEvents(.TouchDragEnter)
            } else {
                b.sendActionsForControlEvents(.TouchDragExit)
            }
        }
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.processButtonStates(touches, withEvent: event) { b, inside in
            b.highlighted = false
            if inside && b.enabled && self.firstButtonTouched != nil {
                
                b.sendActionsForControlEvents(.TouchUpInside)
            }
            self.closeKeyboard()
        }
    }
    
    private func processButtonStates(touches: Set<UITouch>, withEvent event: UIEvent?, eventHandler:((UIButton, Bool)->Void)? = nil) {
        for t in touches {
            let point = t.locationInView(self.contentView)
            
            for b in self.buttons {
                if let testPoint = self.contentView?.convertPoint(point, toView: b) {
                    let inside = b.pointInside(testPoint, withEvent:event)
                    b.highlighted = inside
                    eventHandler?(b, inside)
                }
            }
        }
    }
}

// MARK: - Setup
private extension TVAlertController {
    
    private func setupContentView() {
        
        if self.contentView == nil {
            
            var views = [UIView]()
            let contentView = UIView()
            self.view.addSubview(contentView)
            
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Vertical)
            contentView.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
            
            // Vertical Constraints
            self.contentView = contentView
            
            self.sortButtons()
            self.setupLabels(&views)
            self.setupTextFields(&views)
            self.setupButtons(&views)
            self.setupConstraints(&views)
            
            contentView.layoutIfNeeded()
            contentView.sizeToFit()
            
            let height = abs((views.first?.frame.minY ?? 0) - (views.last?.frame.maxY ?? 0))
            
            contentView.centerVerticallyInSuperview()
            contentView.centerHorizontallyInSuperview()
            contentView.constrainSizeTo(CGSize(width: self.view.bounds.width - (self.horizontalInset * 2), height: height))
            
            
            contentView.layoutIfNeeded()
            
            for b in self.buttons {
                b.layoutSubviews()
            }
            
        }
        
    }
    
    private func sortButtons() {
        
        if self.autosortActions == false {
            return
        }
        
        let normal = self.actions.filter({$0.style != .Cancel})
        let cancel = self.actions.filter({$0.style == .Cancel})
        var actions = normal
        actions.appendContentsOf(cancel)
        if self.actions.count == 2 {
            actions = cancel
            actions.appendContentsOf(normal)
        }
        self.actions = actions
    }
    
    private func setupLabels(inout views:[UIView]) {
        
        func configureLabel(label:UILabel) {
            label.textAlignment = .Center
            label.numberOfLines = 0
            label.lineBreakMode = NSLineBreakMode.ByWordWrapping
            label.textColor = self.buttonTextColor
        }
        
        if let t = self.title {
            let titleView = TVLabel()
            titleView.text = t
            titleView.font = UIFont.boldSystemFontOfSize(18)
            configureLabel(titleView)
            views += [titleView]
        }
        
        if let m = self.message {
            let messageView = TVLabel()
            messageView.text = m
            messageView.font = UIFont.systemFontOfSize(16)
            configureLabel(messageView)
            views += [messageView]
        }
        
    }
    
    private func setupTextFields(inout views:[UIView]) {
        
        guard let textFields = self.textFields else {
            return
        }
        
        for (_, textfield) in textFields.enumerate() {
            views += [textfield]
        }
    }
    
    private func setupButtons(inout views:[UIView]) {
        
        func configureButton(button:TVButton, action:TVAlertAction) {
            button.setTitle(action.title, forState: .Normal)
            button.enabled = action.enabled
            button.translatesAutoresizingMaskIntoConstraints = false
            button.userInteractionEnabled = false
            button.layer.cornerRadius = 5
            button.shadows = self.buttonShadows
            button.addTarget(self, action: #selector(TVAlertController.didTapButton(_:)), forControlEvents: .TouchUpInside)
            var buttonTextColor = self.buttonTextColor
            switch action.style {
            case .Default:
                break
            case .Cancel:
                if self.preferredAction == nil {
                    button.titleLabel?.font = UIFont.boldSystemFontOfSize(button.titleLabel!.font.pointSize)
                }
                break
            case .Destructive:
                buttonTextColor = UIColor.redColor()
                break
            }
            
            if let a = self.preferredAction where a == action {
                button.titleLabel?.font = UIFont.boldSystemFontOfSize(button.titleLabel!.font.pointSize)
            }
            
            button.setTitleColor(buttonTextColor, forState: .Normal)
            button.setTitleColor(self.buttonHighlightedTextColor, forState: .Highlighted)
            button.setBackgroundColor(self.buttonBackgroundColor, forState: .Normal)
            button.setBackgroundColor(buttonTextColor, forState: .Highlighted)
        }
        
        var containerView:UIView? = nil
        let count = self.actions.count
        
        for (i, action) in self.actions.enumerate() {
            let button = TVButton(type: .Custom)
            self.buttons += [button]
            button.tag = i
            configureButton(button, action: action)
            if count == 2 {
                if containerView == nil {
                    let c = UIView()
                    containerView = c
                    views += [c]
                }
                containerView?.addSubview(button)
            } else {
                views += [button]
            }
        }
        self.setupPairedConstraintsIfNeeded(containerView)
    }
    
    private func setupPairedConstraintsIfNeeded(containerView:UIView?) {
        if let c = containerView where self.buttons.count == 2 {
            c.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[button0]-20-[button1]|", options:[.AlignAllCenterY, .AlignAllBottom, .AlignAllTop], metrics: nil, views: ["button0":self.buttons[0],"button1":self.buttons[1]]))
            c.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[button0]|", options:[.AlignAllBottom, .AlignAllTop], metrics: nil, views: ["button0":self.buttons[0],"button1":self.buttons[1]]))
            c.addConstraint(NSLayoutConstraint(item: self.buttons[0], attribute: .Width, relatedBy: .Equal, toItem: self.buttons[1], attribute: .Width, multiplier: 1, constant: 0))
        }
    }
    
    private func setupConstraints(inout views:[UIView]) {
        
        if views.count < 1 {
            return
        }
        
        var verticalString = "V:"
        var dict:[String:AnyObject] = [:]
        let limit = views.count - 1
        var index = 0
        var prev:UIView?
        
        for (i,v) in views.enumerate() {
            
            let name = "view\(i)"
            dict[name] = v
            
            v.translatesAutoresizingMaskIntoConstraints = false
            v.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Vertical)
            v.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
            self.contentView?.addSubview(v)
            
            var spacing:CGFloat = 10
            var height:CGFloat = 36
            
            if v is UIButton {
                spacing = 15
            }
            
            if let label = v as? UILabel {
                
                let maxWidth = self.view.bounds.width - (self.horizontalInset * 2)
                let maxHeight : CGFloat = 10000
                height = label.attributedText?.boundingRectWithSize(CGSizeMake(maxWidth, maxHeight), options: .UsesLineFragmentOrigin, context: nil).size.height ?? 30
            }
            
            if prev != nil {
                verticalString += "-\(spacing)-"
            }
            
            verticalString += "[\(name)]"
            
            if index == limit {
                verticalString += "|"
            }
            
            v.centerHorizontallyInSuperview()
            v.constrainSizeToHeight(height)
            
            index += 1
            prev = v
        }
        
        // Vertical Constraints
        self.contentView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(verticalString, options:[.AlignAllLeft, .AlignAllRight], metrics: nil, views: dict))
        
        self.contentView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view0]|", options:[], metrics: nil, views: dict))
    }
    
}

// MARK: - TVAlertActionDelegate
extension TVAlertController: TVAlertActionDelegate {
    
    private func didChangeEnabled(action:TVAlertAction, enabled: Bool) {
        
        let index = (self.actions as NSArray).indexOfObject(action)
        self.buttons[index].enabled = enabled
        
    }
}

// MARK: - Blur view
private extension TVAlertController {
    private func setupBlurView() {
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.image = self.backgroundImage
        imageView.contentMode = .ScaleAspectFill
        imageView.contentMode = .ScaleToFill
        self.view.addSubview(imageView)
        
        let blurEffect = UIBlurEffect(style: self.style)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = imageView.bounds
        view.addSubview(blurredEffectView)
    }
    
    private func takeScreenshot() {
        let screen = UIScreen.mainScreen()
        let snapshotView = screen.snapshotViewAfterScreenUpdates(true)
        UIGraphicsBeginImageContextWithOptions(snapshotView.bounds.size, true, 0)
        snapshotView.drawViewHierarchyInRect(snapshotView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.backgroundImage = image
    }
}

// MARK:- Keyboard moving
private extension TVAlertController {
    
    private func setupObservers() {
        
        if self.manageKeyboard {
            return
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(TVAlertController.keyboardWillAppear(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(TVAlertController.keyboardWillDisappear(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    private func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func keyboardWillAppear(notification: NSNotification){
        self.animateContentViewYCenterTo(-30)
    }
    
    @objc private func keyboardWillDisappear(notification: NSNotification){
        self.animateContentViewYCenterTo(0)
    }
    
    private func animateContentViewYCenterTo(y:CGFloat) {
        
        guard let contentView = self.contentView else {
            return
        }
        
        for c in self.view.constraints {
            if c.firstItem as! NSObject == contentView && c.firstAttribute == NSLayoutAttribute.CenterY {
                c.constant = y
            }
        }
        
        UIView.animateWithDuration(0.33) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK:- External Extensions

// MARK: First responder
private extension UIView {
    private func findFirstResponder() -> UIView? {
        for subView in self.subviews {
            if subView.isFirstResponder() {
                return subView
            }
            
            if let recursiveSubView = subView.findFirstResponder() {
                return recursiveSubView
            }
        }
        
        return nil
    }
}

// MARK: AutoLayout helpers
private extension UIView {
    
    private func centerInSuperview() {
        self.centerHorizontallyInSuperview()
        self.centerVerticallyInSuperview()
    }
    
    private func centerHorizontallyInSuperview(){
        self.superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: self.superview, attribute: .CenterX, multiplier: 1, constant: 0))
    }
    
    private func centerVerticallyInSuperview(){
        self.superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: self.superview, attribute: .CenterY, multiplier: 1, constant: 0))
    }
    
    private func constrainSizeTo(size:CGSize){
        self.constrainSizeToWidth(size.width)
        self.constrainSizeToHeight(size.height)
    }
    
    private func constrainSizeToHeight(size:CGFloat){
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: size))
    }
    
    private func constrainSizeToWidth(size:CGFloat){
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: size))
    }
    
}

// MARK: Image with color -- for button background
private extension UIImage {
    private static func imageWithColor(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK:- TVButton
private class TVButton:UIButton {
    
    var shadows:Bool = true
    private var backgroundColorStates:[String:UIColor] = [:]
    override var enabled: Bool {
        didSet {
            self.alpha = enabled ? 1 : 0.3
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            self.backgroundColorStates["\(UIControlState.Normal)"] = self.backgroundColor ?? UIColor.clearColor()
        }
    }
    
    override var highlighted: Bool {
        didSet {
            let state = self.highlighted ? UIControlState.Highlighted : UIControlState.Normal
            if let c = self.backgroundColorStates["\(state)"] {
                self.layer.backgroundColor = c.CGColor
            }
            self.layer.shadowColor = self.highlighted ? UIColor.blackColor().CGColor : UIColor.clearColor().CGColor
            self.layer.shadowRadius = 4;
            self.layer.shadowOpacity = 0.7;
            self.layer.shadowOffset = CGSize(width: 0, height: 2);
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    private func commonInit() {
        
        self.addTarget(self, action: #selector(TVButton.grow), forControlEvents: .TouchDown)
        self.addTarget(self, action: #selector(TVButton.grow), forControlEvents: .TouchDragEnter)
        self.addTarget(self, action: #selector(TVButton.normal), forControlEvents: .TouchDragExit)
        self.addTarget(self, action: #selector(TVButton.normal), forControlEvents: .TouchUpInside)
    }
    
    @objc private func grow() {
        self.transformToSize(1.15)
    }
    
    @objc private func normal() {
        self.transformToSize(1.0)
    }
    
    @objc private func shrink() {
        self.transformToSize(0.8)
    }
    
    private func transformToSize(scale:CGFloat) {
        UIView.beginAnimations("button", context: nil)
        UIView.setAnimationDuration(0.1)
        self.transform = CGAffineTransformMakeScale(scale,scale);
        UIView.commitAnimations()
    }
    
    func setBackgroundColor(color: UIColor, forState state: UIControlState) {
        self.backgroundColorStates["\(state)"] = color
        
        if state == .Normal {
            self.backgroundColor = color
        }
    }
}

// MARK:- TVTextField
private class TVTextField: UITextField {
    let inset: CGFloat = 10
    
    // placeholder position
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , inset , inset)
    }
    
    // text position
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , inset , inset)
    }
    
    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, inset, inset)
    }
}

// MARK:- TVLabel
private class TVLabel: UILabel {
    
    private override func layoutSubviews() {
        super.layoutSubviews()
        self.preferredMaxLayoutWidth = CGRectGetWidth(self.bounds)
        super.layoutSubviews()
    }
}