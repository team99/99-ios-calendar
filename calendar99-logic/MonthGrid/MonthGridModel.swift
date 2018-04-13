//
//  MonthGridModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for month grid model.
public protocol NNMonthGridModelDependency {}

/// Model for month grid views.
public protocol NNMonthGridModelType {}

// MARK: - Model.
public extension NNCalendar.MonthGrid {

  /// Model implementation.
  public final class Model {
    fileprivate let dependency: NNMonthGridModelDependency

    public init(_ dependency: NNMonthGridModelDependency) {
      self.dependency = dependency
    }
  }
}

// MARK: - NNMonthGridModelType
extension NNCalendar.MonthGrid.Model: NNMonthGridModelType {}
