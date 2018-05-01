//
//  ViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// View model for month header view.
public protocol NNMonthHeaderViewModelType: NNMonthControlViewModelType {

  /// Stream month descriptions to populate the month display label.
  var monthDescriptionStream: Observable<String> { get }

  /// Emit an event whenever the user has reached the minimum month.
  var reachedMinimumMonth: Observable<Bool> { get }

  /// Emit an event whenever the user has reached the maximum month.
  var reachedMaximumMonth: Observable<Bool> { get }
}

// MARK: - All bindings.
public extension NNMonthHeaderViewModelType {
  public func setupAllBindingsAndSubBindings() {
    setupMonthControlBindings()
  }
}

/// Factory for month header view model.
public protocol NNMonthHeaderViewModelFactory {

  /// Create a month header view model.
  ///
  /// - Returns: A NNMonthHeaderViewModelType instance.
  func monthHeaderViewModel() -> NNMonthHeaderViewModelType
}

public extension NNCalendarLogic.MonthHeader {
  
  /// View model implementation.
  public final class ViewModel {

    /// Delegate month controlling to this view model.
    fileprivate let monthControlVM: NNMonthControlViewModelType
    fileprivate let model: NNMonthHeaderModelType
    fileprivate let disposable: DisposeBag

    required public init(_ monthControlVM: NNMonthControlViewModelType,
                         _ model: NNMonthHeaderModelType) {
      self.monthControlVM = monthControlVM
      self.model = model
      disposable = DisposeBag()
    }

    convenience public init(_ model: NNMonthHeaderModelType) {
      let monthControlVM = NNCalendarLogic.MonthControl.ViewModel(model)
      self.init(monthControlVM, model)
    }
  }
}

// MARK: - NNMonthControlFunction
extension NNCalendarLogic.MonthHeader.ViewModel: NNMonthControlFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
    return monthControlVM.currentMonthReceiver
  }
}

// MARK: - NNMonthControlViewModelType
extension NNCalendarLogic.MonthHeader.ViewModel: NNMonthControlViewModelType {
  public var currentMonthForwardReceiver: AnyObserver<UInt> {
    return monthControlVM.currentMonthForwardReceiver
  }

  public var currentMonthBackwardReceiver: AnyObserver<UInt> {
    return monthControlVM.currentMonthBackwardReceiver
  }

  public func setupMonthControlBindings() {
    monthControlVM.setupMonthControlBindings()
  }
}

// MARK: - NNMonthHeaderViewModelType
extension NNCalendarLogic.MonthHeader.ViewModel: NNMonthHeaderViewModelType {
  public var reachedMinimumMonth: Observable<Bool> {
    let minMonth = model.minimumMonth
    return model.currentMonthStream.map({$0 == minMonth}).distinctUntilChanged()
  }

  public var reachedMaximumMonth: Observable<Bool> {
    let maxMonth = model.maximumMonth
    return model.currentMonthStream.map({$0 == maxMonth}).distinctUntilChanged()
  }

  public var monthDescriptionStream: Observable<String> {
    return model.currentMonthStream
      .map({[weak self] in self?.model.formatMonthDescription($0)})
      .filter({$0.isSome}).map({$0!})
  }
}
