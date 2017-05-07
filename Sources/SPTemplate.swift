//
//  SPFile.swift
//  SwiftPackage
//
//  Created by viwii on 2017/5/6.
//
//

import Foundation


public enum SPTemplate {
    case file(String)
    case test
    case package
    
    public var content: String {
        switch self {
        case .file(let filename):   return SwiftFileTemplate(file: filename).content
        case .test:                 return SwiftTestTemplate().content
        case .package:              return SwiftPackTemplate().content
        }
    }
}


protocol TemplateContent {
    
    var content: String { get }
    
    var comment: String { get }
}

extension TemplateContent {
    
    func comment(file: String) -> String {
        let p = SPProjectInfo.projectName
        let w = SPProjectInfo.whoami
        let d = SPProjectInfo.date
        return "//\n//  \(file)\n//  \(p)\n//\n//  Created by \(w) on \(d).\n//\n//\n\n"
    }
}

/*
 //
 //  file
 //  ProjectName
 //
 //  Created by whoami on date.
 //
 //
 
 import Foundation / import ProjectNameLib
 */
struct SwiftFileTemplate: TemplateContent {
    
    var content: String = ""
    
    var comment: String = ""
    
    init(file: String) {
        let file = file.suffixing(with: ".swift")
        
        comment = comment(file: file)
        
        if file == "main.swift" {
            content = comment + "\n//import \(SPProjectInfo.projectLib)\n"
        } else {
            content = comment + "\nimport Foundation\n"
        }
    }
}

/*
 //
 //  ProjectNameTestCase.swift
 //  Patterns
 //
 //  Created by viwii on 2017/5/5.
 //
 //
 
 import XCTest
 
 @testable import ProjectNameLib
 
 class ProjectNameTestCase: XCTestCase {
 
    func testExample() {
    }
 
 }
 */
struct SwiftTestTemplate: TemplateContent {
    
    var content: String = ""
    
    var comment: String = ""

    init() {
        let file = SPProjectInfo.projectName.appending("TestCase.swift")
        
        comment = comment(file: file)
        
        let test = "class \(SPProjectInfo.projectName)TestCase: XCTestCase {\n\tfunc testExample() {\n\t}\n}"
        
        content = comment + "\nimport XCTest\n@testable import \(SPProjectInfo.projectLib)\n\(test)"
        
    }
}


struct SwiftPackTemplate: TemplateContent {
    
    var content: String
    
    var comment: String = "// swift package"
    
    init() {
        content = "import PackageDescription\nlet package = Package(\n\tname: \"\(SPProjectInfo.projectName)\", \n\ttargets: [\n\t\tTarget(name: \"\(SPProjectInfo.projectName)App\", dependencies: [\"\(SPProjectInfo.projectName)Lib\"]), \n\t\tTarget(name: \"\(SPProjectInfo.projectName)Lib\", dependencies: [])\n\t], \n\tdependencies: []\n)\n"
    }
}
