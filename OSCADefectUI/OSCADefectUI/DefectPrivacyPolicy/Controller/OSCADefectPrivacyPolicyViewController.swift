//
//  OSCADefectPrivacyPolicyViewController.swift
//  OSCADefectUI
//
//  Created by Ömer Kurutay on 30.03.22.
//

import OSCAEssentials
import UIKit

public final class OSCADefectPrivacyPolicyViewController: UIViewController {
  
  @IBOutlet private var privacyTextContainer: UIView!
  @IBOutlet private var privacyTextView: UITextView!
  @IBOutlet private var textViewHeight: NSLayoutConstraint!
  
  private var viewModel: OSCADefectPrivacyPolicyViewModel!
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    self.setupViews()
    self.viewModel.viewDidLoad()
  }
  
  private func setupViews() {
    self.navigationItem.title = self.viewModel.screenTitle
    
    self.view.backgroundColor = OSCADefectUI.configuration.colorConfig.backgroundColor
    
    self.privacyTextContainer.backgroundColor = .clear
    
    self.privacyTextView.isScrollEnabled = false
    self.privacyTextView.textContainerInset = .zero
    self.privacyTextView.textContainer.lineFragmentPadding = 0
    
    let size = OSCADefectUI.configuration.fontConfig.bodyLight.pointSize
    let fontSize = "\(size)"
    let css = "<style> body {font-stretch: normal; font-size: \(fontSize)px; line-height: normal; font-family: 'Helvetica Neue'} </style>"
    let htmlString = "\(css)\(self.viewModel.privacyPolicy)"
    
    guard let attrString = try? NSMutableAttributedString(
      HTMLString: htmlString,
      color: OSCADefectUI.configuration.colorConfig.textColor)
    else { return }
    
    self.privacyTextView.attributedText = attrString
    self.privacyTextView.linkTextAttributes = [.foregroundColor: OSCADefectUI.configuration.colorConfig.primaryColor]
    
    self.textViewHeight.constant = self.privacyTextView.sizeThatFits(self.privacyTextView.frame.size).height
    
    self.view.layoutIfNeeded()
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    self.textViewHeight.constant = self.privacyTextView.sizeThatFits(self.privacyTextView.frame.size).height
    self.view.layoutIfNeeded()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setup(
      largeTitles: true,
      tintColor: OSCADefectUI.configuration.colorConfig.navigationTintColor,
      titleTextColor: OSCADefectUI.configuration.colorConfig.navigationTitleTextColor,
      barColor: OSCADefectUI.configuration.colorConfig.navigationBarColor)
  }
}

// MARK: - instantiate view controller
extension OSCADefectPrivacyPolicyViewController: StoryboardInstantiable {
  public static func create(with viewModel: OSCADefectPrivacyPolicyViewModel) -> OSCADefectPrivacyPolicyViewController {
    let vc: Self = Self.instantiateViewController(OSCADefectUI.bundle)
    vc.viewModel = viewModel
    return vc
  }
}
