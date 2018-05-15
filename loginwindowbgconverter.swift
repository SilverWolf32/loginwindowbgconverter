import Foundation
import AppKit.NSImage

func printUsage() {
	print("usage: \(CommandLine.arguments[0]) \u{1B}[4mimage-file\u{1B}[0m")
}

guard CommandLine.arguments.indices.contains(1) else {
	printUsage()
	exit(1)
}
let inputFile = CommandLine.arguments[1]

// print("Filename: \(inputFile)")

guard let image = NSImage(contentsOfFile: inputFile) else {
	print("\(CommandLine.arguments[0]): cannot load image from \(inputFile)")
	exit(2)
}
