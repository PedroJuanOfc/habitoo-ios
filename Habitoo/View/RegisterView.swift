//
//  RegisterView.swift
//  Habitoo
//
//  Created by Pedro Juan Ferreira Saraiva on 31/08/25.
//

import SwiftUI

struct RegisterView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        password.count >= 6
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Dados") {
                    TextField("Nome", text: $name)
                        .textContentType(.name)
                        .autocapitalization(.words)

                    TextField("E-mail", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                    SecureField("Senha (mín. 6)", text: $password)
                        .textContentType(.newPassword)
                }

                Section {
                    Button {
                        if isFormValid {
                            alertMessage = "Formulário válido"
                        } else {
                            alertMessage = "Preencha os campos corretamente."
                        }
                        showingAlert = true
                    } label: {
                        Text("Criar conta")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Habitoo — Registrar")
            .alert("Registro", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

#Preview {
    RegisterView()
}
