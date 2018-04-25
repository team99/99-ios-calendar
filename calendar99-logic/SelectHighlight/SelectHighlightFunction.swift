//
//  SelectHighlightFunction.swift
//  calendar99-logic
//
//  Created by Hai Pham on 17/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Shared functionalities between the model and view model that can have
/// defaults.
public protocol NNSelectHighlightDefaultFunction {}

/// Shared functionalities between the model and view model that cannot have
/// defaults.
public protocol NNSelectHighlightNoDefaultFunction {

  /// Calculate highlight part for a Date. The reason for this absence of rx
  /// can be found in documentation for isDateSelected(:_).
  ///
  /// - Parameter date: A Date instance.
  /// - Returns: A HighlightPart instance.
  func highlightPart(_ date: Date) -> NNCalendarLogic.HighlightPart
}
