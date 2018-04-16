//
//  SelectionHighlightViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the view model and dependency for selection
/// highlight view.
public protocol NNSelectionHighlightViewModelFunction:
  NNGridDisplayViewModelFunction {}

/// Dependency for selection highlight view model.
public protocol NNSelectionHighlightViewModelDependency:
  NNSelectionHighlightViewModelFunction,
  NNMGridDisplayViewModelDependency {}

/// View model for selection highlight view.
public protocol NNSelectionHighlightViewModelType:
  NNSelectionHighlightViewModelFunction,
  NNGridDisplayViewModelType {}
