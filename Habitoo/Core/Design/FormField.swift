//
//  FormField.swift
//  Habitoo
//
//  Created by Pedro Juan Ferreira Saraiva on 05/09/25.
//

import SwiftUI

struct FormField: View {
    enum Kind { case text, secure, email }
    let title: String
    @Binding var text: String
    var kind: Kind = .text
    var autocapitalization: TextInputAutocapitalization = .never

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Group {
                switch kind {
                case .text:
                    TextField(title, text: $text)
                case .secure:
                    SecureField(title, text: $text)
                case .email:
                    TextField(title, text: $text)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                }
            }
            .textInputAutocapitalization(autocapitalization)
            .textFieldStyle(.roundedBorder)
        }
    }
}
