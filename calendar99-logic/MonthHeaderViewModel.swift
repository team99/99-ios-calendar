//
//  ViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// View model for month header view.
public protocol NNMonthHeaderViewModelType:
  NNMonthHeaderFunctionality,
  NNMonthControlViewModelType
{
  /// Stream month descriptions to populate the month display label.
  var monthDescriptionStream: Observable<String> { get }
}

public extension NNCalendar.MonthHeader {
  
  /// View model implementation.
  public final class ViewModel: NNMonthHeaderViewModelType {
    public var monthForwardReceiver: AnyObserver<UInt> {
      return monthControlVM.monthForwardReceiver
    }

    public var monthBackwardReceiver: AnyObserver<UInt> {
      return monthControlVM.monthBackwardReceiver
    }

    public var monthDescriptionStream: Observable<String> {
      return model.componentStream
        .map({[weak self] in self?.model.formatMonthDescription($0)})
        .filter({$0.isSome}).map({$0!})
        .distinctUntilChanged()
    }

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

    public func setupBindings() {
      /// Set up bindings in the month control view model to kickstart the
      /// month/year calculations.
      monthControlVM.setupBindings()
    }
  }
}
