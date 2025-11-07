//
//  ReportView.swift
//  ElitechToolDemo
//
//  Created by wuwu on 2025/9/19.
//

import SwiftUI
import WebKit

struct ReportView: View {
    
    @EnvironmentObject var vm: HomeVM
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("返回")
            }

            WebView(url: vm.reportURL)
        }
    }
}




struct WebView: UIViewRepresentable {
    let url: URL?
    
    func makeUIView(context: Context) -> WKWebView {
        let web = WKWebView()
        
        return web
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let uuu = url {
            let request = URLRequest(url: uuu)
            webView.load(request)
        }
    }
}
