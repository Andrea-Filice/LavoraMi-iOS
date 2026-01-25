//
//  SplashScreenView.swift
//  LavoraMi
//
//  Created by Andrea Filice on 25/01/26.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 1.0
    
    var body: some View {
        if(isActive){
            ContentView()
        }
        
        else{
            VStack{
                VStack{
                    Image("icon")
                        .resizable()
                        .frame(width: 150, height: 150)
                }
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.opacity = 0.0
                    }
                }
            }
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    self.isActive = true
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
