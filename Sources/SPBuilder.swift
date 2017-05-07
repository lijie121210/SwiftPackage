//
//  SPBuilder.swift
//  SwiftPackage
//
//  Created by viwii on 2017/5/6.
//
//

import Foundation

// ------------------> 定义一些扩展

public extension CommandLine {
    
    // supporting commands
    public enum Builder {
        case `init`
        case xcode
        case xcodeOpen
        case unknow
        
        public static func make(_ text: String) -> Builder {
            switch text {
            case "init", "-i":          return .init
            case "xcode", "-x":         return .xcode
            case "xcode-open", "-xo", "xcode-o":    return .xcodeOpen
            default:                    return .unknow
            }
        }
    }
    
    // using shell commands
    enum Cmds {
        static let pwd = ["pwd"]
        static let whoami = ["whoami"]
        static let swiftinit = ["swift","package","init","--type","executable"]
        static let xcodeproj = ["swift","package","generate-xcodeproj"]
        static let openXcodeproj = ["open","\(SPProjectInfo.projectName).xcodeproj"]
        static let build = ["swift","build"]

        case open(String)
        
        var xcodeproj: [String] {
            if case let .open(x) = self {
                return ["open","\(x).xcodeproj"]
            }
            return []
        }
    }
    
    // commands execution
    @discardableResult
    public static func shell(_ arguments: String...) -> (String?, Int32) {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = arguments
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        
        task.waitUntilExit()
        
        return (output, task.terminationStatus)
    }
}

// 执行命令行命令的另一种方式
public extension Array where Element == String {
    
    @discardableResult
    public func execute() -> (String?, Int32) {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = self
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        
        task.waitUntilExit()
        
        return (output, task.terminationStatus)
    }
}

// 使一个字符串以固定字符结尾
public extension String {
    
    public mutating func suffix(with end: String) {
        if hasSuffix(end) {
            return
        } else {
            append(end)
        }
    }
    
    public func suffixing(with end: String) -> String {
        if hasSuffix(end) {
            return self
        } else {
            return self + end
        }
    }
}

// <------------------


// ------------------>

// 建造者接口定义
public protocol Builder {
    
    func buildPackage() throws
}

// 对外提供建造者接口实现
public class SPBuilder {
    
    public class func make(_ type: CommandLine.Builder) -> Builder {
        switch type {
        case .init:         return InitBuilder()
        case .xcode:        return XcodeBuilder(isOpening: false)
        case .xcodeOpen:    return XcodeBuilder(isOpening: true)
        case .unknow:       return EmptyBuilder()
        }
    }
}

// <------------------


extension Builder {
    
    // ------------------>

    private var workDir: String {
        return SPProjectInfo.projectDirectory.suffixing(with: "/")
    }
    
    private var sources: String {
        return workDir.appending("Sources")
    }
    
    private var sprefix: String {
        return sources.suffixing(with: "/").appending(SPProjectInfo.projectName)
    }
    
    private var lib: String {
        return sprefix.appending("Lib")
    }
    
    private var app: String {
        return sprefix.appending("App")
    }
    
    private var errfile: String {
        return "\(SPProjectInfo.projectName)Error.swift"
    }
    private var err: String {
        return lib.suffixing(with: "/").appending(errfile)
    }
    
    private var from: String {
        return sources.suffixing(with: "/").appending("main.swift")
    }
    
    private var target: String {
        return app.suffixing(with: "/").appending("main.swift")
    }
    
    private var tests: String {
        return workDir.appending("Tests")
    }
    
    private var packageTest: String {
        return tests.suffixing(with: "/").appending("\(SPProjectInfo.projectName)Tests")
    }
    
    private var testcase: String {
        return packageTest.suffixing(with: "/").appending("\(SPProjectInfo.projectName)TestCase.swift")
    }
    
    private var xcodeproj: String {
        return workDir.appending("\(SPProjectInfo.projectName).xcodeproj")
    }
    
    // <------------------
    
    // create exectable swift package
    func buildPackageStructure() throws {
        print(#function)
        
        guard CommandLine.Cmds.swiftinit.execute().1 == 0 else {
            throw SPError.shellExeFailure
        }
    }
    
    // divide Sources into two module
    func buildSourcesModules() throws {
        print("building sources modules")
        if !FileManager.default.fileExists(atPath: sources) {
            try FileManager.default.createDirectory(atPath: sources, withIntermediateDirectories: false, attributes: nil)
        }
        if !FileManager.default.fileExists(atPath: lib) {
            try FileManager.default.createDirectory(atPath: lib, withIntermediateDirectories: false, attributes: nil)
        }
        if !FileManager.default.fileExists(atPath: app) {
            try FileManager.default.createDirectory(atPath: app, withIntermediateDirectories: false, attributes: nil)
        }
    }
    
    func buildError() throws {
        print("building error.swift")
        
        if FileManager.default.fileExists(atPath: err) {
            return
        }
        FileManager.default.createFile(atPath: err, contents: Data(), attributes: nil)
        try SPTemplate.file(errfile).content.write(toFile: err, atomically: false, encoding: .utf8)
    }
    
    // delete and recreate main.swift to app/
    func buildMain() throws {
        print("building main.swift")

        if FileManager.default.fileExists(atPath: from) {
            try FileManager.default.removeItem(atPath: from)
        }
        if FileManager.default.fileExists(atPath: target) {
            return
        }
        FileManager.default.createFile(atPath: target, contents: Data(), attributes: nil)
        try SPTemplate.file("main").content.write(toFile: target, atomically: false, encoding: .utf8)
    }
    
    // create test module
    func buildTestsModule() throws {
        print("building tests module")

        if FileManager.default.fileExists(atPath: packageTest) {
            return
        }
        if !FileManager.default.fileExists(atPath: tests) {
            try FileManager.default.createDirectory(atPath: tests, withIntermediateDirectories: false, attributes: nil)
        }
        try FileManager.default.createDirectory(atPath: packageTest, withIntermediateDirectories: false, attributes: nil)
    }
    
    // create testcase file
    func buildTestCase() throws {
        print("building default testcase")

        if FileManager.default.fileExists(atPath: testcase) {
            return
        }
        FileManager.default.createFile(atPath: testcase, contents: Data(), attributes: nil)
        try SPTemplate.test.content.write(toFile: testcase, atomically: false, encoding: .utf8)
    }
    
    // generate ProjectName.xcodeproj
    func buildXcodeproj() throws {
        print("building xcodeproj")

        if FileManager.default.fileExists(atPath: xcodeproj) {
            try FileManager.default.removeItem(atPath: xcodeproj)
        }
        CommandLine.Cmds.build.execute()
        CommandLine.Cmds.xcodeproj.execute()
    }
    
    // open ProjectName.xcodeproj
    func openXcodeproj() throws {
        print("opening xcodeproj ")

        if !FileManager.default.fileExists(atPath: xcodeproj) {
            try buildXcodeproj()
        }
        CommandLine.Cmds.open(SPProjectInfo.projectName).xcodeproj.execute()
    }
    
    // generate Package.swift
    func buildPackageFile() throws {
        print("building Package.swift")

        let d = workDir.appending("Package.swift")
        if FileManager.default.fileExists(atPath: d) {
            try FileManager.default.removeItem(atPath: d)
        }
        FileManager.default.createFile(atPath: d, contents: Data(), attributes: nil)
        try SPTemplate.package.content.write(toFile: d, atomically: false, encoding: .utf8)
    }
}


// The Builders

class EmptyBuilder: Builder {
    func buildPackage() throws {
        
    }
}

class InitBuilder: Builder {
    
    func buildPackage() throws {
        
        try buildPackageStructure()
        
        try buildSourcesModules()
        
        try buildMain()
        
        try buildError()
        
        try buildTestsModule()
        
        try buildTestCase()
        
        try buildPackageFile()
    }
}

class XcodeBuilder: InitBuilder {
    
    var isOpening: Bool
    
    init(isOpening: Bool) {
        self.isOpening = isOpening
    }
    
    override func buildPackage() throws {
        
        try super.buildPackage()
        
        try buildXcodeproj()
        
        if isOpening {
            
            try openXcodeproj()
        }
    }
}
