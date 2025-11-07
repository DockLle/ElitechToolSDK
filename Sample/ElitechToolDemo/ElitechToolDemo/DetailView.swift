//
//  DetailView.swift
//  ElitechToolDemo
//
//  Created by wuwu on 2025/9/10.
//

import SwiftUI
import CoreBluetooth
import AlertToast

struct DetailView: View {
    
    @EnvironmentObject var vm: HomeVM
    
    @State var isOtaDownloading: Bool = false
    @State private var otaProgress: Double = 0
    @State private var readProgress: Double = 0
    
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 20) {
                
                VStack(spacing: 20) {
                    Text("实时数据").font(.system(size: 20,weight: .medium)).frame(maxWidth: .infinity,alignment: .leading)
                    
                    HStack(alignment: .firstTextBaseline,spacing: 0) {
                        Text(vm.rt_vacuum).font(.system(size: 60)).lineLimit(1)
                        Text(vm.rt_vacuumUnit)
                    }
                    
                    HStack(alignment: .firstTextBaseline,spacing: 0) {
                        Text("环境温度")
                        Text(vm.rt_tamb).font(.system(size: 30)).lineLimit(1)
                        Text(vm.rt_tempUnit)
                    }
                    HStack {
                        Text("水饱和温度")
                        Text(vm.rt_th2o).font(.system(size: 30)).lineLimit(1)
                        Text(vm.rt_tempUnit)
                    }
                    
                    HStack {
                        Text("记录间隔")
                        Text(vm.rt_recordinterval).font(.system(size: 30)).lineLimit(1)
                        Text("s")
                    }
                    HStack {
                        Text("电量")
                        Text(vm.rt_power).font(.system(size: 30)).lineLimit(1)
                        Text("")
                    }
                    
                    Button {
                        let randomNumber = Int.random(in: 0...7)
                        vm.isLoading = true
                        vm.device?.setVacuumUnit(randomNumber, result: { res in
                            vm.isLoading = false
                        })
                        
                    } label: {
                        Text("设置真空单位")
                    }
                    
                    Button {
                        var randomNumber = 0
                        if vm.rt_tempUnit == "℃"
                        {
                            randomNumber = 1
                        }
                        else
                        {
                            randomNumber = 0
                        }
                        vm.isLoading = true
                        vm.device?.setTemperatureUnit(randomNumber, result: { res in
                            vm.isLoading = false
                        })
                    } label: {
                        Text("设置温度单位")
                    }
                    
                    Button {
                        if let randomNumber = Int(vm.rt_recordinterval)
                        {
                            vm.isLoading = true
                            vm.device?.setRecordInterval(randomNumber + 1, result: { res in
                                vm.isLoading = false
                            })
                        }
                        
                    } label: {
                        Text("设置记录间隔")
                    }
                    
                    
                }
                .padding(.all,20)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.pink, lineWidth: 1)
                )
                
                HStack {
                    ProgressView(value: otaProgress, total: 100)
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding()
                    Button {
                        vm.checkAction()
                    } label: {
                        Text("检查更新")
                    }

                }.padding()
                
                VStack(spacing: 20) {
                    Text("抽真空").font(.system(size: 20,weight: .medium)).frame(maxWidth: .infinity,alignment: .leading)
                    HStack {
                        Button {
                            
                            vm.device?.startVacuuming(result: { res in
                                vm.startDone = res
                                if res
                                {
                                    vm.endEnable = true
                                }
                            })
                        } label: {
                            Text("开始抽真空")
                            
                        }.disabled(vm.startDone)
                        
                        if vm.startDone {
                            Image(systemName: "checkmark.seal")
                        }
                    }
                    
                    HStack {
                        Button {
                            vm.device?.endVacuuming(result: { res in
                                if res {
                                    vm.endEnable = false
                                    vm.readDataEnabled = true
                                }
                            })
                        } label: {
                            Text("结束抽真空")
                        }.disabled(!vm.endEnable)
                        
                        if vm.readDataEnabled {
                            Image(systemName: "checkmark.seal")
                        }
                    }
                    
                    
                    HStack {
                        ProgressView(value: readProgress, total: 100)
                                .progressViewStyle(LinearProgressViewStyle())
                                .padding()
                        Button {
                            vm.device?.readRecord(result: { progress, err, records in
                                
                                if err == nil {
                                    print("进度",progress)
                                    readProgress = Double(progress)
                                    if progress == 100,records.count > 0 {
                                        print(records)
                                        vm.recordList = records
                                    }
                                }
                                
                            })
                        } label: {
                            Text("读取抽真空数据")
                        }.disabled(!vm.readDataEnabled)
                        
                        if vm.recordList.count > 0 {
                            Image(systemName: "checkmark.seal")
                        }
                    }
                    
                    Button {
                        vm.isLoading = true
                        if let _ = vm.genReport(records: vm.recordList)
                        {
                            vm.isLoading = false
                            vm.canToReport = true
                        }
                    } label: {
                        Text("生成报告")
                    }.disabled(vm.recordList.count <= 0)
                }
                .padding(.all,20)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.pink, lineWidth: 1)
                )
            }
            .alert(isPresented: Binding(get: {
                vm.updateState > 0
            }, set: { _ in })) {
                
                if vm.updateState == 2
                {
                    Alert(title: Text("去更新"), message: Text(vm.updateVersion + "==" + vm.updateVersionDesc), dismissButton: .default(Text("确定"), action: {
                        vm.updateState = 0;
                        isOtaDownloading = true;
                        vm.device?.updateSoftware({ isDownloaded, updateProgress, err in
                            if err == nil {
                                
                                if isDownloaded {//下载完成
                                    
                                    otaProgress = Double(updateProgress)
                                    if updateProgress >= 100 {
                                        isOtaDownloading = false
                                    }
                                }
                                
                            }
                            else
                            {
                                print(err ?? "更新出错")
                            }
                        })
                    }))
                }
                else
                {
                    Alert(title: Text("无需更新"), message: Text("未发现新版本"), dismissButton: .default(Text("确定"),action: {
                        vm.updateState = 0;
                    }))
                }
                
                
            }
            .toast(isPresenting: $vm.isLoading, alert: {
                AlertToast(displayMode: .alert, type: .loading,title: "",style: .style(backgroundColor: Color.secondary))
            })
            .toast(isPresenting: $isOtaDownloading, alert: {
                AlertToast(displayMode: .alert, type: .loading,title: "",style: .style(backgroundColor: Color.secondary))
            })
            .sheet(isPresented: $vm.canToReport, content: {
                ReportView()
            })
            .onDisappear {
                vm.bleIsConnect = false
            }
            
            
        }
        
    }
}

