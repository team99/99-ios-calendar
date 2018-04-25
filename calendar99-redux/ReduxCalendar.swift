//
//  ReduxCalendar.swift
//  calendar99-redux
//
//  Created by Hai Pham on 18/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import HMReactiveRedux
import calendar99_logic

// MARK: - Redux calendar.
public extension NNCalendarRedux.Calendar {

  /// Calendar actions, including month, date selections etc.
  public enum Action: ReduxActionType {
    case updateCurrentMonth(NNCalendarLogic.Month)
    case updateSelection(Set<NNCalendarLogic.Selection>)
    case clearAll

    fileprivate static var basePath: String {
      return "calendar99.calendar"
    }

    public static var currentMonthPath: String {
      return "\(basePath).currentMonth"
    }

    public static var selectionPath: String {
      return "\(basePath).selection"
    }
  }

  /// Calendar reducers.
  public final class Reducer {

    /// Reduce calendar actions to produce a new state.
    ///
    /// - Parameters:
    ///   - prevState: A TreeState instance.
    ///   - action: An Action instance.
    /// - Returns: A TreeState instance.
    public static func reduce(_ prevState: TreeState<Any>,
                              _ action: Action) -> TreeState<Any> {
      switch action {
      case .updateCurrentMonth(let month):
        return prevState.updateValue(Action.currentMonthPath, month)

      case .updateSelection(let selection):
        return prevState.updateValue(Action.selectionPath, selection)

      case .clearAll:
        return prevState.removeSubstate(Action.basePath)
      }
    }
  }
}
