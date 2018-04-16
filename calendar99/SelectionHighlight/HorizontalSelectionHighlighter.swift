//
//  HorizontalSelectionHighlighter.swift
//  calendar99
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit
import calendar99_logic

/// Horizontal selection highlighter.
public final class NNHorizontalSelectionHighlighter {
  public init() {}
}

// MARK: - NNSelectionHighlighterType
extension NNHorizontalSelectionHighlighter: NNSelectionHighlighterType {
  public func drawHighlight(_ context: CGContext,
                            _ rect: CGRect,
                            _ pos: NNCalendar.HighlightPosition) {
    context.saveGState()
    defer { context.restoreGState() }
    var highlightRect = rect.insetBy(dx: 0, dy: 5)
    let bezier: UIBezierPath

    switch pos {
    case .startAndEnd:
      highlightRect = highlightRect.insetBy(dx: 5, dy: 0)
      bezier = UIBezierPath(roundedRect: highlightRect, cornerRadius: 5)

    case .start:
      highlightRect = highlightRect.offsetBy(dx: 5, dy: 0)

      bezier = UIBezierPath(roundedRect: highlightRect,
                            byRoundingCorners: [.topLeft, .bottomLeft],
                            cornerRadii: CGSize(width: 5, height: 5))

    case .end:
      highlightRect = CGRect(x: highlightRect.origin.x,
                             y: highlightRect.origin.y,
                             width: highlightRect.width - 5,
                             height: highlightRect.height)

      bezier = UIBezierPath(roundedRect: highlightRect,
                            byRoundingCorners: [.topRight, .bottomRight],
                            cornerRadii: CGSize(width: 5, height: 5))

    default:
      bezier = UIBezierPath(rect: highlightRect)
    }

    context.setFillColor(UIColor.groupTableViewBackground.cgColor)
    bezier.fill()
  }
}
