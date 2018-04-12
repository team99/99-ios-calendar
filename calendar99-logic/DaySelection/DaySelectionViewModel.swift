//
//  DaySelectionViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// View model for day selection views.
public protocol NNDaySelectionViewModelType: NNDaySelectionFunctionality {

  /// Receive single dates and compare them against the global selections to
  /// decide whether to select or deselect.
  var dateSelectionReceiver: AnyObserver<Date> { get }

  /// Set up selection bindings.
  func setupDaySelectionBindings()
}

// MARK: - View model.
public extension NNCalendar.DaySelection {

  /// View model implementation.
  public final class ViewModel {
    fileprivate let model: NNDaySelectionModelType
    fileprivate let dateSelectionSbj: PublishSubject<Date>
    fileprivate let disposable: DisposeBag

    public init(_ model: NNDaySelectionModelType) {
      self.model = model
      disposable = DisposeBag()
      dateSelectionSbj = PublishSubject()
    }
  }
}

// MARK: - NNDaySelectionFunctionality
extension NNCalendar.DaySelection.ViewModel: NNDaySelectionFunctionality {
  public var allDateSelectionStream: Observable<Set<Date>> {
    return model.allDateSelectionStream
  }

  public func isDateSelected(_ date: Date) -> Bool {
    return model.isDateSelected(date)
  }
}

// MARK: - NNDaySelectionViewModelType
extension NNCalendar.DaySelection.ViewModel: NNDaySelectionViewModelType {
  public var dateSelectionReceiver: AnyObserver<Date> {
    return dateSelectionSbj.asObserver()
  }

  public func setupDaySelectionBindings() {
    let disposable = self.disposable

    dateSelectionSbj
      .withLatestFrom(model.allDateSelectionStream) {($1, $0)}
      .map({(prev: Set<Date>, date: Date) -> Set<Date> in
        if prev.contains(date) {
          return prev.filter({$0 != date})
        } else {
          var newSet = Set(prev)
          newSet.insert(date)
          return newSet
        }
      })
      .distinctUntilChanged()
      .subscribe(model.allDateSelectionReceiver)
      .disposed(by: disposable)
  }
}
