//
//  ContentView.swift
//  ElitechToolDemo
//
//  Created by wuwu on 2025/9/9.
//

import SwiftUI
import CoreBluetooth;
import AlertToast
import ElitechToolSDK

struct HomeListCell: View {
    
    var item : CBPeripheral
    
    
    var body: some View {
        
        VStack {
            Text(item.name ?? "").font(.system(size: 14)).fontWeight(.regular).frame(maxWidth: .infinity,alignment: .leading)
                .padding(EdgeInsets.init(top: 0, leading: 0, bottom: 2, trailing: 0))
            Text(item.identifier.uuidString).font(.system(size: 12)).fontWeight(.regular).frame(maxWidth: .infinity,alignment: .leading)
        }
    }
}


struct HomeView: View {
    
    @StateObject private var vm = HomeVM()
    
    var body: some View {
        
        NavigationView {
            VStack {
                Toggle(isOn: $vm.bleAvailable) {
                    Text("蓝牙状态")
                }.disabled(true).padding(.all,5).border(Color.gray, width: 2)
                
                Button {
                    vm.startScan()
                } label: {
                    Text("开始扫描")
                    if vm.isScanning {
                        ProgressView()
                    }
                }

                List(vm.vgwList, id: \.peripheral.identifier) { item in
                    
                    VStack {
                        HomeListCell(item: item.peripheral).background(Color.green)
                        NavigationLink("",destination: DetailView(),isActive: $vm.bleIsConnect).hidden()
                        
                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .onTapGesture {
                        vm.isLoading = true
                        ElitechManager.shared().connect(item.peripheral)
                    }
                    
                }
                

            }
            .padding(.horizontal,30)
            .background(Color(red: 240/255.0, green: 240/255.0, blue: 240/255.0))
            .navigationTitle("发现设备")
            .navigationBarTitleDisplayMode(.inline)
            .toast(isPresenting: $vm.isLoading, alert: {
                AlertToast(displayMode: .alert, type: .loading,title: "正在连接",style: .style(backgroundColor: Color.secondary))
            })
        }
        .environmentObject(vm)
        .onAppear {
            
            vm.$bleIsConnect.sink { isConnect in
                if !isConnect,let vgwmini = vm.vgwmini {
                    ElitechManager.shared().disconnect(vgwmini)
                }
            }.store(in: &vm.cancellables)
        }
    }
    
}

