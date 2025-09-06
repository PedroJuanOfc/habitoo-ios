//
//  AuthView.swift
//  Habitoo
//
//  Created by Pedro Juan Ferreira Saraiva on 01/09/25.
//

import SwiftUI

enum AuthScreen {
    case login
    case register
}

struct AuthView: View {
    @EnvironmentObject private var session: AppSession
    @State private var screen: AuthScreen = .login

    var body: some View {
        if session.token != nil {
            HabitsListView()
        } else {
            NavigationStack {
                Group {
                    switch screen {
                    case .login:
                        LoginView(onTapRegister: { screen = .register })
                    case .register:
                        RegisterView(onTapLogin: { screen = .login })
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationTitle(screen == .login ? "Entrar" : "Cadastrar")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    AuthView().environmentObject(AppSession())
}
