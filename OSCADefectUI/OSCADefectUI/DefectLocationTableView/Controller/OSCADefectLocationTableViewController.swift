//
//  OSCADefectLocationTableViewController.swift
//  OSCADefectUI
//
//  Created by Ömer Kurutay on 03.03.22.
//

import OSCAEssentials
import UIKit
import MapKit
import Combine

public final class OSCADefectLocationTableViewController: UITableViewController {
  
  /// The map view of the parent view controller `OSCADefectLocationViewController` after initialization
  var mapView: MKMapView?
  
  private var viewModel: OSCADefectLocationTableViewModel!
  private var bindings = Set<AnyCancellable>()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    self.setupViews()
    self.setupBindings()
    self.viewModel.viewDidLoad()
  }
  
  private func setupViews() {
    self.view.backgroundColor = .clear
  }
  
  private func setupBindings() {
    let stateValueHandler: (OSCADefectLocationTableViewModelState) -> Void = { [weak self] viewModelState in
      guard let `self` = self else { return }
      
      switch viewModelState {
      case .searching:
        self.tableView.reloadData()
        
      case .selected:
        self.dismiss(animated: true, completion: nil)
      }
    }
    
    self.viewModel.$state
      .receive(on: RunLoop.main)
      .sink(receiveValue: stateValueHandler)
      .store(in: &self.bindings)
  }
  
  // MARK: - Table view data source
  
  public override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    self.viewModel.searchResults.count
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: "cell")
    else { return UITableViewCell() }
    
    cell.backgroundColor = OSCADefectUI.configuration.colorConfig.secondaryBackgroundColor.withAlphaComponent(0.85)
    
    let rowItem = self.viewModel.searchResults[indexPath.row].placemark
    cell.textLabel?.text = rowItem.name
    cell.detailTextLabel?.text = self.viewModel.parseAddress(for: rowItem)
    
    cell.textLabel?.font = OSCADefectUI.configuration.fontConfig.subheaderLight
    cell.detailTextLabel?.font = OSCADefectUI.configuration.fontConfig.bodyLight
    
    cell.textLabel?.textColor = OSCADefectUI.configuration.colorConfig.textColor
    cell.detailTextLabel?.textColor = OSCADefectUI.configuration.colorConfig.textColor
    
    return cell
  }
  
  public override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.viewModel.didSelectItem(at: indexPath.row)
  }
}

// MARK: - instantiate view conroller
extension OSCADefectLocationTableViewController: StoryboardInstantiable {
  public static func create(with viewModel: OSCADefectLocationTableViewModel) -> OSCADefectLocationTableViewController {
    let vc = Self.instantiateViewController(OSCADefectUI.bundle)
    vc.viewModel = viewModel
    return vc
  }
}

extension OSCADefectLocationTableViewController: UISearchResultsUpdating {
  public func updateSearchResults(for searchController: UISearchController) {
    guard let mapView = self.mapView,
          let searchBarText = searchController.searchBar.text
    else { return }
    
    self.viewModel.updateSearchResults(with: searchBarText,
                                       in: mapView.region)
  }
}
