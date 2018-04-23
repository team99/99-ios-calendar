//
//  WeekdayDecorator.swift
//  calendar99
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit
import calendar99_logic

/// Decorator for weekday view.
public protocol NNWeekdayViewDecoratorType {

  /// Background color for weekday view.
  var weekdayViewBackground: UIColor { get }

  /// Get a weekday cell decorator.
  ///
  /// - Parameters:
  ///   - indexPath: An IndexPath instance.
  ///   - item: A Weekday instance.
  /// - Returns: A NNWeekdayCellDecoratorType instance.
  func weekdayCellDecorator(_ indexPath: IndexPath, _ item: NNCalendar.Weekday)
    -> NNWeekdayCellDecoratorType
}

/// Decorator for weekday cell view.
public protocol NNWeekdayCellDecoratorType {

  /// Text color for weekday description label.
  var weekdayDescriptionTextColor: UIColor { get }

  /// Font for weekday description label.
  var weekdayDescriptionFont: UIFont { get }
}
