//
//  DetailViewVM.swift
//  ElitechToolDemo
//
//  Created by wuwu on 2025/9/18.
//

import Foundation
import Combine
import libxlsxwriter
import ElitechToolSDK

class HomeVM: NSObject,ObservableObject {
    
    var cancellables = Set<AnyCancellable>()
    
    // homeView
    @Published var bleAvailable = false//蓝牙是否可用
    @Published var isScanning: Bool = false//是否在扫描中
    @Published var isLoading: Bool = false
    @Published var bleIsConnect = false//是否已连接目标设备
    @Published var vgwList: [ETBleScanData] = []//发现的设备列表
    
    
    //detailView
    
    @Published var rt_vacuum: String = "--" //实时数据
    @Published var rt_vacuumUnit: String = "" //实时数据
    @Published var rt_th2o: String = "--" //实时数据
    @Published var rt_tamb: String = "--" //实时数据
    @Published var rt_tempUnit: String = "" //实时数据
    @Published var rt_recordinterval: String = "" //实时数据
    @Published var rt_power: String = "" //实时数据
    
    @Published var startDone = false //开始操作成功
    @Published var endEnable = false //结束是否可操作
    @Published var readDataEnabled = false //读取数据是否可操作
    @Published var recordList: [[String:String]] = [] //读取数据是否可操作
    @Published var canToReport = false //能否跳转报告
    @Published var updateState = 0 // 0:未检查更新 1：无需更新 2：可更新
    @Published var updateVersion: String = "" //ota版本
    @Published var updateVersionDesc: String = "" //ota描述
    
    //报告url
    var reportURL: URL?
    
    
    //选中的设备
    var vgwmini : CBPeripheral?
    var device: ElitechToolDevice?
    
    
    override init() {
        super.init()
        ElitechManager.shared().addDelegate(self);
    }
    
    func resetStatusForDetailPage() {
        startDone = false
        endEnable = false
        readDataEnabled = false
        canToReport = false
        
        updateState = 0
        updateVersion = ""
        updateVersionDesc = ""
        
    }
    
    func startScan() {
        ElitechManager.shared().startScan()
        isScanning = true;
        
    }
    
    func genReport(records:[[String:String]]) -> URL? {
        
        guard let documentsURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }
        
        let fileURL = documentsURL.appendingPathComponent("hello_vgw.xlsx")
        let filePath = fileURL.path as NSString
        
        
        let workbook = workbook_new(filePath.fileSystemRepresentation)
        let workSheet = workbook_add_worksheet(workbook, nil)
        
        
        worksheet_set_column(workSheet, 0, 4, 40, nil);
        
        worksheet_write_string(workSheet, 0, 0, "时间", nil)
        worksheet_write_string(workSheet, 0, 1, "真空值", nil)
        worksheet_write_string(workSheet, 0, 2, "环境温度", nil)
        worksheet_write_string(workSheet, 0, 3, "水饱和温度", nil)
        
        for i in 0..<records.count {
            let item = records[i]
            if let time = item["timestamp"] {
                worksheet_write_string(workSheet, lxw_row_t(i + 1), 0, time, nil)
            }
            
            if let vacuum = item["vacuum"] {
                worksheet_write_string(workSheet, lxw_row_t(i + 1), 1, vacuum + "micron", nil)
            }
            
            if let Tamb = item["Tamb"] {
                worksheet_write_string(workSheet, lxw_row_t(i + 1), 2, Tamb + "℃", nil)
            }
            
            if let TH2O = item["TH2O"] {
                worksheet_write_string(workSheet, lxw_row_t(i + 1), 3, TH2O + "℃", nil)
            }
            
            
            
        }
        
        workbook_close(workbook)
        reportURL = fileURL
        return fileURL
    }
    
    func initDevice(peripheral: CBPeripheral) {
        device = ElitechToolDevice(peripheral: peripheral, withRecordInterval: 5)
        device?.receiveRtData(withInterval: 1, rtData: {[weak self] rtobj in
            //接收实时数据，更新界面
            self?.rt_vacuum = rtobj.vaccum
            self?.rt_tamb = rtobj.tamb
            self?.rt_th2o = rtobj.th2o
            self?.rt_vacuumUnit = rtobj.vacUnit
            self?.rt_tempUnit = rtobj.temUnit
            self?.rt_recordinterval = "\(rtobj.recordInterval)"
            self?.rt_power = "\(rtobj.power)%"
        })
    }
    
    
    func checkAction() {
//        device?.getVersion({ swv, code in
//            print(swv,code)
//        })
        device?.check(forUpdate: {[weak self] canUpdate, version, description in
            DispatchQueue.main.async {
                self?.updateState = canUpdate ? 2 : 1;
                self?.updateVersion = version
                self?.updateVersionDesc = description
            }
            
        })
        
    }
    
    
}

extension HomeVM: ElitechManagerDelegate
{
    func elitechManagerDidUpdateState(_ manager: ElitechManager) {
        switch manager.state {
        case .poweredOn:
            bleAvailable = true
        default:
            print("请检查蓝牙状态")
            bleAvailable = false
        }
    }
    
    func elitechManager(_ manager: ElitechManager, didDiscoverPeripheral device: ETBleScanData) {
        print("-===",device)
        if !vgwList.contains(device) {
            vgwList.append(device)
        }
    }
    
    func elitechManager(_ manager: ElitechManager, didConnect peripheral: CBPeripheral, result isSuccess: Bool) {
        
        if isSuccess {
            vgwmini = peripheral
            initDevice(peripheral: peripheral)
            isLoading = false
            bleIsConnect = true;
        }
    }
    
    func elitechManager(_ manager: ElitechManager, didDisconnect peripheral: CBPeripheral, error: any Error) {
        resetStatusForDetailPage()
    }
    
    func elitechManager(_ manager: ElitechManager, didReceive data: Data, from peripheral: CBPeripheral) {
        device?.swallowData(data, from: peripheral)
    }
    
    
}


