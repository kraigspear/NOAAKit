//
//  ContentView.swift
//  NOAATest.iOS
//
//  Created by Kraig Spear on 6/21/21.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject private var viewModel = ContentViewModel()

    var body: some View {
        VStack {
            DataEntryView(label: "Observed On:", data: viewModel.date)
            DataEntryView(label: "Temperature:", data: viewModel.temperature)

        }.onAppear {
            async {
                await viewModel.reload()
            }
        }
    }
}

private struct DataEntryView: View {
    let label: String
    let data: String

    var body: some View {
        HStack {
            Text(label)
            Text(data).padding()
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
