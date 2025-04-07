//
//  OSCADefectUIDIContainer.swift
//  OSCADefectUI
//
//  Created by Ömer Kurutay on 22.02.22.
//  Reviewed by Stephan Breidenach on 21.06.22
//
import Foundation
import OSCAEssentials
import OSCADefect


final class OSCADefectUIDIContainer {
  
  let dependencies: OSCADefectUIDependencies
  let dataModule  : OSCADefect
  
  public init(dependencies: OSCADefectUIDependencies) {
    self.dependencies = dependencies
    self.dataModule   = OSCADefectUIDIContainer.makeOSCADefectModule(dependencies: dependencies)
  }
  
  // MARK: - OSCADefectModule
  private static func makeOSCADefectModule(dependencies: OSCADefectUIDependencies) -> OSCADefect {
    return dependencies.dataModule
  }
  
  // MARK: - Defect Form
  func makeOSCADefectFormViewController(actions: OSCADefectFormViewModelActions) -> OSCADefectFormViewController {
    return OSCADefectFormViewController.create(with: makeOSCADefectFromViewModel(actions: actions))
  }
  
  func makeOSCADefectFromViewModel(actions: OSCADefectFormViewModelActions) -> OSCADefectFormViewModel {
    return OSCADefectFormViewModel(dataModule: dependencies.dataModule,
                                   actions: actions)
  }
  
  // MARK: - Defect Form Picker
  func makeOSCADefectFormPickerViewController(actions: OSCADefectFormPickerViewModelActions, viewModel: OSCADefectFormViewModel) -> OSCADefectFormPickerViewController {
    return OSCADefectFormPickerViewController.create(with: makeOSCADefectFromPickerViewModel(actions: actions, viewModel: viewModel))
  }
  
  func makeOSCADefectFromPickerViewModel(actions: OSCADefectFormPickerViewModelActions, viewModel: OSCADefectFormViewModel) -> OSCADefectFormPickerViewModel {
    return OSCADefectFormPickerViewModel(dataModule: dependencies.dataModule,
                                         actions: actions,
                                         viewModel: viewModel)
  }
  
  // MARK: - Defect Information
  func makeOSCADefectInformationViewController(actions: OSCADefectInformationViewModelActions) -> OSCADefectInformationViewController {
    return OSCADefectInformationViewController.create(with: makeOSCADefectInformationViewModel(actions: actions))
  }
  
  func makeOSCADefectInformationViewModel(actions: OSCADefectInformationViewModelActions) -> OSCADefectInformationViewModel {
    return OSCADefectInformationViewModel(dataModule: dependencies.dataModule, actions: actions)
  }
  
  // MARK: - Defect Location
  func makeOSCADefectLocationViewController(actions: OSCADefectLocationViewModelActions, viewModel: OSCADefectFormViewModel) -> OSCADefectLocationViewController {
    return OSCADefectLocationViewController.create(with: makeOSCADefectLocationViewModel(actions: actions, viewModel: viewModel))
  }
  
  func makeOSCADefectLocationViewModel(actions: OSCADefectLocationViewModelActions, viewModel: OSCADefectFormViewModel) -> OSCADefectLocationViewModel {
    return OSCADefectLocationViewModel(actions: actions, viewModel: viewModel)
  }
  
  // MARK: - Defect Location Table
  func makeOSCADefectLocationTableViewController(actions: OSCADefectLocationTableViewModelActions, viewModel: OSCADefectLocationViewModel) -> OSCADefectLocationTableViewController {
    return OSCADefectLocationTableViewController.create(with: makeOSCADefectLocationTableViewModel(actions: actions, viewModel: viewModel))
  }
  
  func makeOSCADefectLocationTableViewModel(actions: OSCADefectLocationTableViewModelActions, viewModel: OSCADefectLocationViewModel) -> OSCADefectLocationTableViewModel {
    return OSCADefectLocationTableViewModel(
     actions: actions,
      viewModel: viewModel)
  }
  
  // MARK: - Defect Privacy Policy
  func makeOSCADefectPrivacyPolicyViewController(actions: OSCADefectPrivacyPolicyViewModelActions, privacyPolicy: String) -> OSCADefectPrivacyPolicyViewController {
    return OSCADefectPrivacyPolicyViewController.create(with: makeOSCADefectPrivacyPolicyViewModel(actions: actions, privacyPolicy: privacyPolicy))
  }
  
  func makeOSCADefectPrivacyPolicyViewModel(actions: OSCADefectPrivacyPolicyViewModelActions, privacyPolicy: String) -> OSCADefectPrivacyPolicyViewModel {
    return OSCADefectPrivacyPolicyViewModel(
      actions: actions,
      privacyPolicy: privacyPolicy)
  }
  
  // MARK: - Flow Coordinators
  func makeDefectFormFlowCoordinator(router: Router) -> OSCADefectFormFlowCoordinator {
    return OSCADefectFormFlowCoordinator(router: router, dependencies: self)
  }
}

extension OSCADefectUIDIContainer: OSCADefectFormFlowCoordinatorDependencies {}
