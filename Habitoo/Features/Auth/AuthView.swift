//
//  AuthView.swift
//  Habitoo
//
//  Created by Pedro Juan Ferreira Saraiva on 01/09/25.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var session: AppSession

    var body: some View {
        if session.token != nil {
            HabitsListView()
        } else {
            NavigationStack {
                LoginView()
                    .navigationTitle("Entrar")
            }
        }
    }
}

#Preview {
    AuthView().environmentObject(AppSession())
}
