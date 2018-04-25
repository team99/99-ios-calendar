//
//  MonthGridViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// View model for month-grid based views.
public protocol NNMonthGridViewModelType:
  NNGridDisplayDefaultFunction,
  NNGridDisplayNoDefaultFunction
{
  /// Trigger grid item selection. Each grid selection corresponds to an Index
  /// Path in the current month grid.
  var gridSelectionReceiver: AnyObserver<NNCalendarLogic.GridPosition> { get }

  /// Stream grid selections.
  var gridSelectionStream: Observable<NNCalendarLogic.GridPosition> { get }
}

// MARK: - ViewModel.
public extension NNCalendarLogic.MonthGrid {

  /// View model implementation for month grid view.
  public final class ViewModel {
    fileprivate let model: NNMonthGridModelType
    fileprivate let gridSelectionSb: PublishSubject<NNCalendarLogic.GridPosition>

    required public init(_ model: NNMonthGridModelType) {
      self.model = model
      gridSelectionSb = PublishSubject()
    }
  }
}

// MARK: - NNGridDisplayDefaultFunction
extension NNCalendarLogic.MonthGrid.ViewModel: NNGridDisplayDefaultFunction {
  public var weekdayStacks: Int { return model.weekdayStacks }
}

// MARK: - NNMonthGridViewModelType
extension NNCalendarLogic.MonthGrid.ViewModel: NNMonthGridViewModelType {
  public var gridSelectionStream: Observable<NNCalendarLogic.GridPosition> {
    return gridSelectionSb.asObservable()
  }

  public var gridSelectionReceiver: AnyObserver<NNCalendarLogic.GridPosition> {
    return gridSelectionSb.asObserver()
  }
}
