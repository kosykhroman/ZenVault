import Cocoa
import Carbon
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    let vaultPath = NSHomeDirectory() + "/.ZenVault"
    let desktopPath = NSHomeDirectory() + "/Desktop"
    
    let categories: [String: [String]] = [
        "🖼 Images": ["jpg", "jpeg", "png", "gif", "bmp", "webp", "heic"],
        "📄 PDF": ["pdf"],
        "📝 Word": ["doc", "docx"],
        " Excel": ["xls", "xlsx", "csv"],
        "🎬 Videos": ["mp4", "mov", "mkv", "avi"],
        "🎵 Audio": ["mp3", "wav", "flac", "m4a"],
        "📦 Archives": ["zip", "rar", "7z", "tar", "gz"],
        "💻 Code": ["py", "js", "html", "json", "ts"],
        " Text": ["txt", "md", "rtf"]
    ]
    let ignoreExtensions = ["ds_store", "tmp", "crdownload", "part", "localized"]
    
    var launchAtLoginItem: NSMenuItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        try? FileManager.default.createDirectory(
            atPath: vaultPath,
            withIntermediateDirectories: true
        )
        
        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )
        if let button = statusItem.button {
            let iconPath = Bundle.main.path(forResource: "app_icon", ofType: "png") ?? (NSHomeDirectory() + "/ZenVault/app_icon.png")
            if let image = NSImage(contentsOfFile: iconPath) {
                image.isTemplate = true
                image.size = NSSize(width: 18, height: 18)
                button.image = image
            } else {
                button.title = "✨"
            }
            button.action = #selector(toggleAction)
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(
            title: "🧹 Clean / Restore",
            action: #selector(toggleAction),
            keyEquivalent: ""
        ))
        menu.addItem(NSMenuItem.separator())
        
        launchAtLoginItem = NSMenuItem(
            title: "️ Launch at Login",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        updateLaunchAtLoginState()
        menu.addItem(launchAtLoginItem)
        
        menu.addItem(NSMenuItem(
            title: " Open Vault",
            action: #selector(openVault),
            keyEquivalent: ""
        ))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(
            title: "❌ Quit",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))
        statusItem.menu = menu
        
        checkAccessibilityPermission()
        
        // Регистрируем хоткей ТОЛЬКО если права уже даны.
        // Это предотвращает появление системного диалога с замком.
        if AXIsProcessTrusted() {
            NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
                if event.modifierFlags.contains([.command, .shift]) && event.keyCode == 6 {
                    self?.toggleAction()
                }
            }
        } else {
            print("⚠️ Accessibility not granted. Hotkey disabled until granted.")
        }
    }
    
    @objc func toggleLaunchAtLogin() {
        do {
            if launchAtLoginItem.state == .on {
                try SMAppService.mainApp.unregister()
                launchAtLoginItem.state = .off
            } else {
                try SMAppService.mainApp.register()
                launchAtLoginItem.state = .on
            }
        } catch {
            print("Launch at login error: \(error)")
        }
    }
    
    func updateLaunchAtLoginState() {
        if SMAppService.mainApp.status == .enabled {
            launchAtLoginItem.state = .on
        } else {
            launchAtLoginItem.state = .off
        }
    }
    
    func checkAccessibilityPermission() {
        let defaults = UserDefaults.standard
        let alreadyAskedKey = "alreadyAskedAccessibility"
        
        // Если уже спрашивали — молчим и ничего не делаем
        if defaults.bool(forKey: alreadyAskedKey) {
            return
        }
        
        // Тихая проверка (без системного диалога)
        if !AXIsProcessTrusted() {
            let alert = NSAlert()
            alert.messageText = "Permission Required"
            alert.informativeText = "ZenVault needs Accessibility permission to use keyboard shortcuts.\n\nPlease enable it in:\nSystem Settings → Privacy & Security → Accessibility\n\nThen restart the app."
            alert.addButton(withTitle: "Open Settings")
            alert.addButton(withTitle: "Later")
            
            if alert.runModal() == .alertFirstButtonReturn {
                let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
                NSWorkspace.shared.open(url)
            }
        }
        
        // Запоминаем, что спросили, чтобы больше никогда не спрашивать
        defaults.set(true, forKey: alreadyAskedKey)
    }
    
    @objc func toggleAction() {
        let files = getDesktopFiles()
        if files.isEmpty {
            restoreFiles()
        } else {
            hideFiles(files)
        }
    }
    
    func getDesktopFiles() -> [URL] {
        let fm = FileManager.default
        guard let items = try? fm.contentsOfDirectory(atPath: desktopPath) else {
            return []
        }
        
        return items.compactMap { filename in
            let path = desktopPath + "/" + filename
            let ext = (filename as NSString).pathExtension.lowercased()
            if !ignoreExtensions.contains(ext) && fm.fileExists(atPath: path) {
                return URL(fileURLWithPath: path)
            }
            return nil
        }
    }
    
    func getCategory(for filename: String) -> String {
        let ext = (filename as NSString).pathExtension.lowercased()
        for (category, extensions) in categories {
            if extensions.contains(ext) { return category }
        }
        return "📎 Other"
    }
    
    func hideFiles(_ files: [URL]) {
        let fm = FileManager.default
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let sessionName = "Session_" + formatter.string(from: Date())
        let sessionPath = vaultPath + "/" + sessionName
        
        try? fm.createDirectory(
            atPath: sessionPath,
            withIntermediateDirectories: true
        )
        
        var moved = 0
        for file in files {
            let category = getCategory(for: file.lastPathComponent)
            let categoryPath = sessionPath + "/" + category
            try? fm.createDirectory(
                atPath: categoryPath,
                withIntermediateDirectories: true
            )
            
            let destPath = categoryPath + "/" + file.lastPathComponent
            do {
                try fm.moveItem(at: file, to: URL(fileURLWithPath: destPath))
                moved += 1
            } catch {
                print("Error: \(error)")
            }
        }
        let msg = "\(moved) files hidden"
        showNotification(title: "ZenVault", message: msg, subtitle: "✨ Desk cleaned!")
    }
    
    func restoreFiles() {
        let fm = FileManager.default
        guard let sessions = try? fm.contentsOfDirectory(atPath: vaultPath) else {
            showNotification(
                title: "ZenVault",
                message: "Vault is empty",
                subtitle: "📭 Nothing to restore"
            )
            return
        }
        
        let sortedSessions = sessions.sorted().reversed()
        guard let latestSession = sortedSessions.first else { return }
        let sessionPath = vaultPath + "/" + latestSession
        
        let alert = NSAlert()
        alert.messageText = "How to restore files?"
        alert.informativeText = "Choose how to return files to Desktop."
        alert.addButton(withTitle: "In Folders")
        alert.addButton(withTitle: "Scattered")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            var restored = 0
            if let cats = try? fm.contentsOfDirectory(atPath: sessionPath) {
                for cat in cats {
                    let catPath = sessionPath + "/" + cat
                    let destCatPath = desktopPath + "/" + cat
                    try? fm.createDirectory(
                        atPath: destCatPath,
                        withIntermediateDirectories: true
                    )
                    if let files = try? fm.contentsOfDirectory(atPath: catPath) {
                        for file in files {
                            let src = catPath + "/" + file
                            let dst = destCatPath + "/" + file
                            try? fm.moveItem(atPath: src, toPath: dst)
                            restored += 1
                        }
                    }
                    try? fm.removeItem(atPath: catPath)
                }
            }
            try? fm.removeItem(atPath: sessionPath)
            let msg = "\(restored) files in folders"
            showNotification(title: "ZenVault", message: msg, subtitle: "📁 Restored!")
            
        } else if response == .alertSecondButtonReturn {
            var restored = 0
            if let cats = try? fm.contentsOfDirectory(atPath: sessionPath) {
                for cat in cats {
                    let catPath = sessionPath + "/" + cat
                    if let files = try? fm.contentsOfDirectory(atPath: catPath) {
                        for file in files {
                            let src = catPath + "/" + file
                            let dst = desktopPath + "/" + file
                            try? fm.moveItem(atPath: src, toPath: dst)
                            restored += 1
                        }
                    }
                    try? fm.removeItem(atPath: catPath)
                }
            }
            try? fm.removeItem(atPath: sessionPath)
            let msg = "\(restored) files returned"
            showNotification(title: "ZenVault", message: msg, subtitle: "🔄 Restored!")
        }
    }
    
    @objc func openVault() {
        NSWorkspace.shared.open(URL(fileURLWithPath: vaultPath))
    }
    
    func showNotification(title: String, message: String, subtitle: String = "") {
        let safeMessage = message.replacingOccurrences(of: "\"", with: "\\\"")
        let script = "display notification \"" + safeMessage + "\""
        let script2 = " with title \"" + title + "\""
        let script3 = " subtitle \"" + subtitle + "\""
        let script4 = " sound name \"Glass\""
        let fullScript = script + script2 + script3 + script4
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", fullScript]
        try? process.run()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()