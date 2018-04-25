//
//  Regular99DelegateBridge.swift
//  calendar99-legacy
//
//  Created by Hai Pham on 24/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP
import calendar99_logic
import calendar99_presetLogic
import calendar99_preset

// MARK: - Delegate bridge.
extension NNCalendarLegacy.Regular99 {

  /// Delegate bridge for Regular99 calendar preset.
  final class DelegateBridge {
    fileprivate weak var calendar: NNRegular99Calendar?
    fileprivate let delegate: NNRegular99CalendarDelegate?
    fileprivate let currentMonthSb: BehaviorSubject<Void>
    fileprivate let selectionSb: BehaviorSubject<Void>

    private init(_ delegate: NNRegular99CalendarDelegate) {
      self.delegate = delegate
      currentMonthSb = BehaviorSubject(value: ())
      selectionSb = BehaviorSubject(value: ())
    }

    convenience init(_ calendar: NNRegular99Calendar,
                     _ delegate: NNRegular99CalendarDelegate) {
      self.init(Wrapper(delegate))
      self.calendar = calendar
    }

    convenience init(_ calendar: NNRegular99Calendar,
                     _ delegate: NNRegular99CalendarNoDefaultDelegate) {
      self.init(DefaultDelegate(delegate))
      self.calendar = calendar
    }
  }
}

// MARK: - NNGridDisplayDefaultFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNGridDisplayDefaultFunction {
  var weekdayStacks: Int {
    return calendar.zipWith(delegate, {$1.weekdayStacks(for: $0)}).getOrElse(0)
  }
}

// MARK: - NNMonthAwareNoDefaultModelFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNMonthAwareNoDefaultModelFunction {
  var currentMonthStream: Observable<NNCalendar.Month> {
    return currentMonthSb
      .map({[weak self] in (self?.calendar).zipWith(self?.delegate, {
        $1.currentMonth(for: $0)})
      })
      .filter({$0.isSome}).map({$0!})
  }
}

// MARK: - NNMonthControlNoDefaultFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNMonthControlNoDefaultFunction {
  var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    return currentMonthSb.mapObserver({[weak self] month -> Void in
      (self?.calendar).zipWith(self?.delegate, {
        $1.regular99($0, onCurrentMonthChangedTo: month)
      })
    })
  }
}

// MARK: - NNMonthControlNoDefaultModelFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNMonthControlNoDefaultModelFunction {
  var minimumMonth: NNCalendar.Month {
    return calendar.zipWith(delegate, {$1.minimumMonth(for: $0)})
      .getOrElse(NNCalendar.Month(Date()))
  }

  var maximumMonth: NNCalendar.Month {
    return calendar.zipWith(delegate, {$1.maximumMonth(for: $0)})
      .getOrElse(NNCalendar.Month(Date()))
  }

  var initialMonthStream: Single<NNCalendar.Month> {
    return Single.just(calendar.zipWith(delegate, {$1.initialMonth(for: $0)})
      .getOrElse(NNCalendar.Month(Date())))
  }
}

// MARK: - NNMonthHeaderDefaultModelFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNMonthHeaderDefaultModelFunction {
  func formatMonthDescription(_ month: NNCalendar.Month) -> String {
    return calendar.zipWith(delegate, {
      $1.regular99($0, monthDescriptionFor: month)
    }).getOrElse("")
  }
}

// MARK: - NNMultiDaySelectionNoDefaultFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNMultiDaySelectionNoDefaultFunction {
  var allSelectionReceiver: AnyObserver<Set<NNCalendar.Selection>> {
    return selectionSb.mapObserver({[weak self] selection -> Void in
      (self?.calendar).zipWith(self?.delegate, {
        $1.regular99($0, onSelectionChangedTo: selection)
      })
    })
  }

  var allSelectionStream: Observable<Try<Set<NNCalendar.Selection>>> {
    return selectionSb
      .map({[weak self] in (self?.calendar).zipWith(self?.delegate, {
        $1.currentSelections(for: $0)
      })})
      .filter({$0.isSome}).map({$0!.asTry()})
  }
}

// MARK: - NNMultiMonthGridSelectionCalculator
extension NNCalendarLegacy.Regular99.DelegateBridge: NNMultiMonthGridSelectionCalculator {
  func gridSelectionChanges(_ monthComps: [NNCalendar.MonthComp],
                            _ currentMonth: NNCalendar.Month,
                            _ prev: Set<NNCalendar.Selection>,
                            _ current: Set<NNCalendar.Selection>)
    -> Set<NNCalendar.GridPosition>
  {
    return calendar.zipWith(delegate, {
      $1.regular99($0, gridSelectionChangesFor: monthComps,
                           whileCurrentMonthIs: currentMonth,
                           withPreviousSelection: prev,
                           andCurrentSelection: current)
    }).getOrElse([])
  }
}

// MARK: - NNSelectHighlightNoDefaultFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNSelectHighlightNoDefaultFunction {
  func highlightPart(_ date: Date) -> NNCalendar.HighlightPart {
    return calendar.zipWith(delegate, {$1.regular99($0, highlightPartFor: date)})
      .getOrElse(.none)
  }
}

// MARK: - NNSingleDaySelectionNoDefaultFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNSingleDaySelectionNoDefaultFunction {
  func isDateSelected(_ date: Date) -> Bool {
    return calendar.zipWith(delegate, {$1.regular99($0, isDateSelected: date)})
      .getOrElse(false)
  }
}

// MARK: - NNWeekdayAwareNoDefaultModelFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNWeekdayAwareNoDefaultModelFunction {
  var firstWeekday: Int {
    return calendar.zipWith(delegate, {$1.firstWeekday(for: $0)}).getOrElse(1)
  }
}

// MARK: - NNWeekdayDisplayDefaultModelFunction
extension NNCalendarLegacy.Regular99.DelegateBridge: NNWeekdayDisplayDefaultModelFunction {
  func weekdayDescription(_ weekday: Int) -> String {
    return calendar.zipWith(delegate, {
      $1.regular99($0, weekdayDescriptionFor: weekday)
    }).getOrElse("")
  }
}

// MARK: - NNRegular99CalendarModelDependency
extension NNCalendarLegacy.Regular99.DelegateBridge: NNRegular99CalendarModelDependency {}

// MARK: - Delegate wrapper.
extension NNCalendarLegacy.Regular99.DelegateBridge {

  /// Wrapper for delegate to store reference weakly. This is because we need
  /// to store a strong reference to the delegate in the bridge class to cater
  /// to default dependencies.
  final class Wrapper: NNRegular99CalendarDelegate {
    private weak var delegate: NNRegular99CalendarDelegate?

    init(_ delegate: NNRegular99CalendarDelegate) {
      self.delegate = delegate
    }

    /// Defaultable.
    func firstWeekday(for calendar: NNRegular99Calendar) -> Int {
      return delegate?.firstWeekday(for: calendar) ?? 1
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   weekdayDescriptionFor weekday: Int) -> String {
      return delegate?.regular99(calendar, weekdayDescriptionFor: weekday) ?? ""
    }

    func weekdayStacks(for calendar: NNRegular99Calendar) -> Int {
      return delegate?.weekdayStacks(for: calendar) ?? 0
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   monthDescriptionFor month: NNCalendar.Month) -> String {
      return NNCalendar.Util.defaultMonthDescription(month)
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   gridSelectionChangesFor months: [NNCalendar.MonthComp],
                   whileCurrentMonthIs month: NNCalendar.Month,
                   withPreviousSelection prev: Set<NNCalendar.Selection>,
                   andCurrentSelection current: Set<NNCalendar.Selection>)
      -> Set<NNCalendar.GridPosition>
    {
      return delegate?.regular99(calendar,
                                 gridSelectionChangesFor: months,
                                 whileCurrentMonthIs: month,
                                 withPreviousSelection: prev,
                                 andCurrentSelection: current) ?? []
    }

    /// Non-defaultable.
    func minimumMonth(for calendar: NNRegular99Calendar) -> NNCalendar.Month {
      return delegate?.minimumMonth(for: calendar) ?? NNCalendar.Month(Date())
    }

    func maximumMonth(for calendar: NNRegular99Calendar) -> NNCalendar.Month {
      return delegate?.maximumMonth(for: calendar) ?? NNCalendar.Month(Date())
    }

    func initialMonth(for calendar: NNRegular99Calendar) -> NNCalendar.Month {
      return delegate?.initialMonth(for: calendar) ?? NNCalendar.Month(Date())
    }

    func currentMonth(for calendar: NNRegular99Calendar) -> NNCalendar.Month {
      return delegate?.currentMonth(for: calendar) ?? NNCalendar.Month(Date())
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   onCurrentMonthChangedTo month: NNCalendar.Month) {
      delegate?.regular99(calendar, onCurrentMonthChangedTo: month)
    }

    func currentSelections(for calendar: NNRegular99Calendar) -> Set<NNCalendar.Selection>? {
      return delegate?.currentSelections(for: calendar) ?? []
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   onSelectionChangedTo selections: Set<NNCalendar.Selection>) {
      delegate?.regular99(calendar, onSelectionChangedTo: selections)
    }

    func regular99(_ calendar: NNRegular99Calendar, isDateSelected date: Date) -> Bool {
      return delegate?.regular99(calendar, isDateSelected: date) ?? false
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   highlightPartFor date: Date) -> NNCalendar.HighlightPart {
      return delegate?.regular99(calendar, highlightPartFor: date) ?? .none
    }
  }
}

// MARK: - Default delegate
extension NNCalendarLegacy.Regular99.DelegateBridge {
  final class DefaultDelegate: NNRegular99CalendarDelegate {
    private let highlightCalc: NNCalendar.DateCalc.HighlightPart
    private weak var delegate: NNRegular99CalendarNoDefaultDelegate?

    init(_ delegate: NNRegular99CalendarNoDefaultDelegate) {
      self.delegate = delegate
      let weekdayStacks = 6
      let sequentialCalc = NNCalendar.DateCalc.Default(weekdayStacks, 1)
      highlightCalc = NNCalendar.DateCalc.HighlightPart(sequentialCalc, weekdayStacks)
    }

    /// Defaultable.
    func firstWeekday(for calendar: NNRegular99Calendar) -> Int {
      return 1
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   weekdayDescriptionFor weekday: Int) -> String {
      return NNCalendar.Util.defaultWeekdayDescription(weekday)
    }

    func weekdayStacks(for calendar: NNRegular99Calendar) -> Int {
      return highlightCalc.weekdayStacks
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   monthDescriptionFor month: NNCalendar.Month) -> String {
      return NNCalendar.Util.defaultMonthDescription(month)
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   gridSelectionChangesFor months: [NNCalendar.MonthComp],
                   whileCurrentMonthIs month: NNCalendar.Month,
                   withPreviousSelection prev: Set<NNCalendar.Selection>,
                   andCurrentSelection current: Set<NNCalendar.Selection>)
      -> Set<NNCalendar.GridPosition>
    {
      return highlightCalc.gridSelectionChanges(months, month, prev, current)
    }

    /// Non-defaultable.
    func minimumMonth(for calendar: NNRegular99Calendar) -> NNCalendar.Month {
      return delegate?.minimumMonth(for: calendar) ?? NNCalendar.Month(Date())
    }

    func maximumMonth(for calendar: NNRegular99Calendar) -> NNCalendar.Month {
      return delegate?.maximumMonth(for: calendar) ?? NNCalendar.Month(Date())
    }

    func initialMonth(for calendar: NNRegular99Calendar) -> NNCalendar.Month {
      return delegate?.initialMonth(for: calendar) ?? NNCalendar.Month(Date())
    }

    func currentMonth(for calendar: NNRegular99Calendar) -> NNCalendar.Month {
      return delegate?.currentMonth(for: calendar) ?? NNCalendar.Month(Date())
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   onCurrentMonthChangedTo month: NNCalendar.Month) {
      delegate?.regular99(calendar, onCurrentMonthChangedTo: month)
    }

    func currentSelections(for calendar: NNRegular99Calendar) -> Set<NNCalendar.Selection>? {
      return delegate?.currentSelections(for: calendar) ?? []
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   onSelectionChangedTo selections: Set<NNCalendar.Selection>) {
      delegate?.regular99(calendar, onSelectionChangedTo: selections)
    }

    func regular99(_ calendar: NNRegular99Calendar, isDateSelected date: Date) -> Bool {
      return delegate?.regular99(calendar, isDateSelected: date) ?? false
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   highlightPartFor date: Date) -> NNCalendar.HighlightPart {
      return delegate?.regular99(calendar, highlightPartFor: date) ?? .none
    }
  }
}

// MARK: - Delegate bridge
public extension NNRegular99Calendar {
  public typealias NoDefaultDelegate = NNRegular99CalendarNoDefaultDelegate
  public typealias Delegate = NNRegular99CalendarDelegate
  public typealias NoDefaultLegacyDependency = (NoDefaultDelegate, Decorator)
  public typealias LegacyDependency = (Delegate, Decorator)

  /// Non-defaultable legacy dependencies.
  public var noDefaultLegacyDependency: NoDefaultLegacyDependency? {
    get { return nil }

    set {
      guard let newValue = newValue else {
        #if DEBUG
        fatalError("Properties cannot be nil")
        #else
        return
        #endif
      }

      let modelDp = NNCalendarLegacy.Regular99.DelegateBridge(self, newValue.0)
      let model = NNCalendarPreset.Regular99.Model(modelDp)
      let viewModel = NNCalendarPreset.Regular99.ViewModel(model)
      dependency = (viewModel, newValue.1)
    }
  }
}