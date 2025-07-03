//
//  SheetModifier.swift
//  iCredential
//
//  Created by Appcom on 03/07/2025.
//

import SwiftUI

struct ContentHeightSheetModifier: ViewModifier {
    @State private var contentHeight: CGFloat = 0
    private var contentHeightMeasurerView: some View {
        GeometryReader { proxy in
            Color.clear
                .onChange(of: proxy.size.height, initial: true) { oldValue, newHeight in
                    contentHeight = newHeight
                }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .background(contentHeightMeasurerView)
            .presentationDetents([.height(contentHeight)])
    }
}

extension View {
    func adjustSheetContentHeight() -> some View {
        self.modifier(ContentHeightSheetModifier())
    }
}
