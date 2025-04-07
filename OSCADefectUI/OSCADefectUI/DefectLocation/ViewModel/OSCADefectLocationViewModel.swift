//
//  OSCADefectLocationViewModel.swift
//  OSCADefectUI
//
//  Created by Ömer Kurutay on 03.03.22.
//  Reviewed by Stephan Breidenbach on 21.06.22
//

import OSCAEssentials
import class MapKit.MKPlacemark
import Combine
import CoreLocation


public struct OSCADefectLocationViewModelActions {}

public final class OSCADefectLocationViewModel {
  private let actions: OSCADefectLocationViewModelActions?
  private let formViewModel: OSCADefectFormViewModel
  private var bindings = Set<AnyCancellable>()
  
  // MARK: - Initializer
  public init(actions: OSCADefectLocationViewModelActions,
              viewModel: OSCADefectFormViewModel) {
    self.actions = actions
    self.formViewModel = viewModel
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
  
  @Published var selectedPin: MKPlacemark?
  
  var defaultLoation: OSCAGeoPoint? { self.formViewModel.dataModule.defaultLocation }
  
  // MARK: Localized Strings
  
  var screenTitle: String { NSLocalizedString(
    "defect_location_screen_title",
    bundle: self.bundle,
    comment: "The screen title") }
  var searchBarPlaceholder: String { NSLocalizedString(
    "defect_search_bar_placeholder",
    bundle: self.bundle,
    comment: "The search bar placeholder") }
}

// MARK: - INPUT. View event methods
extension OSCADefectLocationViewModel {
  func viewDidLoad() {
    var userLocation: CLLocationCoordinate2D?
    if let location = CLLocationManager().location {
      // user location
      userLocation = location.coordinate
    } else if let location = self.defaultLoation{
      // fallback
      userLocation = location.clLocationCoordinate2D
    }// end if
    if let userLocation = userLocation {
      self.selectedPin = MKPlacemark(coordinate: userLocation)
    }// end if
  }// end func viewDidLoad
  
  /**
   Sets the new coordinate to the dragged annotation in the map view.
   - Parameter coodinate: New coordinates after drag ended
   */
  func mapViewDragStateEnded(at coordinate: CLLocationCoordinate2D) {
    selectedPin = MKPlacemark(coordinate: coordinate)
  }
  
  /**
   Passes the selected item from child view controller `OSCADefectLocationTableViewController`
   to `OSCADefectLocationViewController`.
   - Parameter item: The selected item from `OSCADefectLocationTableViewController`
   */
  func didSelectLocationTableItem(_ item: MKPlacemark) {
    selectedPin = item
  }
  
  /**
   Updates the map view in the parent view controller `OSCADefectFormViewController`
   with the selected `MKPlacemark`
   - Parameter pin
   */
  func updateFormMapView(with pin: MKPlacemark) {
    formViewModel.defectPosition = pin
  }
}
