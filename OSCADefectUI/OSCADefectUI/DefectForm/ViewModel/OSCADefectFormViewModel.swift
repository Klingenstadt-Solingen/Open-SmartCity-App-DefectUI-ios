//
//  OSCADefectFormViewModel.swift
//  OSCADefectUI
//
//  Created by Ömer Kurutay on 22.02.22.
//

import OSCAEssentials
import OSCADefect
import Foundation
import Photos
import class MapKit.MKPlacemark
import class MapKit.MKUserLocation
import struct MapKit.MKCoordinateRegion
import CoreLocation
import Combine

public struct OSCADefectFormViewModelActions {
  let showDefectFormPicker: (OSCADefectFormViewModel) -> Void
  let showDefectInformation: () -> Void
  let showDefectLocation: (OSCADefectFormViewModel) -> Void
  let showDefectPrivacyPolicy: (String) -> Void
  let showImagePicker: (OSCADefectFormViewModel.ImagePickerType) -> Void
  let closeImagePicker: () -> Void
  let closeDefectForm: () -> Void
}

public struct PeronalData: OptionSet {
  public var rawValue: Int
  
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  
  public static var fullName = PeronalData(rawValue: 1 << 0)
  public static var userAddress = PeronalData(rawValue: 1 << 1)
  public static var userPostalCode = PeronalData(rawValue: 1 << 2)
  public static var userCity = PeronalData(rawValue: 1 << 3)
  public static var phone = PeronalData(rawValue: 1 << 4)
  public static var email = PeronalData(rawValue: 1 << 5)
  public static var all: PeronalData = [.fullName, .userAddress, .userPostalCode, .userCity, .phone, .email]
  public static var none: PeronalData = []
}

public enum OSCADefectFormViewModelError: Error, Equatable {
  case privacyPolicyFetch
  case defectFormDataSubmit
}

public enum OSCADefectFormViewModelState: Equatable {
  case fillInForm
  case validating
  case sending
  case finishedSending
  case loading
  case finishedLoading
  case receivedResponse
  case error(OSCADefectFormViewModelError)
}

public final class OSCADefectFormViewModel {
  let imagesMaxCount: Int = 4
  let dataModule: OSCADefect
  private let actions: OSCADefectFormViewModelActions?
  private var bindings = Set<AnyCancellable>()

  public var defaultLocation: ParseGeoPoint?
  
  // MARK: Initializer
  public init(dataModule: OSCADefect,
              actions: OSCADefectFormViewModelActions) {
    self.dataModule = dataModule
    self.actions = actions
  }
  
  // MARK: - OUTPUT
  
  enum ImagePickerType {
    case camera
    case photo
  }
  
  @Published var state: OSCADefectFormViewModelState = .fillInForm
  /// The jpeg data of the selected images from the collection view
  @Published var images: [Foundation.Data] = []
  @Published var defectType: OSCADefectFormContact? = nil
  @Published var defectPosition: MKPlacemark?
  @Published var defectAddress: String = ""
  @Published var fullName: String = ""
  @Published var userAddress: String = ""
  @Published var userPostalCode: String = ""
  @Published var userCity: String = ""
  @Published var phone: String = ""
  @Published var email: String = ""
  
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
  
  var defectRegion: MKCoordinateRegion? {
    guard let coordinate = defectPosition?.coordinate else { return nil }
    return MKCoordinateRegion(
      center: coordinate,
      latitudinalMeters: regionDistance,
      longitudinalMeters: regionDistance)
  }
  /// Returns the user region if available otherwise a default region is returned.
  var userLocation: CLLocationCoordinate2D? {
    LocationManager.shared.askForPermissionIfNeeded()
    if let userLocation = LocationManager.shared.userLocation {
      let location = CLLocationCoordinate2D(
        latitude: userLocation.coordinate.latitude,
        longitude: userLocation.coordinate.longitude)
      return location
    } else {
      let location = self.dataModule.defaultLocation?.clLocationCoordinate2D
      return location
    }
  }
  var updateCount: Int = 0
  /// The map zoom level. Defaults to 2km
  let regionDistance: CLLocationDistance = 2000
  
  var address: String = ""
  var postalCode: String = ""
  var city: String = ""
  /// The note which will be sent to the server after submission
  var note: String = ""
  var isPrivacyPolicyConfirmed: Bool = false
  let alertTitlePhoto: String? = nil
  let alertMessagePhoto: String? = nil
  
  // MARK: Localized Strings
  var screenTitle: String { NSLocalizedString(
    "defect_form_screen_title",
    bundle: self.bundle,
    comment: "The screen title") }
  var photosTitle: String { NSLocalizedString(
    "defect_photos_title",
    bundle: self.bundle,
    comment: "The title for photos") }
  var locationTitle: String { NSLocalizedString(
    "defect_location_title",
    bundle: self.bundle,
    comment: "The title for the location") }
  var customLocationTitle: String { NSLocalizedString(
    "defect_custom_location_title",
    bundle: self.bundle,
    comment: "The title for the custom location button") }
  var defectTitle: String { NSLocalizedString(
    "defect_defect_title",
    bundle: self.bundle,
    comment: "The title for the defect form fields") }
  var defectTypeTitle: String { NSLocalizedString(
    "defect_defect_type_title",
    bundle: self.bundle,
    comment: "The title for the defect types") }
  var notePlaceholder: String { NSLocalizedString(
    "defect_note_placeholder",
    bundle: self.bundle,
    comment: "The note placeholder") }
  var personalDataTitle: String { NSLocalizedString(
    "defect_personal_data_title",
    bundle: self.bundle,
    comment: "The title for the personal data fields") }
  var fullNamePlaceholder: String { NSLocalizedString(
    "defect_placeholder_full_name",
    bundle: self.bundle,
    comment: "The placeholder for the full name field") }
  var addressPlaceholder: String { NSLocalizedString(
    "defect_placeholder_address",
    bundle: self.bundle,
    comment: "The placeholder for the address field") }
  var postalCodePlaceholder: String { NSLocalizedString(
    "defect_placeholder_postal_code",
    bundle: self.bundle,
    comment: "The placeholder for the postal code field") }
  var cityPlaceholder: String { NSLocalizedString(
    "defect_placeholder_city",
    bundle: self.bundle,
    comment: "The placeholder for the city field") }
  var phonePlaceholder: String { NSLocalizedString(
    "defect_placeholder_phone",
    bundle: self.bundle,
    comment: "The placeholder for the phone number field") }
  var emailPlaceholder: String { NSLocalizedString(
    "defect_placeholder_email",
    bundle: self.bundle,
    comment: "The placeholder for the e-mail address field") }
  var inputMessageError: String { NSLocalizedString(
    "defect_input_message_error",
    bundle: self.bundle,
    comment: "The error message for invalid inputs in text fields") }
  var privacyConsent: String { NSLocalizedString(
    "defect_privacy_policy_consent",
    bundle: self.bundle,
    comment: "The consent to the privacy policy") }
  var privacyConsentLinks: [String] { [NSLocalizedString(
    "defect_privacy_policy_consent_link",
    bundle: self.bundle,
    comment: "The link in the privacy policy consent")] }
  var privacyRange: NSRange {
    (privacyConsent as NSString).range(of: privacyConsentLinks[0])
  }
  var submitTitle: String { NSLocalizedString(
    "defect_submit_title",
    bundle: self.bundle,
    comment: "The title for the submit button") }
  var uploadingMessageImage: String { NSLocalizedString(
    "defect_upload_message_image",
    bundle: self.bundle,
    comment: "The message shown while image is uploading") }
  var alertTitleSuccess: String { NSLocalizedString(
    "defect_alert_title_success",
    bundle: self.bundle,
    comment: "The alert action title to show success") }
  var alertMessageSuccess: String { NSLocalizedString(
    "defect_alert_message_success",
    bundle: self.bundle,
    comment: "The alert action message to show success") }
  var alertTitleError: String { NSLocalizedString(
    "defect_alert_title_error",
    bundle: self.bundle,
    comment: "The alert title for an error") }
  var alertMessageError: String { NSLocalizedString(
    "defect_alert_message_error",
    bundle: self.bundle,
    comment: "The alert message for an entry error") }
  var alertActionConfirm: String { NSLocalizedString(
    "defect_alert_title_confirm",
    bundle: self.bundle,
    comment: "The alert action title to confirm") }
  var alertActionRecord: String { NSLocalizedString(
    "defect_alert_title_record",
    bundle: self.bundle,
    comment: "The alert action title to take a picture") }
  var alertActionSelect: String { NSLocalizedString(
    "defect_alert_title_select",
    bundle: self.bundle,
    comment: "The alert action title to select a picture") }
  var alertActionDelete: String { NSLocalizedString(
    "defect_alert_title_remove",
    bundle: self.bundle,
    comment: "The alert action to remove a picture") }
  var alertActionCancel: String { NSLocalizedString(
    "defect_alert_title_cancel",
    bundle: self.bundle,
    comment: "The alert action title to cancel") }
  
  // MARK: - Private
  
  private func fetchParseConfigParams() {
    state = .loading
    
    self.dataModule
      .getParseConfigParams()
      .sink { completion in
        switch completion {
        case .finished:
          self.state = .finishedLoading
          
        case .failure:
          self.state = .error(.privacyPolicyFetch)
        }
      } receiveValue: { result in
        switch result {
        case let .success(parseConfigParams):
          guard let privacyText = parseConfigParams.privacyText
          else {
            self.state = .error(.privacyPolicyFetch)
            return
          }
          self.actions?.showDefectPrivacyPolicy(privacyText)
          
        case .failure:
          self.state = .error(.privacyPolicyFetch)
        }
      }
      .store(in: &self.bindings)
  }

  private func sendDefectForm() {
    self.state = .sending
    let personalData = OSCADefectUI.configuration.personalData
    // encode png images to base64 strings
    let base64Strings: [String] = self.images.compactMap{ $0.base64EncodedString() }
    
    let defectFormData: OSCADefectFormData = OSCADefectFormData(
      name         : personalData.contains(.fullName) ? fullName : nil,
      phone        : personalData.contains(.phone) ? phone : nil,
      email        : personalData.contains(.email) ? email : nil,
      address      : address,
      postalCode   : postalCode,
      city         : city,
      // base64 encoded Strings
      images       : base64Strings.isEmpty       ? nil : base64Strings,
      message      : note,
      contactId    : defectType?.objectId,
      geopoint     : ParseGeoPoint(
        latitude : defectPosition?.coordinate.latitude,
        longitude: defectPosition?.coordinate.longitude))
    
    self.dataModule
      .send(defectFormData: defectFormData)
      .sink { completion in
        switch completion {
        case .finished:
          self.state = .finishedSending
          
        case .failure:
          self.state = .error(.defectFormDataSubmit)
        }
      } receiveValue: { result in
        switch result {
        case let .success(response):
          print("\(Self.self): \(#function): \(response)")
          
          self.state = .receivedResponse
          
        case .failure:
          self.state = .error(.defectFormDataSubmit)
        }
      }
      .store(in: &self.bindings)
  }
  
  /// Sets the human readable address for the label
  /// - Parameters:
  ///   - latitude: latitude
  ///   - longitude: longitude
  private func setAddressFromLatLon(latitude: Double, longitude: Double) {
    let geocoder = CLGeocoder()
    let location = CLLocation(latitude: latitude, longitude: longitude)
    
    geocoder.reverseGeocodeLocation(location, preferredLocale: .current) { placemarks, error in
      if let error = error {
        print("reverse geodcode fail: \(error.localizedDescription)")
      }
      
      guard let placemark = placemarks?[0] else { return }
      
      var addressString: String = ""
      var streetAddress: String = ""
      var location     : String = ""
      
      if let street = placemark.thoroughfare {
        streetAddress = street
        
        if let hsnr = placemark.subThoroughfare {
          streetAddress += " " + hsnr
        }
        self.address = streetAddress
      }
      
      addressString += streetAddress
      
      if let zip = placemark.postalCode {
        self.postalCode = zip
        location += zip
      }
      if let city = placemark.locality {
        self.city = city
        location += location.isEmpty ? city : " " + city
      }
      
      if !location.isEmpty { addressString += ", " + location }
      
      self.defectAddress = addressString
    }
  }
  
  private func isValid(fullName: String) -> Bool {
    return fullName.count >= 3 && fullName.contains(" ")
  }
  
  private func isFormValid() -> Bool {
    state = .validating
    
    if !defectAddress.isEmpty,
       defectType != nil,
       !note.isEmpty && note != notePlaceholder,
       isPrivacyPolicyConfirmed {
      if OSCADefectUI.configuration.personalData == .none {
        return true
      } else {
        for option: PeronalData in [.fullName, .userAddress, .userPostalCode, .userCity, .phone, .email] {
          guard OSCADefectUI.configuration.personalData.contains(option)
          else { continue }
          
          switch option {
          case .fullName:
            if !isValid(fullName: fullName) { return false }
            
          case .userAddress:
            if userAddress.isEmpty { return false }
            
          case .userPostalCode:
            if userPostalCode.isEmpty { return false }
            
          case .userCity:
            if userCity.isEmpty { return false }
            
          case .phone:
            if phone.isEmpty { return false }
            
          case .email:
            if !email.isValidEmail() { return false }
            
          default: continue
          }
        }
        return true
      }
    }
    
    return false
  }
  
  private func closeImagePicker() {
    self.actions?.closeImagePicker()
  }
}

// MARK: - INPUT. View event methods
extension OSCADefectFormViewModel {
  func viewDidLoad() {
    if let userLocation = self.userLocation {
      self.defectPosition = MKPlacemark(coordinate: userLocation)
    }
    self.note = self.notePlaceholder
  }
  
  func infoButtonTouch() {
    actions?.showDefectInformation()
  }
  
  func imagePickerAction(type: ImagePickerType) {
    switch type {
    case .camera:
      if PermissionManager().hasCameraPermission {
        self.actions?.showImagePicker(type)
      } else {
        AVCaptureDevice.requestAccess(for: .video) { granted in
          if granted {
            self.actions?.showImagePicker(type)
          } else {
            PermissionManager().showPermissionError(type: .camera)
          }
        }
      }
      
    case .photo:
      if PermissionManager().hasPhotoLibraryPermission {
        self.actions?.showImagePicker(type)
      } else {
        PHPhotoLibrary.requestAuthorization { status in
          if status == .authorized {
            self.actions?.showImagePicker(type)
          } else {
            PermissionManager().showPermissionError(type: .photoLibrary)
          }
        }
      }
    }
  }
  
  func didFinishPickingMediaWithInfo(_ image: Data) {
    images.append(image)
    self.closeImagePicker()
  }
  
  func imagePickerControllerDidCancel() {
    self.closeImagePicker()
  }
  
  func setAddressFrom(coordinate: CLLocationCoordinate2D?) {
    guard let coordinate = coordinate else { return }
    setAddressFromLatLon(
      latitude: coordinate.latitude,
      longitude: coordinate.longitude)
  }
  
  func didUpdateMapView(with userLocation: MKUserLocation) {
    if updateCount < 1 {
      updateCount += 1
      defectPosition = MKPlacemark(coordinate: userLocation.coordinate)
    }
  }
  
  func textFieldShouldBeginEditing() {
    actions?.showDefectFormPicker(self)
  }
  
  func customLocationButtonTouch() {
    actions?.showDefectLocation(self)
  }
  
  func textFieldsEditingChanged(_ type: PeronalData, text: String) {
    let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
    
    switch type {
    case .fullName:
      fullName = isValid(fullName: text) ? text : ""
      
    case .userAddress:
      userAddress = text
      
    case .userPostalCode:
      userPostalCode = text
      
    case .userCity:
      userCity = text
      
    case .phone:
      phone = text
      
    case .email:
      email = text.isValidEmail() ? text : ""
      
    default: break
    }
  }
  
  func privacySwitchTouch(isOn: Bool) {
    isPrivacyPolicyConfirmed = isOn
  }
  
  func tapPrivacyLabel() {
    fetchParseConfigParams()
  }
  
  func submitButtonTouch() {
    if isFormValid() {
      sendDefectForm()
    }// end if
  }// end func submitButtonTouch
  
  func receivedResponseAlertCompletion() {
    actions?.closeDefectForm()
  }
}

extension OSCADefectFormViewModel {
  
}// end extension OSCADefectFormViewModel
