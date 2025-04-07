//
//  OSCADefectFormViewController.swift
//  OSCADefectUI
//
//  Created by Ömer Kurutay on 22.02.22.
//

import Combine
import MapKit
import OSCADefect
import OSCAEssentials
import Photos
import SkyFloatingLabelTextField
import SwiftSpinner
import UIKit

public final class OSCADefectFormViewController: UIViewController, Alertable, ActivityIndicatable {
  @IBOutlet private var tapOnMainView: UITapGestureRecognizer!
  @IBOutlet private var scrollView: UIScrollView!
  @IBOutlet private var photosTitleLabel: UILabel!
  @IBOutlet private var collectionView: UICollectionView!
  @IBOutlet private var locationTitleLabel: UILabel!
  @IBOutlet private var addressContainerView: UIView!
  @IBOutlet private var mapContainerView: UIView!
  @IBOutlet private var mapView: MKMapView!
  @IBOutlet private var addressLabel: UILabel!
  @IBOutlet private var customLocationButton: UIButton!
  @IBOutlet private var defectTitleLabel: UILabel!
  @IBOutlet private var defectContainerView: UIView!
  @IBOutlet private var defectTypeTextField: SkyFloatingLabelTextField!
  @IBOutlet private var noteTextView: UITextView!
  @IBOutlet private var personalDataStackView: UIStackView!
  @IBOutlet private var personalDataTitleLabel: UILabel!
  @IBOutlet private var personalDataFieldsStackView: UIStackView!
  @IBOutlet private var fullNameTextField: SkyFloatingLabelTextField!
  @IBOutlet private var addressTextField: SkyFloatingLabelTextField!
  @IBOutlet private var postalCodeTextField: SkyFloatingLabelTextField!
  @IBOutlet private var cityTextField: SkyFloatingLabelTextField!
  @IBOutlet private var phoneTextField: SkyFloatingLabelTextField!
  @IBOutlet private var emailTextField: SkyFloatingLabelTextField!
  @IBOutlet private var privacyStackView: UIStackView!
  @IBOutlet private var privacySwitch: UISwitch!
  @IBOutlet private var privacyLabel: UILabel!
  @IBOutlet private var submitButton: UIButton!
  
  private var viewModel: OSCADefectFormViewModel!
  private var bindings = Set<AnyCancellable>()
  
  public lazy var activityIndicatorView = ActivityIndicatorView(style: .large)
  
  private var activeField: UITextField?
  private var activeTextView: UITextView?
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    setupBindings()
    viewModel.viewDidLoad()
  }
  
  private func setupViews() {
    scrollView.delegate = self
    collectionView.delegate = self
    collectionView.dataSource = self
    mapView.delegate = self
    defectTypeTextField.delegate = self
    noteTextView.delegate = self
    fullNameTextField.delegate = self
    addressTextField.delegate = self
    postalCodeTextField.delegate = self
    cityTextField.delegate = self
    phoneTextField.delegate = self
    emailTextField.delegate = self
    
    self.view.backgroundColor = OSCADefectUI.configuration.colorConfig.backgroundColor
    self.view.addSubview(self.activityIndicatorView)
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
      self.activityIndicatorView.heightAnchor.constraint(equalToConstant: 100.0),
      self.activityIndicatorView.widthAnchor.constraint(equalToConstant: 100.0),
    ])
    
    self.tapOnMainView.cancelsTouchesInView = false
    
    self.navigationItem.title = self.viewModel.screenTitle
    
    photosTitleLabel.text = viewModel.photosTitle
    photosTitleLabel.font = OSCADefectUI.configuration.fontConfig.titleHeavy
    photosTitleLabel.textColor = OSCADefectUI.configuration.colorConfig.textColor
    
    self.collectionView.backgroundColor = .clear
    self.collectionView.layer.masksToBounds = false
    
    locationTitleLabel.text = viewModel.locationTitle
    locationTitleLabel.font = OSCADefectUI.configuration.fontConfig.titleHeavy
    locationTitleLabel.textColor = OSCADefectUI.configuration.colorConfig.textColor
    
    mapContainerView.backgroundColor = .clear
    mapContainerView.addShadow(with: OSCADefectUI.configuration.shadow)
    
    mapView.layer.cornerRadius = OSCADefectUI.configuration.cornerRadius
    mapView.showsUserLocation = true
    
    addressContainerView.backgroundColor = OSCADefectUI.configuration.colorConfig.accentColor.withAlphaComponent(0.75)
    addressContainerView.layer.cornerRadius = OSCADefectUI.configuration.cornerRadius
    
    addressLabel.font = OSCADefectUI.configuration.fontConfig.bodyLight
    addressLabel.textColor = OSCADefectUI.configuration.colorConfig.accentColor.isDarkColor
      ? OSCADefectUI.configuration.colorConfig.whiteDark
      : OSCADefectUI.configuration.colorConfig.blackColor
    addressLabel.numberOfLines = 2
    
    customLocationButton.setTitle(viewModel.customLocationTitle,
                                  for: .normal)
    customLocationButton.titleLabel?.font = OSCADefectUI.configuration.fontConfig.bodyLight
    let locationButtonTitleColor = OSCADefectUI.configuration.colorConfig.primaryColor.isDarkColor
      ? OSCADefectUI.configuration.colorConfig.whiteDark
      : OSCADefectUI.configuration.colorConfig.blackColor
    customLocationButton.setTitleColor(
      locationButtonTitleColor,
      for: .normal)
    customLocationButton.backgroundColor = OSCADefectUI.configuration.colorConfig.primaryColor
    let locationButtonCornerRadius = (Double(customLocationButton.frame.height) / 2) < OSCADefectUI.configuration.cornerRadius
      ? Double(customLocationButton.frame.height) / 2
      : OSCADefectUI.configuration.cornerRadius
    customLocationButton.layer.cornerRadius = locationButtonCornerRadius
    customLocationButton.addShadow(with: OSCADefectUI.configuration.shadow)
    
    defectTitleLabel.text = viewModel.defectTitle
    defectTitleLabel.font = OSCADefectUI.configuration.fontConfig.titleHeavy
    defectTitleLabel.textColor = OSCADefectUI.configuration.colorConfig.textColor
    
    defectContainerView.backgroundColor = OSCADefectUI.configuration.colorConfig.secondaryBackgroundColor
    defectContainerView.layer.cornerRadius = OSCADefectUI.configuration.cornerRadius
    defectContainerView.addShadow(with: OSCADefectUI.configuration.shadow)
    
    defectTypeTextField.font = OSCADefectUI.configuration.fontConfig.bodyLight
    defectTypeTextField.placeholder = viewModel.defectTypeTitle
    defectTypeTextField.textColor = OSCADefectUI.configuration.colorConfig.textColor
    defectTypeTextField.selectedTitleColor = OSCADefectUI.configuration.colorConfig.primaryColor
    defectTypeTextField.errorColor = OSCADefectUI.configuration.colorConfig.errorColor
    let imageArrowDownConfig = UIImage.SymbolConfiguration(scale: .small)
    let imageArrowDown = UIImage(systemName: "arrowtriangle.down.fill")?
      .withConfiguration(imageArrowDownConfig)
    if let image = imageArrowDown {
      let tapGesture = UITapGestureRecognizer(target: self,
                                              action: #selector(self.showPicker(_:)))
      self.defectTypeTextField.withImage(
        image,
        imagePadding: 10,
        imageColor: OSCADefectUI.configuration.colorConfig.primaryColor,
        separatorColor: .clear,
        direction: .right,
        tapGesture: tapGesture)
    }
    
    noteTextView.text = viewModel.notePlaceholder
    noteTextView.font = OSCADefectUI.configuration.fontConfig.bodyLight
    noteTextView.textColor = OSCADefectUI.configuration.colorConfig.whiteDarker
    noteTextView.backgroundColor = OSCADefectUI.configuration.colorConfig.grayColor.withAlphaComponent(0.25)
    noteTextView.layer.cornerRadius = OSCADefectUI.configuration.cornerRadius
    noteTextView.layer.masksToBounds = true
    noteTextView.inputAccessoryView = keyboardToolbar()
    
    personalDataStackView.isHidden = OSCADefectUI.configuration.personalData == .none
    
    personalDataTitleLabel.text = viewModel.personalDataTitle
    personalDataTitleLabel.font = OSCADefectUI.configuration.fontConfig.titleHeavy
    personalDataTitleLabel.textColor = OSCADefectUI.configuration.colorConfig.textColor
    
    personalDataFieldsStackView.backgroundColor = OSCADefectUI.configuration.colorConfig.secondaryBackgroundColor
    personalDataFieldsStackView.layer.cornerRadius = OSCADefectUI.configuration.cornerRadius
    personalDataFieldsStackView.addShadow(with: OSCADefectUI.configuration.shadow)
    
    fullNameTextField.isHidden = !OSCADefectUI.configuration.personalData.contains(.fullName)
    fullNameTextField.textContentType = .name
    fullNameTextField.placeholder = viewModel.fullNamePlaceholder
    fullNameTextField.font = OSCADefectUI.configuration.fontConfig.bodyLight
    fullNameTextField.textColor = OSCADefectUI.configuration.colorConfig.textColor
    fullNameTextField.selectedTitleColor = OSCADefectUI.configuration.colorConfig.primaryColor
    fullNameTextField.errorColor = OSCADefectUI.configuration.colorConfig.errorColor
    fullNameTextField.clearButtonMode = .whileEditing
    fullNameTextField.inputAccessoryView = keyboardToolbar()
    
    addressTextField.isHidden = !OSCADefectUI.configuration.personalData.contains(.userAddress)
    addressTextField.textContentType = .fullStreetAddress
    addressTextField.placeholder = viewModel.addressPlaceholder
    addressTextField.font = OSCADefectUI.configuration.fontConfig.bodyLight
    addressTextField.textColor = OSCADefectUI.configuration.colorConfig.textColor
    addressTextField.selectedTitleColor = OSCADefectUI.configuration.colorConfig.primaryColor
    addressTextField.errorColor = OSCADefectUI.configuration.colorConfig.errorColor
    addressTextField.clearButtonMode = .whileEditing
    addressTextField.inputAccessoryView = keyboardToolbar()
    
    postalCodeTextField.isHidden = !OSCADefectUI.configuration.personalData.contains(.userPostalCode)
    postalCodeTextField.textContentType = .postalCode
    postalCodeTextField.placeholder = viewModel.postalCodePlaceholder
    postalCodeTextField.font = OSCADefectUI.configuration.fontConfig.bodyLight
    postalCodeTextField.textColor = OSCADefectUI.configuration.colorConfig.textColor
    postalCodeTextField.selectedTitleColor = OSCADefectUI.configuration.colorConfig.primaryColor
    postalCodeTextField.errorColor = OSCADefectUI.configuration.colorConfig.errorColor
    postalCodeTextField.clearButtonMode = .whileEditing
    postalCodeTextField.inputAccessoryView = keyboardToolbar()
    
    cityTextField.isHidden = !OSCADefectUI.configuration.personalData.contains(.userCity)
    cityTextField.textContentType = .addressCity
    cityTextField.placeholder = viewModel.cityPlaceholder
    cityTextField.font = OSCADefectUI.configuration.fontConfig.bodyLight
    cityTextField.textColor = OSCADefectUI.configuration.colorConfig.textColor
    cityTextField.selectedTitleColor = OSCADefectUI.configuration.colorConfig.primaryColor
    cityTextField.errorColor = OSCADefectUI.configuration.colorConfig.errorColor
    cityTextField.clearButtonMode = .whileEditing
    cityTextField.inputAccessoryView = keyboardToolbar()
    
    phoneTextField.isHidden = !OSCADefectUI.configuration.personalData.contains(.phone)
    phoneTextField.textContentType = .telephoneNumber
    phoneTextField.placeholder = viewModel.phonePlaceholder
    phoneTextField.font = OSCADefectUI.configuration.fontConfig.bodyLight
    phoneTextField.textColor = OSCADefectUI.configuration.colorConfig.textColor
    phoneTextField.selectedTitleColor = OSCADefectUI.configuration.colorConfig.primaryColor
    phoneTextField.errorColor = OSCADefectUI.configuration.colorConfig.errorColor
    phoneTextField.clearButtonMode = .whileEditing
    phoneTextField.inputAccessoryView = keyboardToolbar()
    
    emailTextField.isHidden = !OSCADefectUI.configuration.personalData.contains(.email)
    emailTextField.textContentType = .emailAddress
    emailTextField.keyboardType = .emailAddress
    emailTextField.placeholder = viewModel.emailPlaceholder
    emailTextField.font = OSCADefectUI.configuration.fontConfig.bodyLight
    emailTextField.textColor = OSCADefectUI.configuration.colorConfig.textColor
    emailTextField.selectedTitleColor = OSCADefectUI.configuration.colorConfig.primaryColor
    emailTextField.errorColor = OSCADefectUI.configuration.colorConfig.errorColor
    emailTextField.clearButtonMode = .whileEditing
    emailTextField.inputAccessoryView = keyboardToolbar()
    
    privacyStackView.backgroundColor = OSCADefectUI.configuration.colorConfig.secondaryBackgroundColor
    privacyStackView.layer.cornerRadius = OSCADefectUI.configuration.cornerRadius
    privacyStackView.addShadow(with: OSCADefectUI.configuration.shadow)
    
    privacySwitch.onTintColor = OSCADefectUI.configuration.colorConfig.primaryColor
    
    privacyLabel.font = OSCADefectUI.configuration.fontConfig.bodyLight
    privacyLabel.textColor = OSCADefectUI.configuration.colorConfig.textColor
    privacyLabel.setTextWithLinks(
      text: viewModel.privacyConsent,
      links: viewModel.privacyConsentLinks,
      color: OSCADefectUI.configuration.colorConfig.primaryColor)
    privacyLabel.numberOfLines = 2
    
    submitButton.setTitle(viewModel.submitTitle, for: .normal)
    submitButton.titleLabel?.font = OSCADefectUI.configuration.fontConfig.bodyLight
    let submitButtonTitleColor = OSCADefectUI.configuration.colorConfig.primaryColor.isDarkColor
      ? OSCADefectUI.configuration.colorConfig.whiteDark
      : OSCADefectUI.configuration.colorConfig.blackColor
    submitButton.setTitleColor(
      submitButtonTitleColor,
      for: .normal)
    submitButton.backgroundColor = OSCADefectUI.configuration.colorConfig.primaryColor
    let submitButtonCornerRadius = (Double(customLocationButton.frame.height) / 2) < OSCADefectUI.configuration.cornerRadius
      ? Double(customLocationButton.frame.height) / 2
      : OSCADefectUI.configuration.cornerRadius
    submitButton.layer.cornerRadius = submitButtonCornerRadius
    submitButton.addShadow(with: OSCADefectUI.configuration.shadow)
    
    let infoButton = UIBarButtonItem(
      image: UIImage(systemName: "info.circle"),
      style: .plain,
      target: self,
      action: #selector(infoButtonTouch))
    navigationItem.rightBarButtonItem = infoButton
  }
  
  private func setupBindings() {
    viewModel.$images
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] _ in
        self?.collectionView.reloadData()
      })
      .store(in: &bindings)
    
    viewModel.$defectPosition
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] in
        guard let `self` = self else { return }
        
        self.viewModel.setAddressFrom(coordinate: $0?.coordinate)
        guard let region = self.viewModel.defectRegion else { return }
        self.mapView.setRegion(region, animated: true)
      })
      .store(in: &bindings)
    
    viewModel.$defectAddress
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] in
        self?.addressLabel.text = $0
      })
      .store(in: &bindings)
    
    viewModel.$defectType
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] defectType in
        guard let title = defectType?.title else { return }
        self?.defectTypeTextField.text = title
        self?.defectTypeTextField.errorMessage = nil
      })
      .store(in: &bindings)
    
    viewModel.$fullName
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] _ in
        _ = self?.errorMessage(for: .fullName)
      })
      .store(in: &bindings)
    
    viewModel.$userAddress
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] _ in
        _ = self?.errorMessage(for: .userAddress)
      })
      .store(in: &bindings)
    
    viewModel.$userPostalCode
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] _ in
        _ = self?.errorMessage(for: .userPostalCode)
      })
      .store(in: &bindings)
    
    viewModel.$userCity
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] _ in
        _ = self?.errorMessage(for: .userCity)
      })
      .store(in: &bindings)
    
    viewModel.$phone
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] _ in
        _ = self?.errorMessage(for: .phone)
      })
      .store(in: &bindings)
    
    viewModel.$email
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] _ in
        _ = self?.errorMessage(for: .email)
      })
      .store(in: &bindings)
    
    let stateValueHandler: (OSCADefectFormViewModelState) -> Void = { [weak self] viewModelState in
      guard let `self` = self else { return }
      
      switch viewModelState {
      case .fillInForm:
        self.hideActivityIndicator()
        
      case .validating:
        var error: Int = 0
        
        if let defectTypeTitle = self.viewModel.defectType?.title,
           !defectTypeTitle.isEmpty {
          self.defectTypeTextField.errorMessage = nil
        } else {
          error += 1
          self.defectTypeTextField.errorMessage = self.viewModel.inputMessageError
        }
        
        if let note = self.noteTextView.text,
           !note.isEmpty,
           note != self.viewModel.notePlaceholder {
          self.noteTextView.textColor = .label
        } else {
          error += 1
          self.noteTextView.textColor = OSCADefectUI.configuration.colorConfig.errorColor
        }
        
        for option: PeronalData in [.fullName, .userAddress, .userPostalCode, .userCity, .phone, .email] {
          guard OSCADefectUI.configuration.personalData.contains(option)
          else { continue }
          
          switch option {
          case .fullName: error += self.errorMessage(for: .fullName)
          case .userAddress: error += self.errorMessage(for: .userAddress)
          case .userPostalCode: error += self.errorMessage(for: .userPostalCode)
          case .userCity: error += self.errorMessage(for: .userCity)
          case .phone: error += self.errorMessage(for: .phone)
          case .email: error += self.errorMessage(for: .email)
          default: continue
          }
        }
        
        if !self.privacySwitch.isOn {
          error += 1
          self.privacySwitch.subviews[0].subviews[0].backgroundColor = OSCADefectUI.configuration.colorConfig.errorColor
        }
        
        if error > 0 {
          self.showAlert(
            title: self.viewModel.alertTitleError,
            message: self.viewModel.alertMessageError,
            actionTitle: self.viewModel.alertActionConfirm)
        }
        
      case .sending:
        self.userInteraction(isEnabled: false)
        self.showActivityIndicator()
        
      case .finishedSending:
        self.userInteraction(isEnabled: true)
        self.hideActivityIndicator()
        
      case .loading:
        self.userInteraction(isEnabled: false)
        self.showActivityIndicator()
        
      case .finishedLoading:
        self.userInteraction(isEnabled: true)
        self.hideActivityIndicator()
        
      case .receivedResponse:
        let alertController = UIAlertController(
          title: self.viewModel.alertTitleSuccess,
          message: self.viewModel.alertMessageSuccess,
          preferredStyle: .alert)
        let alertAction = UIAlertAction(
          title: self.viewModel.alertActionConfirm,
          style: .default) { _ in
            self.viewModel.receivedResponseAlertCompletion()
          }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
        
      case let .error(error):
        self.userInteraction(isEnabled: true)
        self.hideActivityIndicator()
        self.showAlert(
          title: self.viewModel.alertTitleError,
          error: error,
          actionTitle: self.viewModel.alertActionConfirm)
      }
    }
    
    viewModel.$state
      .receive(on: RunLoop.main)
      .sink(receiveValue: stateValueHandler)
      .store(in: &bindings)
  }
  
  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setup(
      largeTitles: true,
      tintColor: OSCADefectUI.configuration.colorConfig.navigationTintColor,
      titleTextColor: OSCADefectUI.configuration.colorConfig.navigationTitleTextColor,
      barColor: OSCADefectUI.configuration.colorConfig.navigationBarColor)
    registerForKeyboardNotifications()
  }
  
  override public func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    deregisterFromKeyboardNotifications()
  }
  
  private func userInteraction(isEnabled: Bool) {
    view.isUserInteractionEnabled = isEnabled
    navigationController?.navigationBar.isUserInteractionEnabled = isEnabled
  }
  
  private func registerForKeyboardNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillAppear(notification:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillDisappear(notification:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil)
  }
  
  private func deregisterFromKeyboardNotifications() {
    NotificationCenter.default.removeObserver(
      self,
      name: UIResponder.keyboardWillShowNotification,
      object: nil)
    NotificationCenter.default.removeObserver(
      self,
      name: UIResponder.keyboardWillHideNotification,
      object: nil)
  }
  
  private func keyboardToolbar() -> UIToolbar {
    let keyboardToolbar = UIToolbar()
    let doneButton = UIBarButtonItem(
      barButtonSystemItem: .done,
      target: self,
      action: #selector(keyboardDoneButtonTouch(barButton:)))
    doneButton.tintColor = OSCADefectUI.configuration.colorConfig.primaryColor
    let flexibleSpace = UIBarButtonItem(
      barButtonSystemItem: .flexibleSpace,
      target: nil,
      action: nil)
    keyboardToolbar.items = [flexibleSpace, doneButton]
    keyboardToolbar.sizeToFit()
    keyboardToolbar.layoutIfNeeded()
    return keyboardToolbar
  }
  
  private func errorMessage(for field: PeronalData) -> Int {
    switch field {
    case .fullName:
      fullNameTextField.errorMessage = viewModel.fullName.isEmpty
        ? viewModel.inputMessageError
        : nil
      return fullNameTextField.hasErrorMessage ? 1 : 0
      
    case .userAddress:
      addressTextField.errorMessage = viewModel.userAddress.isEmpty
        ? viewModel.inputMessageError
        : nil
      return addressTextField.hasErrorMessage ? 1 : 0
      
    case .userPostalCode:
      postalCodeTextField.errorMessage = viewModel.userPostalCode.isEmpty
        ? viewModel.inputMessageError
        : nil
      return postalCodeTextField.hasErrorMessage ? 1 : 0
      
    case .userCity:
      cityTextField.errorMessage = viewModel.userCity.isEmpty
        ? viewModel.inputMessageError
        : nil
      return cityTextField.hasErrorMessage ? 1 : 0
      
    case .phone:
      phoneTextField.errorMessage = viewModel.phone.isEmpty
        ? viewModel.inputMessageError
        : nil
      return phoneTextField.hasErrorMessage ? 1 : 0
      
    case .email:
      emailTextField.errorMessage = viewModel.email.isEmpty
        ? viewModel.inputMessageError
        : nil
      return emailTextField.hasErrorMessage ? 1 : 0
      
    default: return 0
    }
  }
  
  @objc private func keyboardDoneButtonTouch(barButton: UIBarButtonItem) {
    view.endEditing(true)
  }
  
  @objc private func keyboardWillAppear(notification: NSNotification) {
    scrollView.isScrollEnabled = true
    let info = notification.userInfo!
    let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
    var adjustedHeight = keyboardSize!.height
    if let tabbarSize = tabBarController?.tabBar.frame.size {
      adjustedHeight = keyboardSize!.height - tabbarSize.height
    }
    
    let contentInsets = UIEdgeInsets(top: 0.0,
                                     left: 0.0,
                                     bottom: adjustedHeight,
                                     right: 0.0)
    
    scrollView.contentInset = contentInsets
    scrollView.scrollIndicatorInsets = contentInsets
    
    var aRect: CGRect = view.frame
    aRect.size.height -= keyboardSize!.height
    if let activeField = activeField {
      if !aRect.contains(activeField.frame.origin) {
        scrollView.scrollRectToVisible(activeField.frame,
                                       animated: true)
      }
    } else if let activeTextView = activeTextView {
      let converted = activeTextView.convert(activeTextView.frame,
                                             to: scrollView)
      if !aRect.contains(converted.origin) {
        scrollView.scrollRectToVisible(converted,
                                       animated: true)
      }
    }
  }
  
  @objc private func keyboardWillDisappear(notification: NSNotification) {
    let contentInsets: UIEdgeInsets = .zero
    scrollView.contentInset = contentInsets
    scrollView.scrollIndicatorInsets = contentInsets
  }
  
  @objc private func infoButtonTouch() {
    viewModel.infoButtonTouch()
  }
  
  @objc private func showPicker(_ sender: UITapGestureRecognizer) {
    self.viewModel.textFieldShouldBeginEditing()
  }
  
  @IBAction private func tapOnMainViewTouch(_ sender: UITapGestureRecognizer) {
    view.endEditing(true)
  }
  
  @IBAction private func customLocationButtonTouch(_ sender: UIButton) {
    viewModel.customLocationButtonTouch()
  }
  
  @IBAction func textFieldsEditingChanged(_ sender: SkyFloatingLabelTextField) {
    guard let text = sender.text else { return }
    var type: PeronalData = .none
    
    switch sender {
    case fullNameTextField: type = .fullName
    case addressTextField: type = .userAddress
    case postalCodeTextField: type = .userPostalCode
    case cityTextField: type = .userCity
    case phoneTextField: type = .phone
    case emailTextField: type = .email
    default: type = .none
    }
    
    viewModel.textFieldsEditingChanged(type, text: text)
  }
  
  @IBAction func privacySwitchTouch(_ sender: UISwitch) {
    viewModel.privacySwitchTouch(isOn: sender.isOn)
  }
  
  /// Handles the tap on "privacy policy"
  /// - Parameter gesture: the caller of the function
  @IBAction private func tapPrivacyLabel(_ gesture: UITapGestureRecognizer) {
    self.viewModel.tapPrivacyLabel()
  }
  
  /// Handles the touch of the "submit" button
  /// - Parameter sender: caller of the function
  @IBAction func submitButtonTouch(_ sender: UIButton) {
    viewModel.submitButtonTouch()
  }
}

// MARK: - instantiate view conroller

extension OSCADefectFormViewController: StoryboardInstantiable {
  public static func create(with viewModel: OSCADefectFormViewModel) -> OSCADefectFormViewController {
    let vc = Self.instantiateViewController(OSCADefectUI.bundle)
    vc.viewModel = viewModel
    return vc
  }
}

extension OSCADefectFormViewController: MKMapViewDelegate {
  public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    viewModel.didUpdateMapView(with: userLocation)
  }
}

// - MARK: images collection view delegate

extension OSCADefectFormViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  var maxCount: Int { viewModel.imagesMaxCount }
  
  public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
    if viewModel.images.count < maxCount {
      viewModel.images.count + 1
    } else {
      maxCount
    }// end if
  }// end func collectionView number of items in section
  
  public func collectionView(_ collectionView: UICollectionView,
                             cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let index = indexPath.row
    guard index < maxCount else { return UICollectionViewCell() }
    let imageAddable: Bool = viewModel.images.count < maxCount
    if index == 0 && imageAddable {
      // no image in cell
      let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: "addPhotoCell",
        for: indexPath)
      
      cell.addShadow(with: OSCADefectUI.configuration.shadow)
      cell.contentView.layer.cornerRadius = OSCADefectUI.configuration.cornerRadius
      
      if let view = cell.contentView.subviews.first
      {
        view.backgroundColor = OSCADefectUI.configuration.colorConfig.secondaryBackgroundColor
        if let imageView = view.subviews.first as? UIImageView {
          imageView.tintColor = OSCADefectUI.configuration.colorConfig.grayColor
        }
      }
      return cell
    } else {
      // image in cell
      let imageIndex = imageAddable ? index - 1 : index
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: OSCADefectFormPhotoCollectionViewCell.reuseIdentifier,
        for: indexPath) as? OSCADefectFormPhotoCollectionViewCell
      else { return UICollectionViewCell() }
      let imageData = viewModel.images[imageIndex]
      cell.fill(with: imageData)
      
      return cell
    }// end if
  }// end func collection view cell for item at
  
  public func collectionView(_ collectionView: UICollectionView,
                             didSelectItemAt indexPath: IndexPath) {
    let index = indexPath.row
    guard index < maxCount else { return }
    let imageAddable: Bool = viewModel.images.count < maxCount
    if index == 0 && imageAddable {
      // no image in cell => add image
      let alertController = UIAlertController(
        title: viewModel.alertTitlePhoto,
        message: viewModel.alertMessagePhoto,
        preferredStyle: .actionSheet)
      alertController.popoverPresentationController?.sourceView = collectionView.cellForItem(at: indexPath)
      alertController.addAction(UIAlertAction(
        title: viewModel.alertActionRecord,
        style: .default,
        handler: { _ in
          DispatchQueue.main.async {
            self.viewModel.imagePickerAction(type: .camera)
          }
        }))
      alertController.addAction(UIAlertAction(
        title: viewModel.alertActionSelect,
        style: .default,
        handler: { _ in
          DispatchQueue.main.async {
            self.viewModel.imagePickerAction(type: .photo)
          }
        }))
      alertController.addAction(UIAlertAction(
        title: viewModel.alertActionCancel,
        style: .cancel,
        handler: nil))
      present(alertController, animated: true, completion: nil)
    } else {
      // image in cell => delete image
      let imageIndex = imageAddable ? index - 1 : index
      let alertController = UIAlertController(
        title: viewModel.alertTitlePhoto,
        message: viewModel.alertMessagePhoto,
        preferredStyle: .actionSheet)
      alertController.popoverPresentationController?.sourceView = collectionView.cellForItem(at: indexPath)
      alertController.addAction(UIAlertAction(
        title: viewModel.alertActionDelete,
        style: .destructive,
        handler: { _ in
          self.viewModel.images.remove(at: imageIndex)
        }))
      alertController.addAction(UIAlertAction(
        title: viewModel.alertActionCancel,
        style: .cancel,
        handler: nil))
      present(alertController, animated: true, hapticNotification: .warning)
    }// end if
  }// end func collection view did select item at
}// end extension OSCADefectFormViewController

extension OSCADefectFormViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    viewModel.imagePickerControllerDidCancel()
  }
  
  public func imagePickerController(_ picker: UIImagePickerController,
                                    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    guard let image = info[.originalImage] as? UIImage else {
      print("No image found")
      return
    }
    //guard let data = image.pngData() else { return }
    guard let data = image.jpegData(compressionQuality: 0.8) else { return }
    viewModel.didFinishPickingMediaWithInfo(data)
  }
}

extension OSCADefectFormViewController: UITextViewDelegate {
  public func textViewDidChange(_ textView: UITextView) {
    let text = textView.text
      .trimmingCharacters(in: .whitespacesAndNewlines)
    
    viewModel.note = text.isEmpty
      ? viewModel.notePlaceholder
      : text
  }
  
  public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    activeTextView = textView
    return true
  }
  
  public func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == viewModel.notePlaceholder {
      viewModel.note = textView.text
      textView.text = ""
      textView.textColor = .label
    }
  }
  
  public func textViewDidEndEditing(_ textView: UITextView) {
    activeTextView = nil
    let text = textView.text
      .trimmingCharacters(in: .whitespacesAndNewlines)
    
    if text.isEmpty {
      viewModel.note = ""
      textView.text = viewModel.notePlaceholder
      textView.textColor = OSCADefectUI.configuration.colorConfig.whiteDarker
    }
  }
}

extension OSCADefectFormViewController: UITextFieldDelegate {
  public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if textField == defectTypeTextField {
      view.endEditing(true)
      viewModel.textFieldShouldBeginEditing()
      return false
    } else {
      return true
    }
  }
}
