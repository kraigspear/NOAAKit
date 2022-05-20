//
//  ContentView.swift
//  NoaaTest
//
//  Created by Kraig Spear on 7/14/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ContentViewModel

    var body: some View {
        VStack {
            ItemView(title: "Updated:", value: viewModel.updatedOn)
            ItemView(title: "Temperature:", value: viewModel.temperature)
            ItemView(title: "DewPoint", value: viewModel.dewPoint)
            if let feelsLike = viewModel.feelsLike {
                ItemView(title: "Feels Like:", value: feelsLike)
            }
            ItemView(title: "Current Condition:", value: viewModel.textDescription)
            ItemView(title: "Wind:", value: viewModel.wind)
            ItemView(title: "visibility:", value: viewModel.visibility)
            ItemView(title: "RelativeHumidity: ", value: viewModel.relativeHumidity)

            ForEach(viewModel.cloudLayers, id: \.cloudAmount.rawValue) { cloudLayer in
                ItemView(title: "CloudLayer:", value: cloudLayer.cloudAmount.rawValue)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
        }.onAppear {
            Task {
                await viewModel.refresh()
            }
        }
    }
}

struct ItemView: View {

    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Text(value)
        }
    }
}

// struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            .environmentObject(ContentViewModel(noaaFetching: NOAAFetchingPreview()))
//    }
// }
