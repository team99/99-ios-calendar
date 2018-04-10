//
//  ViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for month header view model.
public protocol C99MonthHeaderViewModelDependency {}

/// Factory for month header view model dependency.
public protocol C99MonthHeaderViewModelDependencyFactory {

  /// Create a view model dependency for the month header view.
  ///
  /// - Returns: A Calendar99ViewModelDependency instance.
  func monthHeaderViewModelDependency() -> C99MonthHeaderViewModelDependency
}

/// View model for month header view.
public protocol C99MonthHeaderViewModelType: C99MonthHeaderFunctionality {

  /// Move forward by some months.
  var monthForwardReceiver: AnyObserver<UInt> { get }

  /// Move backward by some months.
  var monthBackwardReceiver: AnyObserver<UInt> { get }

  /// Stream month descriptions with the year.
  var monthDescriptionStream: Observable<String> { get }

  /// Set up stream bindings.
  func setupBindings()
}

public extension Calendar99.MonthHeader {
  
  /// View model implementation.
  public final class ViewModel: C99MonthHeaderViewModelType {
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

    fileprivate let dependency: C99MonthHeaderViewModelDependency
    fileprivate let model: C99MonthHeaderModelType
    fileprivate let monthMovementSb: PublishSubject<MonthDirection>
    fileprivate let disposable: DisposeBag

    public init(_ dependency: C99MonthHeaderViewModelDependency,
                _ model: C99MonthHeaderModelType) {
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
