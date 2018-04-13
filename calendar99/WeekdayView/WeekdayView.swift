//
//  WeekdayView.swift
//  calendar99
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxDataSources
import RxSwift
import calendar99_logic

/// Weekday view that displays weekdays.
public final class NNWeekdayView: UICollectionView {
  public var viewModel: NNWeekdayDisplayViewModelType? {
    willSet {
      #if DEBUG
      if viewModel != nil {
        fatalError("Cannot mutate view model!")
      }
      #endif
    }

    didSet {
      didSetViewModel()
    }
  }

  fileprivate lazy var disposable: DisposeBag = DisposeBag()
  fileprivate lazy var initialized = false

  override public func layoutSubviews() {
    super.layoutSubviews()
    guard !initialized else { return }
    initialized = true
    setupViews()
  }

  private func didSetViewModel() {
    bindViewModel()
  }
}

// MARK: - UICollectionViewFlowLayout
extension NNWeekdayView: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets.zero
  }

  public func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumLineSpacingForSectionAt section: Int)
    -> CGFloat
  {
    return 0
  }

  public func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumInteritemSpacingForSectionAt section: Int)
    -> CGFloat
  {
    return 0
  }

  public func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
    let bounds = collectionView.bounds

    return viewModel
      .map({
        // If the width is larger then the height, this should be a horizontal
        // scrolling view & vice versa.
        if bounds.width > bounds.height {
          let width = bounds.width / CGFloat($0.weekdayCount)
          return CGSize(width: width, height: bounds.height)
        } else {
          let height = bounds.height / CGFloat($0.weekdayCount)
          return CGSize(width: bounds.width, height: height)
        }
      })
      .getOrElse(CGSize.zero)
  }
}

// MARK: - Views.
public extension NNWeekdayView {
  fileprivate var cellId: String {
    return "WeekdayCell"
  }

  fileprivate func setupViews() {
    let bundle = Bundle(for: NNWeekdayView.classForCoder())
    let cellNib = UINib(nibName: "WeekdayCell", bundle: bundle)
    register(cellNib, forCellWithReuseIdentifier: cellId)
  }
}

// MARK: - Data sources.
public extension NNWeekdayView {
  typealias Section = SectionModel<String, NNCalendar.Weekday>
  typealias CVSource = CollectionViewSectionedDataSource<Section>
  typealias RxDataSource = RxCollectionViewSectionedReloadDataSource<Section>

  fileprivate func setupDataSource() -> RxDataSource {
    let dataSource = RxDataSource(configureCell: {[weak self] in
      return self?.configureCell($0, $1, $2, $3) ?? UICollectionViewCell()
    })

    dataSource.canMoveItemAtIndexPath = {(_, _) in false}
    return dataSource
  }

  private func configureCell(_ source: CVSource,
                             _ view: UICollectionView,
                             _ indexPath: IndexPath,
                             _ item: Section.Item) -> UICollectionViewCell {
    guard let cell = view.dequeueReusableCell(
      withReuseIdentifier: cellId,
      for: indexPath) as? NNWeekdayCell else
    {
      #if DEBUG
      fatalError("Invalid properties")
      #else
      return
      #endif
    }

    cell.setupWithWeekday(item)
    return cell
  }
}

// MARK: - View model bindings.
public extension NNWeekdayView {
  fileprivate func bindViewModel() {
    guard let viewModel = self.viewModel else {
      #if DEBUG
      fatalError("Properties cannot be nil")
      #else
      return
      #endif
    }

    viewModel.setupWeekDisplayBindings()
    let disposable = self.disposable
    let dataSource = setupDataSource()
    self.rx.setDelegate(self).disposed(by: disposable)

    viewModel.weekdayStream
      .map({[Section(model: "", items: $0)]})
      .observeOn(MainScheduler.instance)
      .bind(to: self.rx.items(dataSource: dataSource))
      .disposed(by: disposable)

    self.rx.itemSelected.map({$0.row})
      .bind(to: viewModel.weekdaySelectionIndexReceiver)
      .disposed(by: disposable)
  }
}
