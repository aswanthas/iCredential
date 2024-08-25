//
//  CridentialCard.swift
//  iCridentialsSaver
//
//  Created by Aswanth K on 15/06/24.
//

import SwiftUI

struct CridentialCard: View {
    var data: Cridentials
    var body: some View {
        HStack {
            Text(data.accountName ?? "")
                .font(Font.system(size: 20))
                .padding(.trailing, 12)
            SecureField("******", text: Binding<String>(
                get: { "******" },
                set: { _ in }
            ))
            .font(.headline)
            .disabled(true)
            Spacer()
            Image(systemName: "chevron.right")
                .resizable()
                .scaledToFit()
                .foregroundColor(.color2C2C2C)
                .frame(width: 14, height: 16)
        }
        .padding(20)
        .background(Color.cell)
        .cornerRadius(50)
        .overlay(
            RoundedRectangle(cornerRadius: 50)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}
