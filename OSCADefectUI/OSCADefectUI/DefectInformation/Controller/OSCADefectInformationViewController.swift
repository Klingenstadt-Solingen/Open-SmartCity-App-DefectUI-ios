//
//  OSCADefectInformationViewController.swift
//  OSCADefectUI
//
//  Created by Ömer Kurutay on 03.03.22.
//

import OSCAEssentials
import UIKit

public final class OSCADefectInformationViewController: UIViewController {
  
  @IBOutlet private var infoImageContainer: UIView!
  @IBOutlet private var infoImage: UIImageView!
  @IBOutlet private var infoLabel: UILabel!
  
  private var viewModel: OSCADefectInformationViewModel!
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    self.setupViews()
    self.setupBindings()
    self.viewModel.viewDidLoad()
  }
  
  private func setupViews() {
    self.navigationItem.title = self.viewModel.screenTitle
    
    self.view.backgroundColor = OSCADefectUI.configuration.colorConfig.backgroundColor
    
    self.infoImageContainer.backgroundColor = .clear
    self.infoImageContainer.addShadow(with: OSCADefectUI.configuration.shadow)
    
    self.infoImage.image = UIImage(named: viewModel.infoImage,
                                   in: OSCADefectUI.bundle,
                                   with: nil)
    self.infoImage.layer.cornerRadius = OSCADefectUI.configuration.cornerRadius
    
    self.infoLabel.text = self.viewModel.info
    self.infoLabel.font = OSCADefectUI.configuration.fontConfig.bodyLight
    self.infoLabel.textColor = OSCADefectUI.configuration.colorConfig.textColor
  }
  
  private func setupBindings() {}
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setup(
      largeTitles: true,
      tintColor: OSCADefectUI.configuration.colorConfig.navigationTintColor,
      titleTextColor: OSCADefectUI.configuration.colorConfig.navigationTitleTextColor,
      barColor: OSCADefectUI.configuration.colorConfig.navigationBarColor)
  }
}

// MARK: - instantiate view conroller
extension OSCADefectInformationViewController: StoryboardInstantiable {
  public static func create(with viewModel: OSCADefectInformationViewModel) -> OSCADefectInformationViewController {
    let vc = Self.instantiateViewController(OSCADefectUI.bundle)
    vc.viewModel = viewModel
    return vc
  }
}
