//
//  ContentView.swift
//  FoodSnap
//
//  Created by Jad Dibs on 5/4/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationView {
            VStack {
                Text("FoodSnap")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text("Take or select a photo of your ingredients")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                ImagePicker(selectedImage: $selectedImage)
                    .padding()
                
                if selectedImage != nil {
                    Button(action: {
                        // TODO: Process image with Gemini API
                    }) {
                        Text("Analyze Ingredients")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}
