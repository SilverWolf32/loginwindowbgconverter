//
// loginwindowbgconverter
// by SilverWolf
// 2018-09-27
// 
// This is free and unencumbered software released into the public domain. See COPYING.md for more information.
//

import Foundation
// import AppKit.NSImage
// import AppKit.NSScreen
import AppKit
import CoreImage

func printUsage() {
	print("""
	usage: \(CommandLine.arguments[0]) [--heif] \u{1B}[4mimage-file\u{1B}[0m
	It needs to be run as root, as it saves to /Library/Desktop Pictures.
	""")
}

var inputFile = ""
var useHEIF = false

guard CommandLine.arguments.indices.contains(1) else {
	printUsage()
	exit(1)
}
if CommandLine.arguments[1] == "--heif" {
	useHEIF = true
	guard CommandLine.arguments.indices.contains(2) else {
		printUsage()
		exit(1)
	}
	inputFile = CommandLine.arguments[2]
} else {
	inputFile = CommandLine.arguments[1]
}

// print("Filename: \(inputFile)")

guard let inputImage = NSImage(contentsOfFile: inputFile) else {
	print("\(CommandLine.arguments[0]): can't load image from \(inputFile)")
	exit(2)
}

let iw = inputImage.size.width
let ih = inputImage.size.height
let iaspect = Double(iw) / Double(ih)

// use System Profiler to get screen size

var sw = 0, sh = 0

enum ScreenSizeError: Error {
	case foundNil
}
do {
	let task = Process()
	if #available(macOS 10.13, *) {
		task.executableURL = URL(fileURLWithPath: "/bin/zsh")
	} else {
		task.launchPath = "/bin/zsh"
	}
	task.arguments = ["-f", "-c", "system_profiler SPDisplaysDataType | awk '/Resolution/{print $2, $4}' | head -n 1"]
	
	let stdoutPipe = Pipe()
	task.standardOutput = stdoutPipe
	
	if #available(macOS 10.13, *) {
		try task.run()
	} else {
		task.launch()
	}
	task.waitUntilExit()
	
	let data = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
	guard let text = String(data: data, encoding: .utf8) else {
		throw ScreenSizeError.foundNil
	}
	let sizes = (text as NSString).replacingOccurrences(of: "\n", with: "").components(separatedBy: " ")
	sw = Int(sizes[0]) ?? 0
	sh = Int(sizes[1]) ?? 0
	guard sw != 0 && sh != 0 else {
		throw ScreenSizeError.foundNil
	}
} catch {
	print("\(CommandLine.arguments[0]): can't get screen resolution")
	exit(3)
}

// print("Frame: \(frame)")

print("Screen size: \(sw)x\(sh)")

var nw = 0, nh = 0
var x = 0, y = 0 // offsets

let saspect = Double(sw) / Double(sh)
if saspect > iaspect { // screen is wider
	nw = sw
	nh = Int(Double(sw) / iaspect) // keep input image aspect ratio
	y = -1 * (nh - sh) / 2 // half the difference
} else { // screen is narrower
	nh = sh
	nw = Int(Double(sh) * iaspect)
	x = -1 * (nw - sw) / 2
}

// draw into new image
// let newImage = NSImage(size: NSMakeSize(CGFloat(sw), CGFloat(sh)))
// newImage.lockFocus()
guard let newImage = NSBitmapImageRep(bitmapDataPlanes: nil,
                                pixelsWide: Int(sw),
                                pixelsHigh: Int(sh),
                                bitsPerSample: 8,
                                samplesPerPixel: 4,
                                hasAlpha: true,
                                isPlanar: false,
                                colorSpaceName: .deviceRGB,
                                bytesPerRow: sw * 4,
                                bitsPerPixel: 32) else {
	print("\(CommandLine.arguments[0]): can't create bitmap image to draw into!")
	exit(2)
}

// let graphicsContext = NSGraphicsContext.current
NSGraphicsContext.saveGraphicsState()
let graphicsContext = NSGraphicsContext(bitmapImageRep: newImage)
NSGraphicsContext.current = graphicsContext
graphicsContext?.imageInterpolation = .high
let r = NSMakeRect(CGFloat(x), CGFloat(y), CGFloat(nw), CGFloat(nh))
print("drawing rect: \(r)")
inputImage.draw(in: r)

// newImage.unlockFocus()
graphicsContext?.flushGraphics()
NSGraphicsContext.restoreGraphicsState()

print("image size: \(newImage.size)")

// write to file
/* var proposedRect = CGRect(x: 0, y: 0, width: CGFloat(sw), height: CGFloat(sh))
guard let cgImage = newImage.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil) else {
	print("\(CommandLine.arguments[0]): can't get CGImage to save!")
	exit(4)
}
print("proposed rect is now \(proposedRect)") */
// let bitmapImageRep = NSBitmapImageRep(cgImage: cgImage)

if #available(macOS 10.14, *) { // macOS Mojave has a completely different system
	let targetFile = "/Library/Desktop Pictures/Mojave.heic"
	let origFile =  "/Library/Desktop Pictures/Mojave.heic.orig"
	if !FileManager.default.fileExists(atPath: origFile) { // no backup of original Mojave.heic
		print("Backing up original Mojave.heic (this should only happen once)")
		do {
			try FileManager.default.copyItem(atPath: targetFile, toPath: origFile)
		} catch {
			print("\(CommandLine.arguments[0]): \u{1B}[1mbackup failed, aborting!\u{1B}[0m \(error.localizedDescription)")
			exit(1)
		}
	}
	
	print("Saving to \(targetFile)")
	// actual writing
	var imageData: Data? = nil
	if useHEIF {
		guard let ciimage = CIImage(bitmapImageRep: newImage) else {
			print("\(CommandLine.arguments[0]): can't create CIImage from bitmap!")
			exit(2)
		}
		let context = CIContext()
		// let colorSpaceName = CGColorSpace.sRGB
		let colorSpaceName = CGColorSpace.displayP3
		guard let colorSpace = CGColorSpace(name: colorSpaceName) else {
			print("\(CommandLine.arguments[0]): can't get color space!")
			exit(2)
		}
		imageData = context.heifRepresentation(of: ciimage, format: .RGBA8, colorSpace: colorSpace)
	} else {
		imageData = newImage.representation(using: .jpeg, properties: [:])!
	}
	do {
		try imageData?.write(to: URL(fileURLWithPath: targetFile))
	} catch {
		print("\(CommandLine.arguments[0]): can't write image data: \(error)")
		print("(are you root?)")
		exit(1)
	}
} else {
	let targetFile = "/Library/Caches/com.apple.desktop.admin.png"
	print("Saving to \(targetFile)")
	let pngData = newImage.representation(using: .png, properties: [:])!
	do {
		// try pngData.write(to: URL(fileURLWithPath: "\(NSHomeDirectory())/Desktop/com.apple.desktop.admin.png"))
		try pngData.write(to: URL(fileURLWithPath: targetFile))
	} catch {
		print("\(CommandLine.arguments[0]): can't write image data: \(error)")
		print("(are you root?)")
		exit(1)
	}
}
