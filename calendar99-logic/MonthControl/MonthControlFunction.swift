//
//  MonthControlFunction.swift
//  calendar99-logic
//
//  Created by Hai Pham on 21/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and view model.
public protocol NNMonthControlFunction {
  
  /// Receive the current month and push it somewhere for external streaming.
  var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> { get }
}
