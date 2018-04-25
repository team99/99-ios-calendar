//
//  MonthAwareModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Shared functionalities between the model and its dependency that can have
/// defaults.
public protocol NNMonthAwareDefaultModelFunction {}

/// Shared functionalities between the model and its dependency that cannot
/// have defaults.
public protocol NNMonthAwareNoDefaultModelFunction {

  /// Stream the current selected components.
  var currentMonthStream: Observable<NNCalendarLogic.Month> { get }
}
