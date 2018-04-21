//
//  SelectableWeekdayViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// View model for selectable weekday display view. This is a decorator over the
/// week display view model.
public protocol NNSelectableWeekdayViewModelType: NNWeekdayDisplayViewModelType {}

// MARK: - View model.
public extension NNCalendar.SelectWeekday {

  /// View model implementation.
  public final class ViewModel {
    fileprivate let weekdayVM: NNWeekdayDisplayViewModelType
    fileprivate let model: NNSelectableWeekdayModelType
    fileprivate let disposable: DisposeBag

    required public init(_ weekdayVM: NNWeekdayDisplayViewModelType,
                         _ model: NNSelectableWeekdayModelType) {
      self.weekdayVM = weekdayVM
      self.model = model
      disposable = DisposeBag()
    }

    convenience public init(_ model: NNSelectableWeekdayModelType) {
      let weekdayVM = NNCalendar.WeekdayDisplay.ViewModel(model)
      self.init(weekdayVM, model)
    }
  }
}

// MARK: - NNWeekdayDisplayViewModelType
extension NNCalendar.SelectWeekday.ViewModel: NNWeekdayDisplayViewModelType {
  public var weekdayStream: Observable<[NNCalendar.Weekday]> {
    return weekdayVM.weekdayStream
  }

  public var weekdaySelectionIndexReceiver: AnyObserver<Int> {
    return weekdayVM.weekdaySelectionIndexReceiver
  }

  public var weekdaySelectionStream: Observable<Int> {
    return weekdayVM.weekdaySelectionStream
  }

  public func setupWeekDisplayBindings() {
    weekdayVM.setupWeekDisplayBindings()
    let disposable = self.disposable
    let firstWeekday = model.firstWeekday

    // In case:
    // - The user selects a weekday range (e.g. all Mondays).
    // - The user then deselects a Monday within said weekday range.
    // - The next time they selects the same range, some cells will be selected
    // (i.e. the previously deselected date) while the rest becomes deselected.
    weekdaySelectionStream
      .withLatestFrom(model.currentMonthStream) {($1, $0)}
      .map({$0.datesWithWeekday($1)})
      .map({Set($0.map({NNCalendar.DateSelection($0, firstWeekday)}))})
      .withLatestFrom(model.allSelectionStream) {
        return $1.getOrElse([]).symmetricDifference($0)
      }
      .subscribe(model.allSelectionReceiver)
      .disposed(by: disposable)

//    // Uncomment this (and comment the above binding) to quick-test repeat
//    // weekday selection.
//    weekdaySelectionStream
//      .map({NNCalendar.RepeatWeekdaySelection($0, firstWeekday)})
//      .withLatestFrom(model.allSelectionStream) {
//        return $1.getOrElse([]).symmetricDifference(Set(arrayLiteral: $0))
//      }
//      .subscribe(model.allSelectionReceiver)
//      .disposed(by: disposable)
  }
}

// MARK: - NNSelectableWeekdayViewModelType
extension NNCalendar.SelectWeekday.ViewModel: NNSelectableWeekdayViewModelType {}
