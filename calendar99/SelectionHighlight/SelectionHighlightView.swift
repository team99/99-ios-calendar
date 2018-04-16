//
//  SelectionHighlightView.swift
//  calendar99
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit
import calendar99_logic

/// This view detects date selections and draw continuous highlights to reflect
/// those selections.
public final class NNSelectionHighlightView: UIView {
  public typealias ViewModel = NNSelectHighlightViewModelType
  public typealias Dependency = ViewModel

  public var dependency: Dependency? {
    get { return nil }

    set {
      viewModel = newValue
      didSetViewModel()
    }
  }

  fileprivate var viewModel: ViewModel? {
    willSet {
      #if DEBUG
      if viewModel != nil {
        fatalError("Cannot mutate view model")
      }
      #endif
    }
  }

  private lazy var initialized = false

  override public func layoutSubviews() {
    super.layoutSubviews()
    guard !initialized else { return }
    initialized = true
    setupViews()
  }

  override public func draw(_ rect: CGRect) {
    super.draw(rect)

    guard let context = UIGraphicsGetCurrentContext() else {
      #if DEBUG
      fatalError("Graphics context not available")
      #else
      return
      #endif
    }

    #if DEBUG
    drawGrid(context, rect)
    #endif
  }

  private func didSetViewModel() {
    bindViewModel()
  }
}

// MARK: - Grid draw.
public extension NNSelectionHighlightView {

  /// Draw grid lines (in debug mode?) to align highlights. This should not be
  /// in production.
  fileprivate func drawGrid(_ context: CGContext, _ rect: CGRect) {
    guard let viewModel = self.viewModel else {
      #if DEBUG
      fatalError("Properties cannot be nil")
      #else
      return
      #endif
    }

    let viewWidth = bounds.width
    let viewHeight = bounds.height
    let columnWidth = viewWidth / CGFloat(viewModel.columnCount)
    let rowHeight = viewHeight / CGFloat(viewModel.rowCount)

    // Variables are reused to optimize performance.
    var x, y: CGFloat
    var childRect = CGRect.zero

    // Set stroke color.
    context.setStrokeColor(UIColor.red.cgColor)

    for row in 0..<viewModel.rowCount {
      x = 0
      y = rowHeight * CGFloat(row)
      childRect = CGRect(x: x, y: y, width: viewWidth, height: rowHeight)
      context.stroke(childRect)
    }

    for column in 0..<viewModel.columnCount {
      x = columnWidth * CGFloat(column)
      y = 0
      childRect = CGRect(x: x, y: y, width: columnWidth, height: viewHeight)
      context.stroke(childRect)
    }
  }
}

// MARK: - Views.
public extension NNSelectionHighlightView {
  fileprivate func setupViews() {
    backgroundColor = .clear
  }
}

// MARK: - View model bindings.
public extension NNSelectionHighlightView {
  fileprivate func bindViewModel() {}
}
