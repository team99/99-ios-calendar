//
//  SelectionHighlightView.swift
//  calendar99
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit

/// This view detects date selections and draw continuous highlights to reflect
/// those selections.
public final class NNSelectionHighlightView: UIView {
  override public func draw(_ rect: CGRect) {
    super.draw(rect)

    guard let context = UIGraphicsGetCurrentContext() else {
      #if DEBUG
      fatalError("Graphics context not available")
      #else
      return
      #endif
    }
  }
}
