//
//  ContentView.swift
//  Assignment
//
//  Created by Kunal on 03/01/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var path: [DeviceData] = [] // Navigation path
    @State var search: String = ""
    
    var filteredDevices : [DeviceData] {
        guard let computers = viewModel.data else {
            return []
        }
        if search.isEmpty {
            return computers
        }
        return computers.filter {
            $0.name.lowercased().contains(search.lowercased())
        }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            HStack{
                Image(systemName: "magnifyingglass")
                TextField( "Search your devices here....", text: $search)
            }
            .padding(6)
            .background(
                // Used Rectangle for having rounded corners on custom searchbar
                Rectangle()
                    .foregroundStyle(.gray.opacity(0.2))
                    .cornerRadius(8)
            )
            .padding(.horizontal,14)
            .padding(.top,8)

            Group {
                
                if let computers = viewModel.data, !computers.isEmpty {
                    DevicesList(devices: filteredDevices) { selectedComputer in
                        viewModel.navigateToDetail(navigateDetail: selectedComputer)
                        print(computers)
                    }
                } else {
                    ProgressView("Loading...")
                }
            }
            .onChange(of: viewModel.navigateDetail, {
                let navigate = viewModel.navigateDetail
                path.append(navigate!)
            })
            .navigationTitle("Devices")
            .navigationDestination(for: DeviceData.self) { computer in
                DetailView(device: computer)
            }
//            .searchable(text: $search, prompt: "Search your devices")
            .onAppear {
                viewModel.fetchAPI()
                
                let navigate = viewModel.navigateDetail
                if (navigate != nil) {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        // Removed additional +0.5 time as it was causing issues in navigating back to ContentView
                        path.append(navigate!)
                    }
                }
            }
        }
    }
}
