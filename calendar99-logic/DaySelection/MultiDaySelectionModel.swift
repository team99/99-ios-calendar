//
//  MultiDaySelectionModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the model and its dependency. Any views that
/// have the ability to influence the date selection (e.g. month-grid view,
/// weekday selection view whereby selecting a weekday should selects all the
/// dates with said weekday) should have its model functionality conform to
/// this protocol.
public protocol NNMultiDaySelectionModelFunction {

  /// Trigger date selections. Beware that pushing to this stream will override
  /// all previous selections.
  var allDateSelectionReceiver: AnyObserver<Set<Date>> { get }

  /// Stream date selections.
  var allDateSelectionStream: Observable<Set<Date>> { get }
}
