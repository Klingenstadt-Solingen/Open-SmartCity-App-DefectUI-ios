//
//  OSCADefectFormPhotoCollectionViewCell.swift
//  OSCADefectUI
//
//  Created by Ömer Kurutay on 02.03.22.
//

import OSCAEssentials
import UIKit

public final class OSCADefectFormPhotoCollectionViewCell: UICollectionViewCell {
  static let reuseIdentifier = String(describing: OSCADefectFormPhotoCollectionViewCell.self)
  
  @IBOutlet private var imageView: UIImageView!
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.addShadow(with: OSCADefectUI.configuration.shadow)
    self.contentView.layer.cornerRadius = OSCADefectUI.configuration.cornerRadius
  }
  
  /// Sets up the cell
  /// - Parameter image: image for the cell
  func fill(with imageData: Data) {
    self.imageView?.image = UIImage(data: imageData)
  }
}
