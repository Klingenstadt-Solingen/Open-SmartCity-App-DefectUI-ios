//
//  OSCADefectUITests.swift
//  OSCADefectUI
//
//  Created by Ömer Kurutay on 22.02.22.
//  Reviewed by Stephan Breidenbach on 21.06.22
//
#if canImport(XCTest) && canImport(OSCATestCaseExtension)
import XCTest
import OSCAEssentials
import OSCATestCaseExtension
@testable import OSCADefectUI
@testable import OSCADefect

final class OSCADefectUITests: XCTestCase {
  static let moduleVersion = "1.0.4"
  
  override func setUpWithError() throws {
    try super.setUpWithError()
  }// end override func setupWithError
  
  func testModuleInit() throws -> Void {
    let uiModule = try makeDevUIModule()
    XCTAssertNotNil(uiModule)
    XCTAssertEqual(uiModule.version, OSCADefectUITests.moduleVersion)
    XCTAssertEqual(uiModule.bundlePrefix, "de.osca.defect.ui")
    let bundle = OSCADefect.bundle
    XCTAssertNotNil(bundle)
    let uiBundle = OSCADefectUI.bundle
    XCTAssertNotNil(uiBundle)
    let configuration = OSCADefectUI.configuration
    XCTAssertNotNil(configuration)
    XCTAssertNotNil(self.devPlistDict)
    XCTAssertNotNil(self.productionPlistDict)
  }// end func testModuleInit
  
  func testContactUIConfiguration() throws -> Void {
    let _ = try makeDevUIModule()
    let uiModuleConfig = try makeUIModuleConfig()
    XCTAssertEqual(OSCADefectUI.configuration.title, uiModuleConfig.title)
    XCTAssertEqual(OSCADefectUI.configuration.colorConfig.accentColor, uiModuleConfig.colorConfig.accentColor)
    XCTAssertEqual(OSCADefectUI.configuration.fontConfig.bodyHeavy, uiModuleConfig.fontConfig.bodyHeavy)
  }// end func testEventsUIConfiguration
  
}// end final class OSCADefectUITests

// MARK: - factory methods
extension OSCADefectUITests {
  public func makeDevModuleDependencies() throws -> OSCADefectDependencies {
    let networkService = try makeDevNetworkService()
    let userDefaults   = try makeUserDefaults(domainString: "de.osca.defect.ui")
    let dependencies = OSCADefectDependencies(
      networkService: networkService,
      userDefaults: userDefaults)
    return dependencies
  }// end public func makeDevModuleDependencies
  
  public func makeDevModule() throws -> OSCADefect {
    let devDependencies = try makeDevModuleDependencies()
    // initialize module
    let module = OSCADefect.create(with: devDependencies)
    return module
  }// end public func makeDevModule
  
  public func makeProductionModuleDependencies() throws -> OSCADefectDependencies {
    let networkService = try makeProductionNetworkService()
    let userDefaults   = try makeUserDefaults(domainString: "de.osca.defect.ui")
    let dependencies = OSCADefectDependencies(
      networkService: networkService,
      userDefaults: userDefaults)
    return dependencies
  }// end public func makeProductionModuleDependencies
  
  public func makeProductionModule() throws -> OSCADefect {
    let productionDependencies = try makeProductionModuleDependencies()
    // initialize module
    let module = OSCADefect.create(with: productionDependencies)
    return module
  }// end public func makeProductionModule
  
  public func makeUIModuleConfig() throws -> OSCADefectUIConfig {
    return OSCADefectUIConfig(title: "OSCADefectUI",
                              personalData: [.fullName, .email],
                              cornerRadius: 10.0,
                              shadow: OSCAShadowSettings(opacity: 0.3,
                                                         radius: 10,
                                                         offset: CGSize(width: 0, height: 2)),
                              fontConfig: OSCAFontSettings(),
                              colorConfig: OSCAColorSettings())
  }// end public func makeUIModuleConfig
  
  public func makeDevUIModuleDependencies() throws -> OSCADefectUIDependencies {
    let module      = try makeDevModule()
    let uiConfig    = try makeUIModuleConfig()
    return OSCADefectUIDependencies(dataModule: module,
                                    moduleConfig: uiConfig)
  }// end public func makeDevUIModuleDependencies
  
  public func makeDevUIModule() throws -> OSCADefectUI {
    let devDependencies = try makeDevUIModuleDependencies()
    // init ui module
    let uiModule = OSCADefectUI.create(with: devDependencies)
    return uiModule
  }// end public func makeUIModule
  
  public func makeProductionUIModuleDependencies() throws -> OSCADefectUIDependencies {
    let module      = try makeProductionModule()
    let uiConfig    = try makeUIModuleConfig()
    return OSCADefectUIDependencies(dataModule: module,
                                    moduleConfig: uiConfig)
  }// end public func makeProductionUIModuleDependencies
  
  public func makeProductionUIModule() throws -> OSCADefectUI {
    let productionDependencies = try makeProductionUIModuleDependencies()
    // init ui module
    let uiModule = OSCADefectUI.create(with: productionDependencies)
    return uiModule
  }// end public func makeProductionUIModule
}// end extension OSCADefectUITests
#endif

