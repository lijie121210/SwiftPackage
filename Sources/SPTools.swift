//
//  SPTools.swift
//  SwiftPackage
//
//  Created by viwii on 2017/5/6.
//
//

import Foundation

public struct SPTools {
    
    static var usage: String {
        return "\nUsage:\nSwiftPackage [command]\ncommand: init or -i; xcode or -x; xcode-open or -xo or xcode-o\n"
    }
    
    public static func exitSuccess() {
        Darwin.exit(EXIT_SUCCESS)
    }
    
    public static func exitFailure() {
        Darwin.exit(EXIT_FAILURE)
    }
}







