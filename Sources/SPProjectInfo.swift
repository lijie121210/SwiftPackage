//
//  SPProject.swift
//  SwiftPackage
//
//  Created by viwii on 2017/5/7.
//
//


import Foundation

public struct SPProjectInfo {
    
    // informations of project
    
    var workingDirectory: String = {
        let parts = #file.components(separatedBy: "/Sources/SwiftPackageLib")
        return parts.first ?? "./"
    }()
    
    public static var whoami: String = {
        let res = CommandLine.Cmds.whoami.execute().0?.trimmingCharacters(in: CharacterSet.newlines)
        return res ?? "*"
    }()
    
    public static var date: String {
        let date = Date()
        let form = DateFormatter()
        form.dateFormat = "yyyy/mm/dd"
        let str = form.string(from: date)
        return str
    }
    
    public static var projectDirectory: String = {
        return CommandLine.Cmds.pwd.execute().0!.trimmingCharacters(in: CharacterSet.newlines)
    }()
    
    public static var projectName: String = {
        var last = projectDirectory.components(separatedBy: "/").last!
        let a = last.startIndex
        let b = last.index(after: a)
        let firstChar = last.substring(to: b).uppercased()
        last.replaceSubrange(Range(a..<b), with: firstChar)
        return last
    }()
    
    public static var projectLib: String {
        return projectName + "Lib"
    }
    
    public static var projectApp: String {
        return projectName + "App"
    }
    
    // preload
    
    public static func fetchInfo() {
        let _ = whoami
        let _ = projectDirectory
    }
}
