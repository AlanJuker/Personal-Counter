// Renders the Personal Counter app icon: tally marks over the app's
// emerald -> ocean gradient. Produces the light, dark and tinted variants
// iOS expects, full-bleed (the system applies the rounded mask itself).

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let size: CGFloat = 1024

struct RGB {
    let r: CGFloat, g: CGFloat, b: CGFloat
    var components: [CGFloat] { [r, g, b, 1] }
}

let emerald = RGB(r: 0.13, g: 0.78, b: 0.60)
let ocean = RGB(r: 0.13, g: 0.71, b: 0.95)
let ink = RGB(r: 0.05, g: 0.06, b: 0.07)
let white = RGB(r: 1, g: 1, b: 1)
let grayLight = RGB(r: 0.92, g: 0.92, b: 0.92)
let grayDark = RGB(r: 0.10, g: 0.10, b: 0.10)

func makeContext() -> CGContext {
    let space = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(
        data: nil,
        width: Int(size),
        height: Int(size),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: space,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        fatalError("Could not create bitmap context")
    }
    context.setAllowsAntialiasing(true)
    context.interpolationQuality = .high
    return context
}

func fillGradient(_ context: CGContext, from: RGB, to: RGB) {
    let space = CGColorSpaceCreateDeviceRGB()
    let colors = [
        CGColor(colorSpace: space, components: from.components)!,
        CGColor(colorSpace: space, components: to.components)!,
    ] as CFArray
    guard let gradient = CGGradient(colorsSpace: space, colors: colors, locations: [0, 1]) else { return }
    context.drawLinearGradient(
        gradient,
        start: CGPoint(x: 0, y: size),
        end: CGPoint(x: size, y: 0),
        options: []
    )
}

func fillSolid(_ context: CGContext, _ color: RGB) {
    context.setFillColor(red: color.r, green: color.g, blue: color.b, alpha: 1)
    context.fill(CGRect(x: 0, y: 0, width: size, height: size))
}

/// The tally-mark path: four uprights plus a diagonal strike.
func tallyPaths() -> (bars: CGPath, strike: CGPath) {
    let barWidth: CGFloat = 64
    let barHeight: CGFloat = 430
    let gap: CGFloat = 132
    let count = 4
    let groupWidth = CGFloat(count - 1) * gap + barWidth
    let originX = (size - groupWidth) / 2
    let originY = (size - barHeight) / 2

    let bars = CGMutablePath()
    for index in 0..<count {
        let rect = CGRect(
            x: originX + CGFloat(index) * gap,
            y: originY,
            width: barWidth,
            height: barHeight
        )
        bars.addRoundedRect(in: rect, cornerWidth: barWidth / 2, cornerHeight: barWidth / 2)
    }

    let strike = CGMutablePath()
    strike.move(to: CGPoint(x: originX - 46, y: originY + 66))
    strike.addLine(to: CGPoint(x: originX + groupWidth + 46, y: originY + barHeight - 66))

    return (bars, strike)
}

func drawTally(_ context: CGContext, color: RGB, gradient: (RGB, RGB)? = nil) {
    let (bars, strike) = tallyPaths()
    let barWidth: CGFloat = 64
    let strikeOutline = strike.copy(strokingWithWidth: barWidth, lineCap: .round, lineJoin: .round, miterLimit: 10)

    // Clipped one path at a time: a single combined clip would cancel the
    // overlaps under the nonzero winding rule and hollow out the crossings.
    for path in [bars, strikeOutline] {
        context.saveGState()
        context.addPath(path)
        context.clip()
        if let gradient {
            fillGradient(context, from: gradient.0, to: gradient.1)
        } else {
            fillSolid(context, color)
        }
        context.restoreGState()
    }
}

func write(_ context: CGContext, to path: String) {
    guard let image = context.makeImage() else { fatalError("No image") }
    let url = URL(fileURLWithPath: path)
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        fatalError("No destination for \(path)")
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else { fatalError("Could not write \(path)") }
    print("wrote \(path)")
}

let outputDirectory = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."

// Light: gradient background, white marks.
let light = makeContext()
fillGradient(light, from: emerald, to: ocean)
drawTally(light, color: white)
write(light, to: "\(outputDirectory)/AppIcon.png")

// Dark: near-black background, gradient marks.
let dark = makeContext()
fillSolid(dark, ink)
drawTally(dark, color: white, gradient: (emerald, ocean))
write(dark, to: "\(outputDirectory)/AppIcon-Dark.png")

// Tinted: grayscale, the system applies the user's tint.
let tinted = makeContext()
fillSolid(tinted, grayDark)
drawTally(tinted, color: grayLight)
write(tinted, to: "\(outputDirectory)/AppIcon-Tinted.png")
