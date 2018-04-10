//
//  ViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for calendar view model.
public protocol Calendar99MainViewModelDependency {}

/// Factory for calendar view model dependency.
public protocol Calendar99MainViewModelDependencyFactory {

  /// Create a view model dependency for the main calendar view.
  ///
  /// - Returns: A Calendar99ViewModelDependency instance.
  func mainCalendarViewModelDependency() -> Calendar99MainViewModelDependency
}

/// View model for calendar view.
public protocol Calendar99MainViewModelType {

  /// Move forward by some months.
  var monthForwardReceiver: AnyObserver<UInt> { get }

  /// Move backward by some months.
  var monthBackwardReceiver: AnyObserver<UInt> { get }

  /// Set up stream bindings.
  func setupBindings()
}

public extension Calendar99.Main {
  
  /// View model implementation.
  public final class ViewModel: Calendar99MainViewModelType {
    public var monthForwardReceiver: AnyObserver<UInt> {
      return monthMovementSb.mapObserver(MonthDirection.forward)
    }

    public var monthBackwardReceiver: AnyObserver<UInt> {
      return monthMovementSb.mapObserver(MonthDirection.backward)
    }

    fileprivate let dependency: Calendar99MainViewModelDependency
    fileprivate let model: Calendar99MainModelType
    fileprivate let monthMovementSb: PublishSubject<MonthDirection>
    fileprivate let disposable: DisposeBag

    public init(_ dependency: Calendar99MainViewModelDependency,
                _ model: Calendar99MainModelType) {
      self.dependency = dependency
      self.model = model
      disposable = DisposeBag()
      monthMovementSb = PublishSubject()
    }

    public func setupBindings() {
      let disposable = self.disposable

      let monthMovementStream = monthMovementSb
        .withLatestFrom(model.monthStream) {($1, $0)}
        .withLatestFrom(model.yearStream) {($0.0, $1, $0.1.monthOffset)}
        .map({[weak self] in self?.model.newMonthAndYear($0, $1, $2)})
        .filter({$0.isSome}).map({$0!})
        .share(replay: 1)

      Observable
        .merge(model.initialMonthStream.asObservable(),
               monthMovementStream.map({$0.month}))
        .distinctUntilChanged()
        .do(onNext: {print("Month:", $0)})
        .subscribe(model.monthReceiver)
        .disposed(by: disposable)

      Observable
        .merge(model.initialYearStream.asObservable(),
               monthMovementStream.map({$0.year}))
        .distinctUntilChanged()
        .do(onNext: {print("Year:", $0)})
        .subscribe(model.yearReceiver)
        .disposed(by: disposable)
    }
  }
}
