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
                        Task {
                            await registerUser()
                        }
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

    func registerUser() async {
        guard let url = URL(string: "http://localhost:8080/auth/register") else {
            alertMessage = "URL inválida"
            showingAlert = true
            return
        }

        let body: [String: Any] = [
            "name": name,
            "email": email,
            "password": password
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let emailResp = json["email"] as? String {
                        alertMessage = "Usuário registrado com sucesso: \(emailResp)"
                    } else {
                        alertMessage = "Usuário criado"
                    }
                } else if httpResponse.statusCode == 409 {
                    alertMessage = "E-mail já em uso"
                } else {
                    alertMessage = "Erro \(httpResponse.statusCode)"
                }
            }
        } catch {
            alertMessage = "Falha: \(error.localizedDescription)"
        }

        showingAlert = true
    }
}

#Preview {
    RegisterView()
}
