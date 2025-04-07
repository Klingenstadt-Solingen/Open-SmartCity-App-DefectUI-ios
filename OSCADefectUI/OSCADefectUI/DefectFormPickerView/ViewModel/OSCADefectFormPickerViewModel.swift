//
//  OSCADefectFormPickerViewModel.swift
//  OSCADefectUI
//
//  Created by Ömer Kurutay on 02.03.22.
//  Reviewed by Stephan Breidenbach on 21.06.22
//

import Foundation
import OSCADefect
import Combine

public struct OSCADefectFormPickerViewModelActions {
  let closeDefectFormPicker: () -> Void
}

public enum OSCADefectFormPickerViewModelError: Error, Equatable {
  case defectFormContactFetch
  case defectPicking
}

public enum OSCADefectFormPickerViewModelState: Equatable {
  case selected
  case loading
  case finishedLoading
  case error(OSCADefectFormPickerViewModelError)
}

public final class OSCADefectFormPickerViewModel {
  
  private let dataModule: OSCADefect
  private let actions: OSCADefectFormPickerViewModelActions?
  private var formViewModel: OSCADefectFormViewModel!
  private var bindings = Set<AnyCancellable>()
  
  // MARK: Initializer
  public init(dataModule: OSCADefect,
              actions: OSCADefectFormPickerViewModelActions,
              viewModel: OSCADefectFormViewModel) {
    self.dataModule = dataModule
    self.actions = actions
    self.formViewModel = viewModel
  }
  
  // MARK: - OUTPUT
  
  @Published private(set) var state: OSCADefectFormPickerViewModelState = .loading
  @Published private(set) var defectFormContacts: [OSCADefectFormContact] = []
  
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
  
  var selectedDefectFormContact: OSCADefectFormContact? = nil
  let numberOfComponents: Int = 1
  var numberOfItemsInComponent: Int { defectFormContacts.count }
  
  // MARK: Localized Strings
  
  var alertTitleError: String { NSLocalizedString(
    "defect_alert_title_error",
    bundle: self.bundle,
    comment: "The alert title for an error") }
  var alertActionConfirm: String { NSLocalizedString(
    "defect_alert_title_confirm",
    bundle: self.bundle,
    comment: "The alert action title to confirm") }
  var cancelTitle: String { NSLocalizedString(
    "defect_picker_title_cancel",
    bundle: self.bundle,
    comment: "The title for the picker view cancel button") }
  var confirmTitle: String { NSLocalizedString(
    "defect_picker_title_confirm",
    bundle: self.bundle,
    comment: "The title for the picker view confirm button") }
  
  // MARK: - Private
  
  private func fetchAllDefectFormContacts() -> Void {
    state = .loading
    
    self.dataModule
      .getDefectFormContacts(limit: 1000, query: [:])
      .sink { completion in
        switch completion {
        case .finished:
          self.state = .finishedLoading
          
        case .failure:
          self.state = .error(.defectFormContactFetch)
        }
      } receiveValue: { result in
        let sortedResult = result.map {
          $0.sorted(by: { $0.position ?? 99 < $1.position ?? 99 })
        }
        switch sortedResult {
        case let .success(fetchedDefectFormContacts):
          self.selectedDefectFormContact = fetchedDefectFormContacts.first
          self.state = .selected
          self.defectFormContacts = fetchedDefectFormContacts
          
        case .failure:
          self.state = .error(.defectFormContactFetch)
        }
      }
      .store(in: &self.bindings)
  }
}

// MARK: - INPUT. View event methods
extension OSCADefectFormPickerViewModel {
  func viewDidLoad() {
    fetchAllDefectFormContacts()
  }
  
  func viewDidAppear() {}
  
  func didSelectItem(at index: Int) {
    selectedDefectFormContact = defectFormContacts[index]
    state = .selected
  }
  
  func closePicker() {
    selectedDefectFormContact = nil
    actions?.closeDefectFormPicker()
  }
  
  func tapOnMainViewTouch() {
    closePicker()
  }
  
  func cancelButtonTouch() {
    closePicker()
  }
  
  func confirmButtonTouch() {
    formViewModel.defectType = selectedDefectFormContact
    actions?.closeDefectFormPicker()
  }
}
