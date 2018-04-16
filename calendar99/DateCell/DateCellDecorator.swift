//
//  DateCellDecorator.swift
//  calendar99
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit

/// Decorator for date cell.
public protocol NNDateCellDecoratorType {

  /// Selection highlighter.
  var selectionHighlighter: NNSelectionHighlighterType { get }

  /// Background color for today marker.
  var dateCellTodayMarkerBackground: UIColor { get }

  /// Text color for date description label.
  ///
  /// - Parameter state: A NNDateCellDescState instance.
  /// - Returns: An UIColor value.
  func dateCellDescTextColor(_ state: NNDateCellDescState) -> UIColor

  /// Background color for background.
  ///
  /// - Parameter state: A NNDateCellBackgroundState instance.
  /// - Returns: A UIColor value.
  func dateCellBackground(_ state: NNDateCellBackgroundState) -> UIColor
}
