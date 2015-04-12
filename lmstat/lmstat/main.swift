//
//  main.swift
//  lmstat
//
//  Created by Dan Cong on 11/4/15.
//  Copyright (c) 2015 dancong. All rights reserved.
//

import Foundation

if C_ARGC != 3 {
    println("lmstat is a command line tool analyzing iOS LinkMap file.\nUsage: lmstat <LinkMap-file-path> <result-file-path>")
    exit(0)
}

let srcPath = String.fromCString(C_ARGV[1])
let destPath = String.fromCString(C_ARGV[2])

class SymbolSize {
    var file:String = ""
    var size:UInt = 0
    init(file:String, size:UInt) {
        self.file = file
        self.size = size
    }
}

println("Reading file: \(srcPath!)")
var error:NSError?

if let content = String(contentsOfFile:srcPath!, encoding:NSUTF8StringEncoding, error:&error) {
    var lines = content.componentsSeparatedByString("\n")
    println("Start analyzing \(lines.count) lines:")
    var readingFiles = false
    var readingSections = false
    var readingSymbol = false
    var filesMap = [String:String]()
    var filesSizeMap = [String:SymbolSize]()
    var interval:Double = 0
    var idx = 0
    for line in lines {
        
        println("Analyze line: \(++idx)")
        
        if line.hasPrefix("# Object files:") {
            readingFiles = true
        } else if line.hasPrefix("# Sections:") {
            readingFiles = false
            readingSections = true
        } else if line.hasPrefix("# Symbols:") {
            readingSections = false
            readingSymbol = true
        }
        
        if line.hasPrefix("#") == false {
            if readingFiles {
                var fileArr = split(line) {$0 == "\t"}
                filesMap[fileArr[0]] = fileArr[1]
            } else if readingSymbol {
                var start = NSDate().timeIntervalSince1970;
                var symbolArr = split(line) {$0 == "\t"}
                if symbolArr.count == 4 {
                    //Address Size File Name
                    var file = symbolArr[2];
                    var size:UInt = strtoul(symbolArr[1], nil, 16)
                    if let symbolSize = filesSizeMap[file] {
                        symbolSize.size += size;
                    } else {
                        filesSizeMap[file] = SymbolSize(file:file, size:size);
                    }
                }
                interval = NSDate().timeIntervalSince1970 - start
            }
        }
        if interval > 0 {
            var min = NSString(format: "%.1f", Double(lines.count - idx) * interval/60)
            println("Estimated time remaining: \(min) min")
        }
    }
    
    var fileSizes = [SymbolSize]()
    fileSizes += filesSizeMap.values
    fileSizes.sort({$0.size > $1.size})
    var finalSort:String = ""
    for fs in fileSizes {
        var size = NSString(format: "%.2fM", Double(fs.size)/1024/1024)
        finalSort += "\(size)\t\(filesMap[fs.file]!)\n"
    }
    
    finalSort.writeToFile(destPath!, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
    println("Statistics complete, see result in \(destPath!)")
} else {
    println(error)
}

