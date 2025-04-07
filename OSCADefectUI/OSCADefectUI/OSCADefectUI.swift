//
//  OSCADefectUI.swift
//  OSCADefectUI
//
//  Created by Ömer Kurutay on 22.02.22.
//  Reviewed by Stephan Breidenbach on 21.06.22
//

import OSCAEssentials
import OSCADefect
import Foundation

public protocol OSCADefectUIModuleConfig: OSCAUIModuleConfig {
  var personalData: PeronalData { get set }
  var cornerRadius: Double { get set }
  var shadow: OSCAShadowSettings { get set }
  var fontConfig: OSCAFontConfig { get set }
  var colorConfig: OSCAColorConfig { get set }
  var deeplinkScheme: String { get set }
}

public struct OSCADefectUIDependencies {
  let dataModule  : OSCADefect
  let moduleConfig: OSCADefectUIConfig
  let analyticsModule: OSCAAnalyticsModule?
  
  
  public init(dataModule     : OSCADefect,
              moduleConfig   : OSCADefectUIConfig,
              analyticsModule: OSCAAnalyticsModule? = nil
  ) {
    self.dataModule     = dataModule
    self.moduleConfig   = moduleConfig
    self.analyticsModule = analyticsModule
  }// end public init
}// end public struct OSCADefectUIDependencies

public struct OSCADefectUIConfig: OSCADefectUIModuleConfig {
  /// module title
  public var title: String?
  public var externalBundle: Bundle?
  public var personalData: PeronalData
  public var cornerRadius: Double
  public var shadow: OSCAShadowSettings
  public var fontConfig: OSCAFontConfig
  public var colorConfig: OSCAColorConfig
  /// app deeplink scheme URL part before `://`
  public var deeplinkScheme      : String = "solingen"
  
  public init(title: String?,
              externalBundle: Bundle? = nil,
              personalData: PeronalData,
              cornerRadius: Double,
              shadow: OSCAShadowSettings,
              fontConfig: OSCAFontConfig,
              colorConfig: OSCAColorConfig,
              deeplinkScheme: String = "solingen") {
    self.title = title
    self.externalBundle = externalBundle
    self.personalData = personalData
    self.cornerRadius = cornerRadius
    self.shadow = shadow
    self.fontConfig = fontConfig
    self.colorConfig = colorConfig
    self.deeplinkScheme = deeplinkScheme
  }
}

public struct OSCADefectUI: OSCAUIModule {
  /// module DI container
  private var moduleDIContainer: OSCADefectUIDIContainer!
  public var version: String = "1.0.4"
  public var bundlePrefix: String = "de.osca.defect.ui"
  
  public internal(set) static var configuration: OSCADefectUIConfig!
  /// module `Bundle`
  ///
  /// **available after module initialization only!!!**
  public internal(set) static var bundle: Bundle!
  
  /**
   create module and inject module dependencies
   - Parameter mduleDependencies: module dependencies
   */
  public static func create(with moduleDependencies: OSCADefectUIDependencies) -> OSCADefectUI {
    var module: Self = Self.init(config: moduleDependencies.moduleConfig)
    module.moduleDIContainer = OSCADefectUIDIContainer(dependencies: moduleDependencies)
    return module
  }
  
  /// public initializer with module configuration
  /// - Parameter config: module configuration
  public init(config: OSCAUIModuleConfig) {
#if SWIFT_PACKAGE
    Self.bundle = Bundle.module
#else
    guard let bundle: Bundle = Bundle(identifier: self.bundlePrefix) else { fatalError("Module bundle not initialized!") }
    Self.bundle = bundle
#endif
    guard let extendedConfig = config as? OSCADefectUIConfig else { fatalError("Config couldn't be initialized!")}
    OSCADefectUI.configuration = extendedConfig
  }
}

extension OSCADefectUI {
  /**
   public module interface `getter`for `OSCADefectFormFlowCoordinator`
   - Parameter router: router needed or the navigation graph
   */
  public func getDefectFlowCoordinator(router: Router) -> OSCADefectFormFlowCoordinator {
    let flow = self.moduleDIContainer.makeDefectFormFlowCoordinator(router: router)
    return flow
  }// end public func getDefectFlowCoordinator
}// end extension final class OSCADefectUI
