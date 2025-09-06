//
//  RegisterView.swift
//  Habitoo
//
//  Created by Pedro Juan Ferreira Saraiva on 31/08/25.
//

import SwiftUI

struct RegisterView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var resultText = ""
    @State private var showingAlert = false

    var onTapLogin: () -> Void = {}

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        password.count >= 6
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Criar conta")
                .font(.largeTitle).bold()

            CardContainer {
                FormField(title: "Nome", text: $name, kind: .text, autocapitalization: .words)
                FormField(title: "E-mail", text: $email, kind: .email)
                FormField(title: "Senha", text: $password, kind: .secure)

                PrimaryButton(title: "Cadastrar", enabled: isFormValid) {
                    Task { await register() }
                }
            }
            .padding(.top, 8)

            HStack(spacing: 6) {
                Text("Já possui uma conta?")
                    .foregroundStyle(.secondary)
                Button("Entrar") { onTapLogin() }
                    .fontWeight(.semibold)
            }

            Spacer(minLength: 0)
        }
        .padding(.top, 24)
        .alert("Registro", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(resultText)
        }
    }

    func register() async {
        guard let url = URL(string: "http://127.0.0.1:8080/auth/register") else { return }
        let body: [String: Any] = ["name": name, "email": email, "password": password]
        do {
            let data = try JSONSerialization.data(withJSONObject: body)
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = data

            let (respData, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else { return }

            if http.statusCode == 201,
               let json = try? JSONSerialization.jsonObject(with: respData) as? [String: Any],
               let emailResp = json["email"] as? String {
                resultText = "Usuário registrado com sucesso: \(emailResp)"
            } else if http.statusCode == 409 {
                resultText = "E-mail já em uso"
            } else {
                resultText = "Falha no registro (\(http.statusCode))"
            }
        } catch {
            resultText = "Erro: \(error.localizedDescription)"
        }
        showingAlert = true
    }
}

#Preview { RegisterView() }
