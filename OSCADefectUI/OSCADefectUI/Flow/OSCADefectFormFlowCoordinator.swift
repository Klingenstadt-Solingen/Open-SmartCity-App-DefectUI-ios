//
//  OSCADefectFormFlowCoordinator.swift
//  OSCADefectUI
//
//  Created by Ömer Kurutay on 22.02.22.
//

import OSCAEssentials
import OSCADefect
import UIKit

public protocol OSCADefectFormFlowCoordinatorDependencies {
  var deeplinkScheme: String { get }
  func makeOSCADefectFormViewController(actions: OSCADefectFormViewModelActions) -> OSCADefectFormViewController
  func makeOSCADefectFormPickerViewController(actions: OSCADefectFormPickerViewModelActions, viewModel: OSCADefectFormViewModel) -> OSCADefectFormPickerViewController
  func makeOSCADefectInformationViewController(actions: OSCADefectInformationViewModelActions) -> OSCADefectInformationViewController
  func makeOSCADefectLocationViewController(actions: OSCADefectLocationViewModelActions, viewModel: OSCADefectFormViewModel) -> OSCADefectLocationViewController
  func makeOSCADefectLocationTableViewController(actions: OSCADefectLocationTableViewModelActions, viewModel: OSCADefectLocationViewModel) -> OSCADefectLocationTableViewController
  func makeOSCADefectPrivacyPolicyViewController(actions: OSCADefectPrivacyPolicyViewModelActions, privacyPolicy: String) -> OSCADefectPrivacyPolicyViewController
}

public final class OSCADefectFormFlowCoordinator: Coordinator {
  /**
   `children`property for conforming to `Coordinator` protocol is a list of `Coordinator`s
   */
  public var children: [Coordinator] = []
  
  /**
   router injected via initializer: `router` will be used to push and pop view controllers
   */
  public var router: Router
  
  /**
   dependencies injected via initializer DI conforming to the `OSCADefectFormFlowCoordinatorDependencies` protocol
   */
  let dependencies: OSCADefectFormFlowCoordinatorDependencies
  
  /**
   defect form view controller `OSCADefectFormViewController`
   */
  private weak var defectFromVC: OSCADefectFormViewController?
  /**
   defect privacy policy view controller `OSCADefectPrivacyPolicyViewController`
   */
  private weak var defectPrivacyPolicyVC: OSCADefectPrivacyPolicyViewController?
  /**
   defect location view controller `OSCADefectLocationViewController`
   */
  private weak var defectLocationVC: OSCADefectLocationViewController?
  /**
   defect form picker view controller `OSCADefectFormPickerViewController`
   */
  private weak var defectFormPickerVC: OSCADefectFormPickerViewController?
  /**
   defect information view controller `OSCADefectInformationViewController`
   */
  private weak var defectInformationVC: OSCADefectInformationViewController?
  
  public init(router: Router, dependencies: OSCADefectFormFlowCoordinatorDependencies) {
    self.router = router
    self.dependencies = dependencies
  }
  
  // MARK: - Defect Form Picker Actions
  
  private func closeDefectFormPicker() -> Void {
    self.router.navigateBack(animated: true)
  }
  
  // MARK: - Defect Form Actions
  
  private func closeImagePicker() {
    self.router.navigateBack(animated: true)
  }
  
  private func showImagePicker(type: OSCADefectFormViewModel.ImagePickerType) {
    DispatchQueue.main.async {
      let vc = UIImagePickerController()
      switch type {
      case .camera: vc.sourceType = .camera
      case .photo: vc.sourceType = .photoLibrary
      }
      vc.delegate = self.defectFromVC
      vc.modalPresentationStyle = .overFullScreen
      self.router.presentModalViewController(vc,
                                             animated: true)
    }
  }
  
  private func getSearchTableViewController(viewModel: OSCADefectLocationViewModel) -> OSCADefectLocationTableViewController {
    let actions = OSCADefectLocationTableViewModelActions()
    let vc = self.dependencies.makeOSCADefectLocationTableViewController(
      actions: actions,
      viewModel: viewModel)
    return vc
  }
  
  private func showDefectPrivacyPolicy(_ privacyPolicy: String) -> Void {
    let actions = OSCADefectPrivacyPolicyViewModelActions()
    let vc = self.dependencies.makeOSCADefectPrivacyPolicyViewController(
      actions: actions,
      privacyPolicy: privacyPolicy)
    self.router.present(vc,
                        animated: true,
                        onDismissed: nil)
    self.defectPrivacyPolicyVC = vc
  }
  
  private func showDefectLocation(viewModel: OSCADefectFormViewModel) -> Void {
    let actions = OSCADefectLocationViewModelActions()
    let vc = self.dependencies.makeOSCADefectLocationViewController(
      actions: actions,
      viewModel: viewModel)
    vc.defectLocationTabeViewController = getSearchTableViewController(
      viewModel: vc.viewModel)
    self.router.present(vc,
                        animated: true,
                        onDismissed: nil)
    self.defectLocationVC = vc
  }
  
  private func showDefectFormPicker(viewModel: OSCADefectFormViewModel) -> Void {
    let actions = OSCADefectFormPickerViewModelActions(
      closeDefectFormPicker: self.closeDefectFormPicker)
    let vc = self.dependencies.makeOSCADefectFormPickerViewController(
      actions: actions,
      viewModel: viewModel)
    self.router.presentModalViewController(
      vc,
      animated: true,
      onDismissed: nil)
    self.defectFormPickerVC = vc
  }
  
  private func showDefectInformation() -> Void {
    let actions = OSCADefectInformationViewModelActions()
    let vc = self.dependencies.makeOSCADefectInformationViewController(actions: actions)
    self.router.present(vc,
                        animated: true,
                        onDismissed: nil)
    self.defectInformationVC = vc
  }
  
  private func closeDefectForm() -> Void {
    self.router.navigateBack(animated: true)
  }
  
  func showDefectForm(animated: Bool,
                      onDismissed: (() -> Void)?) -> Void {
    let actions = OSCADefectFormViewModelActions(
      showDefectFormPicker: self.showDefectFormPicker,
      showDefectInformation: self.showDefectInformation,
      showDefectLocation: self.showDefectLocation,
      showDefectPrivacyPolicy: self.showDefectPrivacyPolicy,
      showImagePicker: self.showImagePicker,
      closeImagePicker: self.closeImagePicker,
      closeDefectForm: self.closeDefectForm)
    
    let vc = self.dependencies.makeOSCADefectFormViewController(actions: actions)
    self.router.present(vc,
                        animated: animated,
                        onDismissed: onDismissed)
    self.defectFromVC = vc
  }// end func showDefectForm
  
  public func present(animated: Bool,
                      onDismissed: (() -> Void)?) {
    // Note: here we keep strong reference with actions, this way this flow do not need to be strong referenced
    showDefectForm(animated: animated,
                   onDismissed: onDismissed)
  }// end func present
}
