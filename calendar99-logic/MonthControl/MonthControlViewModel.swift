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
  var monthForwardReceiver: AnyObserver<UInt> { get }

  /// Move backward by some months.
  var monthBackwardReceiver: AnyObserver<UInt> { get }

  /// Set up stream bindings.
  func setupBindings()
}

internal extension NNCalendar.MonthControl {
  /// Month control view model implementation.
  internal final class ViewModel: NNMonthControlViewModelType {
    internal var monthForwardReceiver: AnyObserver<UInt> {
      return monthMovementSb.mapObserver(MonthDirection.forward)
    }

    internal var monthBackwardReceiver: AnyObserver<UInt> {
      return monthMovementSb.mapObserver(MonthDirection.backward)
    }

    fileprivate let disposable: DisposeBag
    fileprivate let monthMovementSb: PublishSubject<MonthDirection>
    fileprivate let model: NNMonthControlModelType

    internal init(_ model: NNMonthControlModelType) {
      self.model = model
      disposable = DisposeBag()
      monthMovementSb = PublishSubject()
    }

    internal func setupBindings() {
      let disposable = self.disposable

      let monthMovementStream = monthMovementSb
        .withLatestFrom(model.componentStream) {($1, $0.monthOffset)}
        .map({[weak self] in self?.model.newComponents($0, $1)})
        .filter({$0.isSome}).map({$0!})
        .share(replay: 1)

      Observable
        .merge(model.initialComponentStream.asObservable(), monthMovementStream)
        .distinctUntilChanged()
        .subscribe(model.componentReceiver)
        .disposed(by: disposable)
    }
  }
}
