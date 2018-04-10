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

  /// Stream month descriptions with the year.
  var monthDescriptionStream: Observable<String> { get }

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

    public var monthDescriptionStream: Observable<String> {
      return model.componentStream
        .map({[weak self] in self?.model.formatMonthDescription($0)})
        .filter({$0.isSome}).map({$0!})
        .distinctUntilChanged()
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
