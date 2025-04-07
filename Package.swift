// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
/// use local package path
let packageLocal: Bool = false

let oscaEssentialsVersion = Version("1.1.0")
let oscaTestCaseExtensionVersion = Version("1.1.0")
let oscaDefectVersion = Version("1.1.0")
let skyFloatingLabelTextFieldVersion = Version("3.8.0")
let swiftSpinnerVersion = Version("2.2.0")

let package = Package(
  name: "OSCADefectUI",
  defaultLocalization: "de",
  platforms: [.iOS(.v13)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "OSCADefectUI",
      targets: ["OSCADefectUI"]),
  ],
  dependencies: [
    // OSCAEssentials
    packageLocal ? .package(path: "../OSCAEssentials") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscaessentials-ios.git",
             .upToNextMinor(from: oscaEssentialsVersion)),
    // OSCADefect
    packageLocal ? .package(path: "../OSCADefect") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscadefect-ios.git",
             .upToNextMinor(from: oscaDefectVersion)),
    // SkyFloatingLabelTextField
    .package(url: "https://github.com/Skyscanner/SkyFloatingLabelTextField.git",
             .upToNextMinor(from: skyFloatingLabelTextFieldVersion)),
    /* SwiftSpinner */
    .package(url: "https://github.com/icanzilb/SwiftSpinner.git",
             .upToNextMinor(from: swiftSpinnerVersion)),
    // OSCATestCaseExtension
    packageLocal ? .package(path: "../OSCATestCaseExtension") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscatestcaseextension-ios.git",
             .upToNextMinor(from: oscaTestCaseExtensionVersion)),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "OSCADefectUI",
      dependencies: [/* OSCAEssentials */
                     .product(name: "OSCAEssentials",
                              package: packageLocal ? "OSCAEssentials" : "oscaessentials-ios"),
                     .product(name: "OSCADefect",
                              package: packageLocal ? "OSCADefect" : "oscadefect-ios"),
                     .product(name: "SkyFloatingLabelTextField",
                              package: "SkyFloatingLabelTextField"),
                     .product(name: "SwiftSpinner",
                              package: "SwiftSpinner")],
      path: "OSCADefectUI/OSCADefectUI",
      exclude: ["Info.plist",
                "SupportingFiles"],
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "OSCADefectUITests",
      dependencies: ["OSCADefectUI",
                     .product(name: "OSCATestCaseExtension",
                              package: packageLocal ? "OSCATestCaseExtension" : "oscatestcaseextension-ios")],
      path: "OSCADefectUI/OSCADefectUITests",
      exclude: ["Info.plist"],
      resources: [.process("Resources")]),
  ]
)
