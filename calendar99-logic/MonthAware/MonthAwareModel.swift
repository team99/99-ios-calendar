//
//  MonthAwareModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and its dependency.
public protocol NNMonthAwareModelFunctionality {

  /// Stream the current selected components.
  var currentMonthCompStream: Observable<NNCalendar.MonthComp> { get }
}

/// Dependency for month-aware model.
public protocol NNMonthAwareModelDependency: NNMonthAwareModelFunctionality {}
