//
//  Util.swift
//  calendar99
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import calendar99_logic

public extension NNCalendar {

  /// View utilities.
  public final class ViewUtil {

    /// Initialize a view with nib.
    ///
    /// - Parameter named: The name of the nib file.
    public static func initializeWithNib(view: UIView, _ named: String) {
      let cls: AnyClass = view.classForCoder

      guard
        view.subviews.count == 0,
        let nibView = UINib
          .init(nibName: named, bundle: Bundle(for: cls))
          .instantiate(withOwner: view, options: nil)[0]
          as? UIView else
      {
        return
      }

      nibView.frame = view.bounds
      nibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      view.addSubview(nibView)
    }
  }
}
