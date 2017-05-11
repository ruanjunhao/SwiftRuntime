//
//  UIButton+extension.swift
//  SwiftRuntime
//
//  Created by charles on 2017/5/11.
//  Copyright © 2017年 charles. All rights reserved.
//

import UIKit

extension UIButton {
    
    private struct AssociatedKeys {
        static var xlx_defaultInterval:TimeInterval = 0.5
        static var xlx_customInterval = "xlx_customInterval"
        static var xlx_ignoreInterval = "xlx_ignoreInterval"
    }
    var customInterval: TimeInterval {
        get {
            let xlx_customInterval = objc_getAssociatedObject(self, &AssociatedKeys.xlx_customInterval)
            if let time = xlx_customInterval {
                return time as! TimeInterval
            }else{
                return AssociatedKeys.xlx_defaultInterval
            }
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.xlx_customInterval,  newValue as TimeInterval ,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var ignoreInterval: Bool {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.xlx_ignoreInterval) != nil)
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.xlx_ignoreInterval, newValue as Bool, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    override open class func initialize() {
        if self == UIButton.self {
            DispatchQueue.once(NSUUID().uuidString, block: {
                let systemSel = #selector(UIButton.sendAction(_:to:for:))
                let swizzSel = #selector(UIButton.mySendAction(_:to:for:))
                
                let systemMethod = class_getInstanceMethod(self, systemSel)
                let swizzMethod = class_getInstanceMethod(self, swizzSel)
                
                
                let isAdd = class_addMethod(self, systemSel, method_getImplementation(swizzMethod), method_getTypeEncoding(swizzMethod))
                
                if isAdd {
                    class_replaceMethod(self, swizzSel, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
                }else {
                    method_exchangeImplementations(systemMethod, swizzMethod);
                }
            })
        }
    }
    
    private dynamic func mySendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        if !ignoreInterval {
            isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+customInterval, execute: { [weak self] in
                self?.isUserInteractionEnabled = true
            })
        }
        mySendAction(action, to: target, for: event)
    }
}
