//
//  LavoraMiApp.swift
//  LavoraMi
//
//  Created by Andrea Filice on 05/01/26.
//

import SwiftUI

@main
struct LavoraMiApp: App {
    @AppStorage("appearanceSelection") private var appearanceSelection: Int = AppearanceType.system.rawValue
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .preferredColorScheme(currentScheme)
        }
    }
    
    var currentScheme: ColorScheme? {
            switch AppearanceType(rawValue: appearanceSelection) {
            case .light: return .light
            case .dark: return .dark
            default: return nil
        }
    }
}
