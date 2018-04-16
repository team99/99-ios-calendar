//
//  SelectHighlightFunction.swift
//  calendar99-logic
//
//  Created by Hai Pham on 17/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Shared functionalities between the model and view model for views that can
/// highlight date selections.
public protocol NNSelectHighlightFunction {

  /// Calculate highlight position for a Date.
  ///
  /// - Parameter date: A Date instance.
  /// - Returns: A HighlightPosition instance.
  func calculateHighlightPos(_ date: Date) -> NNCalendar.HighlightPosition
}
