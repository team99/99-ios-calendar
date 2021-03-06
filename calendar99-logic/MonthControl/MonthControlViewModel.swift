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
public protocol NNMonthControlViewModelType: NNMonthControlFunction {

  /// Move forward by some months.
  var currentMonthForwardReceiver: AnyObserver<Void> { get }

  /// Move backward by some months.
  var currentMonthBackwardReceiver: AnyObserver<Void> { get }

  /// Set up stream bindings.
  func setupMonthControlBindings()
}

public extension NNCalendarLogic.MonthControl {
  
  /// Month control view model implementation.
  public final class ViewModel {
    fileprivate let disposable: DisposeBag
    fileprivate let currentMonthMovementSb: PublishSubject<MonthDirection>
    fileprivate let model: NNMonthControlModelType

    public init(_ model: NNMonthControlModelType) {
      self.model = model
      disposable = DisposeBag()
      currentMonthMovementSb = PublishSubject()
    }
  }
}

// MARK: - NNMonthControlFunction
extension NNCalendarLogic.MonthControl.ViewModel: NNMonthControlFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
    return model.currentMonthReceiver
  }
}

// MARK: - NNMonthControlViewModelType
extension NNCalendarLogic.MonthControl.ViewModel: NNMonthControlViewModelType {
  public var currentMonthForwardReceiver: AnyObserver<Void> {
    return currentMonthMovementSb.mapObserver({MonthDirection.forward(1)})
  }

  public var currentMonthBackwardReceiver: AnyObserver<Void> {
    return currentMonthMovementSb.mapObserver({MonthDirection.backward(1)})
  }

  public func setupMonthControlBindings() {
    let disposable = self.disposable
    let minMonth = model.minimumMonth
    let maxMonth = model.maximumMonth

    Observable
      .merge(
        model.initialMonthStream.asObservable(),

        currentMonthMovementSb
          .withLatestFrom(model.currentMonthStream) {($1, $0.monthOffset)}
          .map({$0.with(monthOffset: $1)})
          .filter({$0.isSome}).map({$0!})
      )
      .map({Swift.min(maxMonth, Swift.max(minMonth, $0))})
      .subscribe(model.currentMonthReceiver)
      .disposed(by: disposable)
  }
}
