// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit

import AVFoundation


class AudioChannelsView: View {

  var channelEvent = PublishSubject<AudioChannelEvent>()

  private var melodyContainer: MelodyContainer

  private var channelViews: [AudioChannelView] = []

  private let addChannelView = AddAudioChannelView()

  private var childrenDisposeBag = DisposeBag()

  private let disposeBag = DisposeBag()

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  init(melodyContainer: MelodyContainer) {
    self.melodyContainer = melodyContainer
    super.init()
    channelsListUpdated()

    addChannelView.channelAdded
      .subscribe(onNext: { [weak self] in
        self?.channelAddecd($0)
      })
      .disposed(by: disposeBag)
  }

  func channelsListUpdated() {
    channelViews = melodyContainer.channels.map { AudioChannelView(channel: $0) }
    setupLayout()
    listenForChildEvents()
  }

  private func setupLayout() {
    subviews.forEach { $0.removeFromSuperview() }

    (channelViews + [addChannelView]).enumerated().forEach { index, childView in
      let previousChildView = (index == 0) ? nil : channelViews[index - 1]

      add(
        childView: childView,
        after: previousChildView,
        isLast: index == channelViews.count
      )
    }
  }

  private func add(childView: UIView,
                   after previousChildView: UIView?,
                   isLast: Bool) {
    addSubview(childView)
    childView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      if let previousChildView {
        $0.top.equalTo(previousChildView.snp.bottom).offset(16)
      } else {
        $0.top.equalToSuperview()
      }

      if isLast { $0.bottom.equalToSuperview() }
    }
  }

  private func listenForChildEvents() {
    childrenDisposeBag = DisposeBag()

    channelViews.forEach { listenForChildEvents(of: $0) }
  }

  private func listenForChildEvents(of channelView: AudioChannelView) {
    channelView.channelEvent
      .subscribe(onNext: { [weak self, weak channelView] event in
        if let channelView {
          self?.updateChannel(channelView.channel, with: event)
        }
      })
      .disposed(by: childrenDisposeBag)

    channelView.deleteChannel
      .subscribe(onNext: { [weak self] in self?.deleteChannel($0) })
      .disposed(by: childrenDisposeBag)
  }

  func updateChannel(_ channel: AudioChannel,
                     with event: AudioChannelEvent) {
    melodyContainer.process(
      event: .channelChange(event)
    )
  }

  func channelAddecd(_ channel: AudioChannel) {
    melodyContainer.process(event: .channelAdded(channel))
    channelsListUpdated()
  }

  private func deleteChannel(_ channel: AudioChannel) {
    melodyContainer.process(event: .channelDeleted(id: channel.id))
    channelsListUpdated()
  }
}
