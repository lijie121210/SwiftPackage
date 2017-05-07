// SwiftPackage


func run() throws {
    guard CommandLine.arguments.count == 2 else {
        print(SPTools.usage)
        SPTools.exitFailure()
        return
    }
    
    let builderType = CommandLine.Builder.make(CommandLine.arguments[1])
    
    guard builderType  != .unknow else {
        print(SPTools.usage)
        SPTools.exitFailure()
        return
    }
    
    try SPBuilder.make(builderType).buildPackage()
}

try run()
