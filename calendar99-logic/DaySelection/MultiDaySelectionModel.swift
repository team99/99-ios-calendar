//
//  MultiDaySelectionModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Shared functionalities between the model and its dependency that can have
/// defaults.
public protocol NNMultiDaySelectionDefaultFunction {}

/// Shared functionalities between the model and its dependency that cannot
/// have defaults. Any views that have the ability to influence the date
/// selection (e.g. month-grid view, weekday selection view whereby selecting a
/// weekday should selects all the dates with said weekday) should have its
/// model functionality conform to this protocol.
public protocol NNMultiDaySelectionNoDefaultFunction {

  /// Trigger selections. Beware that pushing to this stream will override all
  /// previous selections.
  var allSelectionReceiver: AnyObserver<Set<NNCalendar.Selection>> { get }

  /// Stream selections.
  var allSelectionStream: Observable<Try<Set<NNCalendar.Selection>>> { get }
}
