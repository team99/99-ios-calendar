//
//  MonthViewDecorator.swift
//  calendar99
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit
import calendar99_logic

/// Decorator for month display view.
public protocol NNMonthViewDecoratorType {

  /// Background color for month view.
  var monthViewBackgroundColor: UIColor { get }

  /// Get a date cell decorator.
  ///
  /// - Parameters:
  ///   - indexPath: An IndexPath instance.
  ///   - item: A Day instance.
  /// - Returns: A NNDateCellDecoratorType instance.
  func dateCellDecorator(_ indexPath: IndexPath, _ item: NNCalendarLogic.Day)
    -> NNDateCellDecoratorType
}

