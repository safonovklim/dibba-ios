//
//  ContentView.swift
//  ios
//
//  Created by Klim on 10/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CoordinatorHostView()
            .ignoresSafeArea() // let UIKit handle safe areas to avoid double padding on bars
    }
}

#Preview {
    ContentView()
}
