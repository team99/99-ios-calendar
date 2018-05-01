//
//  SingleDaySelectionViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// View model for single day selection views.
public protocol NNSingleDaySelectionViewModelType: NNSingleDaySelectionFunction {
  
  /// Receive single dates and compare them against the global selections to
  /// decide whether to select or deselect.
  var dateSelectionReceiver: AnyObserver<Date> { get }

  /// Set up selection bindings.
  func setupDaySelectionBindings()
}

// MARK: - View model.
public extension NNCalendarLogic.DaySelect {

  /// View model implementation.
  public final class ViewModel {
    fileprivate let model: NNSingleDaySelectionModelType
    fileprivate let dateSelectionSbj: PublishSubject<Date>
    fileprivate let disposable: DisposeBag

    public init(_ model: NNSingleDaySelectionModelType) {
      self.model = model
      disposable = DisposeBag()
      dateSelectionSbj = PublishSubject()
    }
  }
}

// MARK: - NNSingleDaySelectionFunction
extension NNCalendarLogic.DaySelect.ViewModel: NNSingleDaySelectionFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return model.isDateSelected(date)
  }
}

// MARK: - NNDaySelectionViewModelType
extension NNCalendarLogic.DaySelect.ViewModel: NNSingleDaySelectionViewModelType {
  public var dateSelectionReceiver: AnyObserver<Date> {
    return dateSelectionSbj.asObserver()
  }

  /// Every time a day is selected, we need to check whether it is already in
  /// the selection set. If it is, remove it.
  public func setupDaySelectionBindings() {
    let disposable = self.disposable
    let firstWeekday = model.firstWeekday

    dateSelectionSbj
      .map({NNCalendarLogic.DateSelection($0, firstWeekday) as NNCalendarLogic.Selection})
      .withLatestFrom(model.allSelectionStream) {($1.getOrElse([]), $0)}
      .map({$0.contains($1)
          ? $0.subtracting(Set(arrayLiteral: $1))
          : $0.union(Set(arrayLiteral: $1))})
      .subscribe(model.allSelectionReceiver)
      .disposed(by: disposable)
  }
}
