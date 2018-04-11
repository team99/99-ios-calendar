//
//  MonthControlViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// View model for controlling month. This can be used both by the month header
/// (with the forward/backward buttons) and the month view (right/left swipes).
public protocol NNMonthControlViewModelType {

  /// Move forward by some months.
  var currentMonthForwardReceiver: AnyObserver<UInt> { get }

  /// Move backward by some months.
  var currentMonthBackwardReceiver: AnyObserver<UInt> { get }

  /// Set up stream bindings.
  func setupBindings()
}

internal extension NNCalendar.MonthControl {
  /// Month control view model implementation.
  internal final class ViewModel: NNMonthControlViewModelType {
    internal var currentMonthForwardReceiver: AnyObserver<UInt> {
      return currentMonthMovementSb.mapObserver(MonthDirection.forward)
    }

    internal var currentMonthBackwardReceiver: AnyObserver<UInt> {
      return currentMonthMovementSb.mapObserver(MonthDirection.backward)
    }

    fileprivate let disposable: DisposeBag
    fileprivate let currentMonthMovementSb: PublishSubject<MonthDirection>
    fileprivate let model: NNMonthControlModelType

    internal init(_ model: NNMonthControlModelType) {
      self.model = model
      disposable = DisposeBag()
      currentMonthMovementSb = PublishSubject()
    }

    internal func setupBindings() {
      let disposable = self.disposable

      let monthMovementStream = currentMonthMovementSb
        .withLatestFrom(model.currentComponentStream) {($1, $0.monthOffset)}
        .map({[weak self] in self?.model.newComponents($0, $1)})
        .filter({$0.isSome}).map({$0!})
        .share(replay: 1)

      Observable
        .merge(model.initialComponentStream.asObservable(), monthMovementStream)
        .distinctUntilChanged()
        .subscribe(model.currentComponentReceiver)
        .disposed(by: disposable)
    }
  }
}
