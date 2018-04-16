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
}

// MARK: - All bindings.
public extension NNMonthHeaderViewModelType {
  public func setupAllBindingsAndSubBindings() {
    setupMonthControlBindings()
  }
}

public extension NNCalendar.MonthHeader {
  
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
      let monthControlVM = NNCalendar.MonthControl.ViewModel(model)
      self.init(monthControlVM, model)
    }
  }
}

// MARK: - NNMonthControlViewModelType
extension NNCalendar.MonthHeader.ViewModel: NNMonthControlViewModelType {
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
extension NNCalendar.MonthHeader.ViewModel: NNMonthHeaderViewModelType {
  public var monthDescriptionStream: Observable<String> {
    return model.currentMonthStream
      .map({[weak self] in self?.model.formatMonthDescription($0)})
      .filter({$0.isSome}).map({$0!})
  }
}
