//
//  LogsViewer.swift
//  AnwalPaySDKNativeiOSExample
//
//  Created by Kiro on 21.01.25.
//

import SwiftUI

struct LogsViewer: View {
    @ObservedObject private var logsManager = LogsManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLog: LogEntry?
    
    var body: some View {
        NavigationView {
            VStack {
                if logsManager.logs.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 64))
                            .foregroundColor(.gray)
                        
                        Text("No logs yet")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("SDK interactions will appear here")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Logs list
                    List(logsManager.logs) { log in
                        LogEntryRow(log: log)
                            .onTapGesture {
                                selectedLog = log
                            }
                    }
                }
            }
            .navigationTitle("SDK Logs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") {
                        LogsManager.shared.clearLogs()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(item: $selectedLog) { log in
            LogDetailsView(log: log)
        }
    }
}

struct LogEntryRow: View {
    let log: LogEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: log.type.icon)
                    .foregroundColor(log.type.color)
                    .font(.system(size: 16))
                
                Text(log.type.displayName)
                    .font(.headline)
                    .foregroundColor(log.type.color)
                
                Spacer()
                
                Text(log.formattedTimestamp)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(log.message.count > 100 ? String(log.message.prefix(100)) + "..." : log.message)
                .font(.body)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

struct LogDetailsView: View {
    let log: LogEntry
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: log.type.icon)
                            .foregroundColor(log.type.color)
                            .font(.system(size: 20))
                        
                        Text(log.type.displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(log.type.color)
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Time: \(log.formattedTimestamp)")
                            .font(.caption)
                            .fontWeight(.bold)
                        
                        Text(log.message)
                            .font(.body)
                            .textSelection(.enabled)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Log Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Copy") {
                        UIPasteboard.general.string = log.message
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    LogsViewer()
}