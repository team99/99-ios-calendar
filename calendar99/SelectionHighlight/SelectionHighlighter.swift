//
//  Highlighter.swift
//  calendar99
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import calendar99_logic

/// Date selection highlighter that draws highlights on a Rect.
public protocol NNSelectionHighlighterType {

  /// Draw highlights in a rect with the specified highlight position.
  ///
  /// - Parameters:
  ///   - context: A CGContext instance.
  ///   - rect: A CGRect instance.
  ///   - pos: A HighlightPosition instance.
  func drawHighlight(_ context: CGContext,
                     _ rect: CGRect,
                     _ pos: NNCalendar.HighlightPosition)
}
