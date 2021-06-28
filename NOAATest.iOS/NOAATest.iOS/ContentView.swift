//
//  ContentView.swift
//  NOAATest.iOS
//
//  Created by Kraig Spear on 6/21/21.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var viewModel = ContentViewModel()

    var body: some View {
        VStack {
            Text(viewModel.temperature)
                .padding()
        }.onAppear {
            async {
                await viewModel.reload()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
