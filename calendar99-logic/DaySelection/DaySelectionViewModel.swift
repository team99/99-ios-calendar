//
//  DaySelectionViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the view model and its dependency so that
/// the view model exposes the same properties.
public protocol NNDaySelectionViewModelFunctionality {}

/// Dependency for day selection view model.
public protocol NNDaySelectionViewModelDependency:
  NNDaySelectionViewModelFunctionality {}

/// View model for day selection views.
public protocol NNDaySelectionViewModelType:
  NNDaySelectionViewModelFunctionality,
  NNDaySelectionFunctionality
{

  /// Receive single-date selections and compare it with global selections. If
  /// a date has already been selected, deselect it and vice versa.
  var dateSelectionReceiver: AnyObserver<Date> { get }

  /// Set up selection bindings.
  func setupBindings()
}

// MARK: - View model.
public extension NNCalendar.DaySelection {

  /// View model implementation.
  public final class ViewModel {
    fileprivate let dependency: NNDaySelectionViewModelDependency
    fileprivate let model: NNDaySelectionModelType
    fileprivate let dateSelectionSbj: PublishSubject<Date>
    fileprivate let disposable: DisposeBag

    public init(_ dependency: NNDaySelectionViewModelDependency,
                _ model: NNDaySelectionModelType) {
      self.dependency = dependency
      self.model = model
      disposable = DisposeBag()
      dateSelectionSbj = PublishSubject()
    }
  }
}

// MARK: - NNDaySelectionViewModelFunctionality
extension NNCalendar.DaySelection.ViewModel: NNDaySelectionViewModelFunctionality {
  public var dateSelectionReceiver: AnyObserver<Date> {
    return dateSelectionSbj.asObserver()
  }

  public func setupBindings() {
    let disposable = self.disposable

    dateSelectionSbj
      .withLatestFrom(model.dateSelectionStream) {($1, $0)}
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
      .subscribe(model.dateSelectionReceiver)
      .disposed(by: disposable)
  }
}

// MARK: - NNDaySelectionViewModelType
extension NNCalendar.DaySelection.ViewModel: NNDaySelectionViewModelType {}
