//
//  OSCADefectLocationViewController.swift
//  OSCADefectUI
//
//  Created by Ömer Kurutay on 03.03.22.
//

import OSCAEssentials
import UIKit
import MapKit
import Combine

public final class OSCADefectLocationViewController: UIViewController {
  
  @IBOutlet private var mapView: MKMapView!
  
  var viewModel: OSCADefectLocationViewModel!
  private var bindings = Set<AnyCancellable>()
  
  var defectLocationTabeViewController: OSCADefectLocationTableViewController?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    self.setupViews()
    self.setupBindings()
    self.viewModel.viewDidLoad()
  }
  
  private func setupViews() {
    self.mapView.delegate = self
    self.mapView.register(MKPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: "pin")
    
    let resultSearchController = UISearchController(searchResultsController: self.defectLocationTabeViewController)
    resultSearchController.searchResultsUpdater = self.defectLocationTabeViewController
    resultSearchController.hidesNavigationBarDuringPresentation = false
    resultSearchController.obscuresBackgroundDuringPresentation = true
    self.definesPresentationContext = true
    
    self.defectLocationTabeViewController?.mapView = self.mapView
    
    let searchBar = resultSearchController.searchBar
    searchBar.sizeToFit()
    searchBar.placeholder = self.viewModel.searchBarPlaceholder
    
    self.navigationItem.searchController = resultSearchController
    self.navigationItem.title = self.viewModel.screenTitle
    
    if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
      textfield.textColor = OSCADefectUI.configuration.colorConfig.blackColor
      textfield.tintColor = OSCADefectUI.configuration.colorConfig.navigationTintColor
      textfield.backgroundColor = OSCADefectUI.configuration.colorConfig.grayLight
      textfield.leftView?.tintColor = OSCADefectUI.configuration.colorConfig.grayDarker
      textfield.returnKeyType = .done
      textfield.keyboardType = .default
      textfield.enablesReturnKeyAutomatically = false
      
      if let clearButton = textfield.value(forKey: "_clearButton") as? UIButton {
        let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
        clearButton.setImage(templateImage, for: .normal)
        clearButton.tintColor = OSCADefectUI.configuration.colorConfig.grayDarker
      }
      
      if let label = textfield.value(forKey: "placeholderLabel") as? UILabel {
        label.attributedText = NSAttributedString(
          string: self.viewModel.searchBarPlaceholder,
          attributes: [.foregroundColor: OSCADefectUI.configuration.colorConfig.grayDarker])
      }
    }
    
    self.view.backgroundColor = OSCADefectUI.configuration.colorConfig.backgroundColor
  }
  
  private func setupBindings() {
    self.viewModel.$selectedPin
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] in
        guard let pin = $0 else { return }
        self?.setAnnotationView(for: pin)
        self?.viewModel.updateFormMapView(with: pin)
      })
      .store(in: &self.bindings)
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setup(
      tintColor: OSCADefectUI.configuration.colorConfig.navigationTintColor,
      titleTextColor: OSCADefectUI.configuration.colorConfig.navigationTitleTextColor,
      barColor: OSCADefectUI.configuration.colorConfig.navigationBarColor)
  }
  
  /// Sets the annotation view for a placemark
  /// - Parameter placemark: the placemark
  private func setAnnotationView(for placemark: MKPlacemark) {
    guard let mapView = self.mapView else { return }
    mapView.removeAnnotations(mapView.annotations)
    let annotation = MKPointAnnotation()
    annotation.coordinate = placemark.coordinate
    if let thoroughfare = placemark.thoroughfare, let subThoroughfare = placemark.subThoroughfare {
      annotation.title = "\(thoroughfare) \(subThoroughfare)"
    }
    
    mapView.addAnnotation(annotation)
    let span = MKCoordinateSpan(latitudeDelta: 0.05,
                                longitudeDelta: 0.05)
    let region = MKCoordinateRegion(center: placemark.coordinate,
                                    span: span)
    mapView.setRegion(region, animated: true)
  }
}

// MARK: - instantiate view conroller
extension OSCADefectLocationViewController: StoryboardInstantiable {
  public static func create(with viewModel: OSCADefectLocationViewModel) -> OSCADefectLocationViewController {
    let vc = Self.instantiateViewController(OSCADefectUI.bundle)
    vc.viewModel = viewModel
    return vc
  }
}

extension OSCADefectLocationViewController: MKMapViewDelegate {
  public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation {
      return nil
    }
    
    let view = mapView.dequeueReusableAnnotationView(withIdentifier: "pin", for: annotation)
    if let pinAnnotationView = view as? MKPinAnnotationView {
      pinAnnotationView.isDraggable = true
      
      return pinAnnotationView
    } else {
      return nil
    }
  }
  
  public func mapView(_: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState _: MKAnnotationView.DragState) {
    if newState == .ending {
      guard let coord = view.annotation?.coordinate else { return }
      viewModel.mapViewDragStateEnded(at: coord)
    }
  }
}
