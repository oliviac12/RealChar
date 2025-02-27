//
//  ConfigView.swift
//  rac
//
//  Created by ZongZiWang on 7/9/23.
//

import SwiftUI
import CachedAsyncImage
import AVFAudio
import Shimmer

struct CharacterOption: Identifiable, Equatable {
    let id: Int
    let name: String
    let description: String
    let imageUrl: URL?
}

struct ConfigView: View {

    let options: [CharacterOption]
    let hapticFeedback: Bool
    @Binding var loaded: Bool
    @Binding var selectedOption: CharacterOption?
    @Binding var openMic: Bool
    let onConfirmConfig: (CharacterOption) -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 20) {
                Text("Choose your partner")
                    .font(
                        Font.custom("Prompt", size: 18).weight(.medium)
                    )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if loaded && !options.isEmpty {
                            ForEach(options) { option in
                                CharacterOptionView(option: option, selected: option == selectedOption)
                                    .onTapGesture {
                                        if selectedOption == option {
                                            selectedOption = nil
                                        } else {
                                            selectedOption = option
                                        }
                                    }
                            }
                        } else {
                            ForEach(0..<6) { id in
                                CharacterOptionView(option: .init(id: id, name: "Placeholder", description: "", imageUrl: nil), selected: false)
                                    .redacted(reason: .placeholder)
                                    .shimmering()
                            }
                        }
                    }
                    .padding(2)
                }

                Toggle(isOn: $openMic) {
                    Text("Wearing headphone?")
                        .font(
                            Font.custom("Prompt", size: 16)
                        )
                }
                .tint(.accentColor)
                .padding(.trailing, 2)

                CtaButton(style: .primary, action: {
                    guard let selectedOption else { return }
                    onConfirmConfig(selectedOption)
                }, text: "Get started")
                .disabled(selectedOption == nil)
            }
            .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 20)
        }
        .onAppear {
            openMic = headphoneOrBluetoothDeviceConnected
        }
    }

    var headphoneOrBluetoothDeviceConnected: Bool {
        !AVAudioSession.sharedInstance().currentRoute.outputs.compactMap {
            ($0.portType == .headphones ||
             $0.portType == .headsetMic ||
             $0.portType == .bluetoothA2DP ||
             $0.portType == .bluetoothHFP ||
             $0.portType == .bluetoothLE) ? true : nil
        }.isEmpty
    }
}

struct CharacterOptionView: View {
    @Environment(\.colorScheme) var colorScheme

    let option: CharacterOption
    let selected: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 22) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 40, height: 40)
                        .background(Color(red: 0.76, green: 0.83, blue: 1))
                        .cornerRadius(20)
                    if let imageUrl = option.imageUrl {
                        CachedAsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image.resizable()
                            default:
                                Image(systemName: "wifi.slash")
                            }
                        }
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .cornerRadius(18)
                    }
                }

                Text(option.name)
                    .font(
                        Font.custom("Prompt", size: 16).weight(.medium)
                    )
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.01, green: 0.03, blue: 0.11).opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Text(option.description)
                .font(
                    Font.custom("Prompt", size: 16).weight(.medium)
                )
                .multilineTextAlignment(.trailing)
                .foregroundColor(colorScheme == .dark ? .white: Color(red: 0.4, green: 0.52, blue: 0.83))
                .frame(alignment: .trailing)
        }
        .padding(.leading, 12)
        .padding(.trailing, 24)
        .padding(.vertical, 10)
        .background(colorScheme == .dark ? (selected ? .white.opacity(0.2) : .white.opacity(0.1)) : (selected ? .white : Color(red: 0.93, green: 0.95, blue: 1)))
        .cornerRadius(40)
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke((colorScheme == .dark ? Color(red: 0.65, green: 0.75, blue: 1).opacity(selected ? 1 : 0) : Color(red: 0.4, green: 0.52, blue: 0.83).opacity(selected ? 0.6 : 0)), lineWidth: 2)
        )
    }
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigView(options: [.init(id: 0, name: "Mythical god", description: "Rogue", imageUrl: URL(string: "https://storage.googleapis.com/assistly/static/realchar/loki.png")!),
                             .init(id: 1, name: "Anime hero", description: "Noble", imageUrl: URL(string: "https://storage.googleapis.com/assistly/static/realchar/raiden.png")!),
                             .init(id: 2, name: "Realtime AI", description: "Kind", imageUrl: URL(string: "https://storage.googleapis.com/assistly/static/realchar/ai_helper.png")!)],
                   hapticFeedback: false,
                   loaded: .constant(true),
                   selectedOption: .constant(nil),
                   openMic: .constant(false),
                   onConfirmConfig: { _ in })
        .frame(width: 310)
    }
}
