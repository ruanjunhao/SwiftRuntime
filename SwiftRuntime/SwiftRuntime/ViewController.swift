//
//  ViewController.swift
//  SwiftRuntime
//
//  Created by charles on 2017/5/11.
//  Copyright © 2017年 charles. All rights reserved.
//

import UIKit

class SimpleSwiftClass {
   dynamic var aBool:Bool = true
   dynamic var aInt:Int = 10
   dynamic var aDouble:Double = 3.1415926
   dynamic var aString:String = "SimpleSwiftClass"
   dynamic var aObj:AnyObject! = nil
    
   dynamic func testNoReturn() {
    }
}

class ViewController: UIViewController {
    
    var aBool:Bool = true
    var aInt:Int = 10
    var aDouble:Double = 3.1415926
    var aString:String = "SimpleSwiftClass"
    var aObj:AnyObject! = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 10, y: 50, width: 100, height: 100)
        btn.backgroundColor = UIColor.red
        btn.addTarget(self, action: #selector(click), for: .touchUpInside)
        view.addSubview(btn)
        
        
        showClassRuntime(SimpleSwiftClass.self);
        showClassRuntime(object_getClass(self));
        
        methodSwizze(cls:object_getClass(self), systemSel: #selector(viewDidAppear(_:)), swizzeSel: #selector(myViewDidAppear(_:)))
        
        myViewDidAppear(true)
        
    }
    
    func click() {
        print(#function)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(#function)
    }
    
    dynamic func myViewDidAppear(_ animated: Bool) {
        print(#function)
    }
    
    func testNoReturn() {
    }
    
    func testReturnBool() -> Bool {
        return true;
    }
    
    func testReturnInt() -> Int {
        return 10;
    }
    
    func testReturnDouble() -> Double {
        return 10.1111;
    }
    
    func testReturnString() -> String {
        return "a boy";
    }
    
    //OC中没有的TypeEncoding
    func testReturnTuple() -> (Bool,String) {
        return (true,"aaa");
    }
    func testReturnCharacter() -> Character {
        return "a";
    }
}

func methodSwizze(cls:AnyClass, systemSel:Selector,swizzeSel:Selector) {
    
    let systemMethod = class_getInstanceMethod(cls, systemSel)
    let swizzeMethod = class_getInstanceMethod(cls, swizzeSel)
    
    
    let isAdd = class_addMethod(cls, systemSel, method_getImplementation(swizzeMethod), method_getTypeEncoding(swizzeMethod))
    
    if isAdd {
        class_replaceMethod(cls, swizzeSel, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
    }else {
        method_exchangeImplementations(systemMethod, swizzeMethod);
    }
}

func showClassRuntime(_ aclass:AnyClass) {
    print(aclass)
    print("start methodList")
    var methodNum:UInt32 = 0
    let methodList = class_copyMethodList(aclass, &methodNum)
    for index in 0..<numericCast(methodNum) {
        let method:Method = methodList![index]!
        print(method_getName(method))
    }
    print("end methodList")
    
    
    print("start propertyList")
    var propertyNum:UInt32 = 0
    let propertyList = class_copyPropertyList(aclass, &propertyNum)
    for index in 0..<numericCast(propertyNum) {
        let property:objc_property_t = propertyList![index]!
        print(String(utf8String: property_getName(property)) ?? "")
    }
    print("end propertyList")
}


