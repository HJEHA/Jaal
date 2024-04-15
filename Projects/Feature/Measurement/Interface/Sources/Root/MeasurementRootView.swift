//
//  MeasurementView.swift
//  FeatureMeasurementInterface
//
//  Created by 황제하 on 4/1/24.
//

import SwiftUI

import ComposableArchitecture

import DomainActivityInterface
import SharedDesignSystem

public struct MeasurementRootView: View {
  @Bindable private var store: StoreOf<MeasurementRootStore>
  
  public init(store: StoreOf<MeasurementRootStore>) {
    self.store = store
  }
  
  public var body: some View {
    NavigationStack {
      VStack(alignment: .leading) {
        HStack {
          title
          
          Spacer()
          
          startButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        
        selectedMode
          .padding(.leading, 20)
          .padding(.top, 12)
        
        
        HStack {
          modeSelectButton(store, mode: .normal)
          
          modeSelectButton(store, mode: .focus)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        
        Spacer()
      }
      .background(SharedDesignSystemAsset.gray100.swiftUIColor)
    }
    .fullScreenCover(
      item: $store.scope(state: \.measurement, action: \.measurement)) { store in
        NavigationStack {
          MeasurementView(store: store)
        }
      }
  }
}

extension MeasurementRootView {
  private var title: some View {
    Text("측정하기")
      .modifier(GamtanFont(font: .bold, size: 24))
  }
  
  private var selectedMode: some View {
    Text("모드 선택")
      .modifier(GamtanFont(font: .bold, size: 20))
  }
  
  private var startButton: some View {
    Button(action: {
      store.send(.startButtonTapped)
    }, label: {
      RoundedRectangle(cornerRadius: 16)
        .foregroundColor(
          SharedDesignSystemAsset.beige.swiftUIColor
        )
        .frame(width: 120, height: 56)
        .overlay(
          HStack {
            Image(
              uiImage: store.selectedMode == .normal
              ? SharedDesignSystemAsset.play.image
              : SharedDesignSystemAsset.flame.image
            )
            .renderingMode(.template)
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(
              store.selectedMode == .normal
              ? SharedDesignSystemAsset.orange.swiftUIColor
              : SharedDesignSystemAsset.red.swiftUIColor
            )
            
            Text("측정 시작")
              .modifier(GamtanFont(font: .bold, size: 18))
              .foregroundColor(
                store.selectedMode == .normal
                ? SharedDesignSystemAsset.orange.swiftUIColor
                : SharedDesignSystemAsset.red.swiftUIColor
              )
          }
        )
    })
  }
  
  @ViewBuilder
  private func modeSelectButton(
    _ viewStore: StoreOf<MeasurementRootStore>,
    mode: MeasurementMode
  ) -> some View {
    Button(action: {
      viewStore.send(.modeButtonTapped(mode))
    }, label: {
      RoundedRectangle(cornerRadius: 16)
        .foregroundColor(
          viewStore.selectedMode == mode
          ? SharedDesignSystemAsset.blue.swiftUIColor
          : SharedDesignSystemAsset.gray500.swiftUIColor
        )
        .frame(height: 64)
        .overlay(
          Text(mode.title)
            .modifier(GamtanFont(font: .bold, size: 24))
            .foregroundColor(.white)
        )
    })
  }
}
