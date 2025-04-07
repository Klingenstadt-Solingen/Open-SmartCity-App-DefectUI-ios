//
//  DefectFormFlow+OSCADeeplinkHandeble.swift
//  OSCADefectUI
//
//  Created by Stephan Breidenbach on 08.09.22.
//

import Foundation
import OSCAEssentials

extension OSCADefectFormFlowCoordinator: OSCADeeplinkHandeble{
  ///```console
  ///xcrun simctl openurl booted \
  /// "solingen://defect/"
  /// ```
  public func canOpenURL(_ url: URL) -> Bool {
    let deeplinkScheme: String = dependencies
      .deeplinkScheme
    return url.absoluteString.hasPrefix("\(deeplinkScheme)://defect")
  }// end public func canOpenURL
  
  public func openURL(_ url: URL,
                      onDismissed:(() -> Void)?) throws -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function): urls: \(url.absoluteString)")
#endif
    guard canOpenURL(url)
    else { return }
    showDefectForm(animated: true,
                   onDismissed: onDismissed)
  }// end public func openURL
}// end extension final class OSCADefectFormFlowCoordinator
