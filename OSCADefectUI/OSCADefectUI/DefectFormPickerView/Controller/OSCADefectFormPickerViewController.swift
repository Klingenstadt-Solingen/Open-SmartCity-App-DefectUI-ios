//
//  OSCADefectFormPickerViewController.swift
//  OSCADefectUI
//
//  Created by Ömer Kurutay on 02.03.22.
//

import OSCAEssentials
import UIKit
import Combine

public final class OSCADefectFormPickerViewController: UIViewController, ActivityIndicatable, Alertable {
  
  @IBOutlet private var dismissView: UIView!
  @IBOutlet private var contentView: UIView!
  @IBOutlet private var cancelButton: UIButton!
  @IBOutlet private var confirmButton: UIButton!
  @IBOutlet private var pickerView: UIPickerView!
  
  public lazy var activityIndicatorView = ActivityIndicatorView(style: .large)
  
  private var viewModel: OSCADefectFormPickerViewModel!
  private var bindings = Set<AnyCancellable>()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    self.setupViews()
    self.setupBindings()
    self.viewModel.viewDidLoad()
  }
  
  private func setupViews() {
    self.pickerView.delegate = self
    self.pickerView.dataSource = self
    
    self.view.backgroundColor = .clear
    
    self.contentView.backgroundColor = OSCADefectUI.configuration.colorConfig.backgroundColor
    self.contentView.addSubview(self.activityIndicatorView)
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
      self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
      self.activityIndicatorView.heightAnchor.constraint(equalToConstant: 100.0),
      self.activityIndicatorView.widthAnchor.constraint(equalToConstant: 100.0),
    ])
    
    self.dismissView.backgroundColor = .clear
    
    self.cancelButton.setTitle(self.viewModel.cancelTitle,
                          for: .normal)
    self.cancelButton.titleLabel?.font = OSCADefectUI.configuration.fontConfig.subheaderLight
    self.cancelButton.setTitleColor(
      OSCADefectUI.configuration.colorConfig.primaryColor,
      for: .normal)
    
    self.confirmButton.setTitle(self.viewModel.confirmTitle,
                           for: .normal)
    self.confirmButton.titleLabel?.font = OSCADefectUI.configuration.fontConfig.subheaderLight
    self.confirmButton.setTitleColor(
      OSCADefectUI.configuration.colorConfig.primaryColor,
      for: .normal)
    self.confirmButton.setTitleColor(
      OSCADefectUI.configuration.colorConfig.primaryColor.withAlphaComponent(0.25),
      for: .disabled)
    self.confirmButton.isEnabled = false
  }
  
  private func setupBindings() {
    let viewStateError: (OSCADefectFormPickerViewModelError) -> Void = { [weak self] error in
      guard let `self` = self else { return }
      
      switch error {
      case .defectFormContactFetch:
          showAlert(
          title: self.viewModel.alertTitleError,
          error: error,
          preferredStyle: .alert)
        
      case .defectPicking:
        self.viewModel.closePicker()
      }
    }
    
    let stateValueHandler: (OSCADefectFormPickerViewModelState) -> Void = { [weak self] viewModelState in
      guard let `self` = self else { return }
      
      switch viewModelState {
      case .loading:
        self.confirmButton.isEnabled = false
        self.showActivityIndicator()
        
      case .finishedLoading:
        self.hideActivityIndicator()
        
      case .selected:
        self.confirmButton.isEnabled = true
        
      case let .error(error):
        viewStateError(error)
      }
    }
    
    self.viewModel.$state
      .receive(on: RunLoop.main)
      .sink(receiveValue: stateValueHandler)
      .store(in: &self.bindings)
    
    self.viewModel.$defectFormContacts
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] _ in
        self?.pickerView.reloadAllComponents()
      })
      .store(in: &self.bindings)
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.contentView.roundCorners(
      corners: [.topLeft, .topRight],
      radius: OSCADefectUI.configuration.cornerRadius)
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    UINotificationFeedbackGenerator().notificationOccurred(.warning)
    self.viewModel.viewDidAppear()
  }
  
  @IBAction func tapOnDismissViewTouch(_ sender: UITapGestureRecognizer) {
    self.viewModel.tapOnMainViewTouch()
  }
  
  @IBAction func cancelButtonTouch(_ sender: UIButton) {
    self.viewModel.cancelButtonTouch()
  }
  
  @IBAction func confirmButtonTouch(_ sender: UIButton) {
    self.viewModel.confirmButtonTouch()
  }
}

// MARK: - instantiate view controller
extension OSCADefectFormPickerViewController: StoryboardInstantiable {
  public static func create(with viewModel: OSCADefectFormPickerViewModel) -> OSCADefectFormPickerViewController {
    let vc: Self = Self.instantiateViewController(OSCADefectUI.bundle)
    vc.viewModel = viewModel
    return vc
  }
}

extension OSCADefectFormPickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  public func numberOfComponents(in _: UIPickerView) -> Int {
    self.viewModel.numberOfComponents
  }
  
  public func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
    self.viewModel.numberOfItemsInComponent
  }
  
  public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
    let pickerLabel = UILabel()
    pickerLabel.text = self.viewModel.defectFormContacts[row].title
    pickerLabel.font = OSCADefectUI.configuration.fontConfig.bodyLight
    pickerLabel.textColor = OSCADefectUI.configuration.colorConfig.textColor
    pickerLabel.textAlignment = .center
    
    return pickerLabel
  }
  
  public func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
    self.viewModel.didSelectItem(at: row)
  }
}
