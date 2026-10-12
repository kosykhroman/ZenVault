ZenVault

A lightweight, native macOS utility to instantly clean and organize your desktop.
Built with pure Swift. Weighs less than 5MB, uses near-zero RAM in idle. No Electron bloat, no subscriptions, no tracking.
Features

Instant Cleanup: Hide all desktop files instantly with Cmd + Shift + Z.
Smart Categorization: Files are automatically sorted into folders (Images, Documents, Archives, etc.).
Hidden Storage: Files are safely stored in a hidden .ZenVault folder in your home directory.
Flexible Restore: Bring files back organized in folders or scattered on the desktop.
Native Menu Bar: Beautiful icon that adapts to Light and Dark mode.
Launch at Login: Starts automatically with your Mac.
Privacy First: 100% local processing. No cloud, no accounts, no data collection.
Installation

Go to the Releases section of this repository.
Download the latest ZenVault.dmg file.
Open the .dmg and drag ZenVault.app to your Applications folder.
Open the app.
Important macOS Security Note: Since this is an indie app, macOS might warn you that it is from an unidentified developer. To bypass this, Right-click (or Ctrl+Click) on ZenVault.app in your Applications folder and select Open. Confirm the prompt. You only need to do this once.
Upon first launch, the app will ask for Accessibility permissions. This is strictly required for the global keyboard shortcut to work. Please grant access in System Settings.
Usage

Clean Desktop: Press Cmd + Shift + Z or select "Clean / Restore" from the menu bar.
Restore Files: Press the same shortcut again to bring your files back.
Open Vault: Click the menu bar icon and select "Open Vault".
Auto-start: Toggle "Launch at Login" in the menu bar settings.
Support the Project

ZenVault is completely free and open-source. If this utility saves you time and you want to support independent development, you can buy me a coffee:

USDT (TRC-20): TUrAM8pNtdajqJ8ECXYCP8cxfteRPBN15q

Bitcoin (BTC): bc1q70hljsrpz75am9tl6j4lmyp76d0jrcfwy5lcsz

Every contribution helps to improve the app and add new features!
Build from Source

If you prefer to compile the app yourself:

bash
1. git clone https://github.com/kosykhroman/ZenVault.git
2. cd ZenVault
3. chmod +x build_app.sh
4. ./build_app.sh
 
The compiled ZenVault.app will be generated in the folder.
License

This project is licensed under the MIT License.
Made with ❤️ by Roman Kosykh.
