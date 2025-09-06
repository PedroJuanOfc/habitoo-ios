//
//  PrimaryButton.swift
//  Habitoo
//
//  Created by Pedro Juan Ferreira Saraiva on 05/09/25.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .disabled(!enabled)
    }
}
