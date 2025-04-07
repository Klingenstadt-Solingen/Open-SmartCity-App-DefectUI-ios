//
//  OSCADefectPrivacyPolicyViewModel.swift
//  OSCADefectUI
//
//  Created by Ömer Kurutay on 30.03.22.
//

import OSCANetworkService
import Foundation

public struct OSCADefectPrivacyPolicyViewModelActions {}

public final class OSCADefectPrivacyPolicyViewModel {
  private let actions: OSCADefectPrivacyPolicyViewModelActions?
  let privacyPolicy: String
  
  // MARK: Initializer
  public init(actions: OSCADefectPrivacyPolicyViewModelActions,
              privacyPolicy: String) {
    self.actions = actions
    self.privacyPolicy = privacyPolicy
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
  
  // MARK: Localized Strings
  
  var screenTitle: String { NSLocalizedString(
    "defect_privacy_policy_screen_title",
    bundle: self.bundle,
    comment: "The screen title for privacy policy") }
}

// MARK: - INPUT. View event methods

extension OSCADefectPrivacyPolicyViewModel {
  func viewDidLoad() {}
}
