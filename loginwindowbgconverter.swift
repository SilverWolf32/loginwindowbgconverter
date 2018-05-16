import Foundation
// import AppKit.NSImage
// import AppKit.NSScreen
import AppKit

func printUsage() {
	print("""
	usage: \(CommandLine.arguments[0]) \u{1B}[4mimage-file\u{1B}[0m
	It needs to be run as root, as it saves to /Library/Caches.
	""")
}

guard CommandLine.arguments.indices.contains(1) else {
	printUsage()
	exit(1)
}
let inputFile = CommandLine.arguments[1]

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
let pngData = newImage.representation(using: .png, properties: [:])!
do {
	// try pngData.write(to: URL(fileURLWithPath: "\(NSHomeDirectory())/Desktop/com.apple.desktop.admin.png"))
	try pngData.write(to: URL(fileURLWithPath: "/Library/Caches/com.apple.desktop.admin.png"))
} catch {
	print("\(CommandLine.arguments[0]): can't write image data: \(error)")
	print("(do you have write permission?)")
	exit(1)
}