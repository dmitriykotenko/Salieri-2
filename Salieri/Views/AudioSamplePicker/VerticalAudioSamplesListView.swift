// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit

import AVFoundation


class VerticalAudioSamplesListView: View {

  lazy var audioSample = BehaviorSubject<AudioSample?>(value: samples[0])

  lazy var audioSamplePicked = PublishSubject<AudioSample>()

  var samples: [AudioSample] {
    didSet { setupLayout() }
  }

  private let scrollView = UIScrollView().preparedForAutoLayout()
  private var sampleViews: [UIView] = []

  private let sampleButtonHeight: CGFloat = 44
  private let insets: UIEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
  private let cornerRadius: CGFloat = 8

  private let disposeBag = DisposeBag()

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  init(samples: [AudioSample]) {
    self.samples = samples

    super.init()

    setupLayout()
  }

  private func setupLayout() {
//    backgroundColor = .systemYellow

    subviews.forEach { $0.removeFromSuperview() }
    snp.removeConstraints()

    let expectedContentHeight =
      CGFloat(samples.count) * sampleButtonHeight + insets.top + insets.bottom

    snp.makeConstraints {
      $0.height.equalTo(expectedContentHeight.clamped(inside: 0...250))
      $0.width.equalTo(120)
    }

    scrollView.layer.cornerRadius = cornerRadius
    addSubview(scrollView)
    scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }

    let contentView = initContentView()
//    contentView.backgroundColor = .systemPink

//    scrollView.backgroundColor = .systemGreen
    scrollView.addSubview(contentView)

    contentView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.trailing.bottom.equalToSuperview()
      $0.width.equalTo(self)
    }
  }

  private func initContentView() -> UIView {
    let sampleViews = samples.map {
      UIButton.small(height: sampleButtonHeight)
        .with(backgroundColor: .clear)
        .with(titleColor: .black, forState: .normal)
        .with(selectedTitleColor: .systemRed)
        .with(title: $0.name)
    }

    zip(samples, sampleViews).forEach { sample, view in
      view.rx.tap
        .subscribe(onNext: { [weak self] in
          self?.audioSample.onNext(sample)
          self?.audioSamplePicked.onNext(sample)
        })
        .disposed(by: disposeBag)
    }

    let contentView = View()
    contentView.backgroundColor = .systemYellow
    contentView.clipsToBounds = true
    contentView.layer.cornerRadius = cornerRadius

    contentView.addVerticalStack(
      ofChildViews: sampleViews,
      insets: insets
    )

    return contentView
  }
}
