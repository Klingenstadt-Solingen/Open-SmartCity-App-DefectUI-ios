//
//  OSCADefectLocationTableViewModel.swift
//  OSCADefectUI
//
//  Created by Ömer Kurutay on 03.03.22.
//

import OSCAEssentials
import class MapKit.MKMapItem
import class MapKit.MKPlacemark
import class MapKit.MKLocalSearch
import struct MapKit.MKCoordinateRegion
import Combine

public struct OSCADefectLocationTableViewModelActions {}


public enum OSCADefectLocationTableViewModelState: Equatable {
  case searching
  case selected
}

public final class OSCADefectLocationTableViewModel {
  private let actions: OSCADefectLocationTableViewModelActions?
  private let locationViewModel: OSCADefectLocationViewModel
  private var bindings = Set<AnyCancellable>()
  
  // MARK: - Initializer
  public init(actions: OSCADefectLocationTableViewModelActions,
              viewModel: OSCADefectLocationViewModel) {
    self.actions = actions
    self.locationViewModel = viewModel
  }
  
  // MARK: OUTPUT
  
  @Published private(set) var state: OSCADefectLocationTableViewModelState = .searching
  
  var searchResults: [MKMapItem] = []
}

// MARK: - INPUT. View event methods
extension OSCADefectLocationTableViewModel {
  func viewDidLoad() {}
  
  /// Parses the address for a placemark
  /// - Parameter item: The placemark
  /// - Returns: an address
  func parseAddress(for item: MKPlacemark) -> String {
    let firstSpace = (item.subThoroughfare != nil && item.thoroughfare != nil) ? " " : ""
    let comma = (item.subThoroughfare != nil || item.thoroughfare != nil) && (item.subAdministrativeArea != nil || item.administrativeArea != nil) ? ", " : ""
    let secondComma = (item.subAdministrativeArea != nil && item.administrativeArea != nil) ? ", " : ""
    let addressLine = String(
      format: "%@%@%@%@%@%@%@",
      // Street number
      item.thoroughfare ?? "",
      firstSpace,
      // Street name
      item.subThoroughfare ?? "",
      comma,
      // City
      item.locality ?? "",
      secondComma,
      // State
      item.administrativeArea ?? ""
    )
    return addressLine
  }
  
  /**
   Updates the table view with the search results.
   - Parameter searchText
   - Parameter region
   */
  func updateSearchResults(with searchText: String, in region: MKCoordinateRegion) {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = searchText
    request.region = region
    
    let search = MKLocalSearch(request: request)
    
    search.start { response, _ in
      guard let response = response else { return }
      self.searchResults = response.mapItems
      self.state = .searching
    }
  }
  
  /**
   Dismisses the table view and passes the selected search result
   to the parent view controller `OSCADefectLocationViewModel`.
   - Parameter index: The index of the selected search result
   */
  func didSelectItem(at index: Int) {
    state = .selected
    locationViewModel.didSelectLocationTableItem(searchResults[index].placemark)
  }
}
