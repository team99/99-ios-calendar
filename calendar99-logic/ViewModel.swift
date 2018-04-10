//
//  ViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for calendar view model.
public protocol Calendar99ViewModelDependency {}

/// Factory for calendar view model dependency.
public protocol Calendar99ViewModelDependencyFactory {

  /// Create a view model dependency.
  ///
  /// - Returns: A Calendar99ViewModelDependency instance.
  func calendarViewModelDependency() -> Calendar99ViewModelDependency
}

/// View model for calendar view.
public protocol Calendar99ViewModelType {

  /// Move forward by some months.
  var monthForwardReceiver: AnyObserver<Int> { get }

  /// Move backward by some months.
  var monthBackwardReceiver: AnyObserver<Int> { get }

  /// Set up stream bindings.
  func setupBindings()
}

public extension Calendar99.Main {
  
  /// View model implementation.
  public final class ViewModel: Calendar99ViewModelType {
    public var monthForwardReceiver: AnyObserver<Int> {
      return monthMovementSb.mapObserver(MonthDirection.forward)
    }

    public var monthBackwardReceiver: AnyObserver<Int> {
      return monthMovementSb.mapObserver(MonthDirection.backward)
    }

    fileprivate let dependency: Calendar99ViewModelDependency
    fileprivate let model: Calendar99ModelType
    fileprivate let monthMovementSb: PublishSubject<MonthDirection>
    fileprivate let disposable: DisposeBag

    public init(_ dependency: Calendar99ViewModelDependency,
                _ model: Calendar99ModelType) {
      self.dependency = dependency
      self.model = model
      disposable = DisposeBag()
      monthMovementSb = PublishSubject()
    }

    public func setupBindings() {
      let disposable = self.disposable

      monthMovementSb
        .withLatestFrom(model.monthStream) {($1, $0)}
        .withLatestFrom(model.yearStream) {($0.0, $1, $0.1.monthOffset)}

    }
  }
}
