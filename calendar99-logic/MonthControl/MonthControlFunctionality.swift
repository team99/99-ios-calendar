//
//  MonthControlFunctionality.swift
//  calendar99-logic
//
//  Created by Hai Pham on 21/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and view model that can have
/// defaults.
public protocol NNMonthControlDefaultFunction {}

/// Shared functionalities between the model and view model that cannot have
/// defaults.
public protocol NNMonthControlNoDefaultFunction {
  
  /// Receive the current month and push it somewhere for external streaming.
  var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> { get }
}
