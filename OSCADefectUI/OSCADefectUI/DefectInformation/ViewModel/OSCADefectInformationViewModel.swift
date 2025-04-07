//
//  OSCADefectInformationViewModel.swift
//  OSCADefectUI
//
//  Created by Ömer Kurutay on 03.03.22.
//

import OSCADefect
import Foundation

public struct OSCADefectInformationViewModelActions {}

public final class OSCADefectInformationViewModel {
  
  private let dataModule: OSCADefect
  private let actions: OSCADefectInformationViewModelActions?
  
  public init(dataModule: OSCADefect,
              actions: OSCADefectInformationViewModelActions) {
    self.dataModule = dataModule
    self.actions = actions
  }
  
  // MARK: - OUTPUT
  
  /**
   Use this to get access to the __Bundle__ delivered from this module's configuration parameter __externalBundle__.
   - Returns: The __Bundle__ given to this module's configuration parameter __externalBundle__. If __externalBundle__ is __nil__, The module's own __Bundle__ is returned instead.
   */
  var bundle: Bundle = {
    if let bundle = OSCADefectUI.configuration.externalBundle {
      return bundle
    }
    else { return OSCADefectUI.bundle }
  }()
  
  let infoImage: String = "Flaw"
  
  // MARK: Localized Strings
  
  var screenTitle: String { NSLocalizedString(
    "defect_information_screen_title",
    bundle: self.bundle,
    comment: "The screen title")}
  var info: String { NSLocalizedString(
    "defect_information",
    bundle: self.bundle,
    comment: "The defect information")}
}

// MARK: - INPUT. View event methods
extension OSCADefectInformationViewModel {
  func viewDidLoad() {}
}
