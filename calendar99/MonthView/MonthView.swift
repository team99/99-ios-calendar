//
//  View.swift
//  calendar99
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import SwiftFP
import calendar99_logic

/// Month view implementation. This view should be quite memory-efficient since
/// it calculates dates lazily based on the user's current month selection. As
/// a result, it does not have scrolling animations when switching months, so
/// if we are looking for feel instead of function, skip this.
public final class NNMonthView: UICollectionView {
  public typealias Decorator = NNMonthViewDecoratorType
  public typealias ViewModel = NNMonthDisplayViewModelType
  public typealias Dependency = (ViewModel, Decorator)

  public var dependency: Dependency? {
    willSet {
      #if DEBUG
      if dependency != nil {
        fatalError("Cannot mutate!")
      }
      #endif
    }

    didSet {
      bindViewModel()
      setupViewsWithDecorator()
    }
  }

  fileprivate var viewModel: ViewModel? { return dependency?.0 }
  fileprivate var decorator: Decorator? { return dependency?.1 }
  fileprivate lazy var disposable: DisposeBag = DisposeBag()

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupViews()
  }

  override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)
    setupViews()
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NNMonthView: UICollectionViewDelegateFlowLayout {
  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForHeaderInSection section: Int) -> CGSize
  {
    return CGSize.zero
  }

  public func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets.zero
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int) -> CGFloat
  {
    return 0
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
  {
    return 0
  }

  public func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cHeight = collectionView.bounds.height
    let cWidth = collectionView.bounds.width
    let weekdays = NNCalendarLogic.Util.weekdayCount

    return viewModel
      .map({(cWidth / CGFloat(weekdays), cHeight / CGFloat($0.weekdayStacks))})
      .map({CGSize(width: $0, height: $1)})
      .getOrElse(CGSize.zero)
  }
}

// MARK: - Views.
public extension NNMonthView {
  fileprivate var cellId: String {
    return "DateCell"
  }

  /// Set up views/sub-views in the calendar view.
  fileprivate func setupViews() {
    let bundle = Bundle(for: NNDateCell.classForCoder())
    let cellNib = UINib(nibName: "DateCell", bundle: bundle)
    register(cellNib, forCellWithReuseIdentifier: cellId)
  }

  fileprivate func setupViewsWithDecorator() {
    guard let decorator = self.decorator else { return }
    backgroundColor = decorator.monthViewBackgroundColor
  }
}

// MARK: - Data source.
public extension NNMonthView {
  typealias Section = AnimatableSectionModel<String, NNCalendarLogic.Day>
  typealias CVSource = CollectionViewSectionedDataSource<Section>
  typealias RxDataSource = RxCollectionViewSectionedAnimatedDataSource<Section>

  /// Use RxDataSources to drive data.
  fileprivate func setupDataSource() -> RxDataSource {
    let dataSource = RxDataSource(
      configureCell: {[weak self] in
        if let `self` = self {
          return self.configureCell($0, $1, $2, $3)
        } else {
          return UICollectionViewCell()
        }
      },
      configureSupplementaryView: {[weak self] in
        if let `self` = self {
          return self.configureSupplementaryView($0, $1, $2, $3)
        } else {
          return UICollectionReusableView()
        }
    })

    dataSource.animationConfiguration = AnimationConfiguration(
      insertAnimation: .fade,
      reloadAnimation: .fade,
      deleteAnimation: .fade
    )

    dataSource.canMoveItemAtIndexPath = {(_, _) in false}
    return dataSource
  }

  private func configureCell(_ source: CVSource,
                             _ view: UICollectionView,
                             _ indexPath: IndexPath,
                             _ item: Section.Item)
    -> UICollectionViewCell
  {
    guard
      let viewModel = self.viewModel,
      let decorator = self.decorator,
      let cell = view.dequeueReusableCell(
        withReuseIdentifier: cellId,
        for: indexPath) as? NNDateCell else
    {
      #if DEBUG
      fatalError("Unrecognized cell")
      #else
      return UICollectionViewCell()
      #endif
    }

    let selected = viewModel.isDateSelected(item.date)
    
    let actualDay = item
      .with(selected: viewModel.isDateSelected(item.date))
      .with(highlightPart: viewModel.highlightPart(item.date))

    let cellDecorator = decorator.dateCellDecorator(indexPath, actualDay)
    cell.setupWithDay(cellDecorator, actualDay)
    return cell
  }

  private func configureSupplementaryView(_ source: CVSource,
                                          _ view: UICollectionView,
                                          _ kind: String,
                                          _ indexPath: IndexPath)
    -> UICollectionReusableView
  {
    return UICollectionReusableView()
  }
}

// MARK: - View model bindings.
public extension NNMonthView {
  fileprivate func bindViewModel() {
    guard let viewModel = self.viewModel else {
      #if DEBUG
      fatalError("Properties cannot be nil")
      #else
      return
      #endif
    }

    viewModel.setupAllBindingsAndSubBindings()
    let disposable = self.disposable
    let dataSource = setupDataSource()
    self.rx.setDelegate(self).disposed(by: disposable)

    viewModel.dayStream
      .map({[Section(model: "", items: $0)]})
      .observeOn(MainScheduler.instance)
      .bind(to: self.rx.items(dataSource: dataSource))
      .disposed(by: disposable)

    self.rx.itemSelected
      .map({NNCalendarLogic.GridPosition(0, $0.row)})
      .bind(to: viewModel.gridSelectionReceiver)
      .disposed(by: disposable)

    // Listen to day index selection to know where to reload.
    viewModel.gridDayIndexSelectionChangesStream
      .map({$0.map({IndexPath(row: $0, section: 0)})})
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: {[weak self] in self?.reloadItems(at: $0)})
      .disposed(by: disposable)
  }
}

extension NNCalendarLogic.Day: IdentifiableType {
  public typealias Identity = String

  public var identity: Identity {
    return "\(date).\(isCurrentMonth)"
  }
}
