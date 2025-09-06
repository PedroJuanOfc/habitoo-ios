//
//  CardContainer.swift
//  Habitoo
//
//  Created by Pedro Juan Ferreira Saraiva on 05/09/25.
//

import SwiftUI

struct CardContainer<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 16) {
            content
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
        .padding(.horizontal, 20)
    }
}
