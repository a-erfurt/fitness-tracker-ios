//
//  PlansView.swift
//  FitnessTracker
//
//  Created by Alexander Erfurt on 24.12.25.
//

import SwiftUI

struct PlansView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Plans")
                    .font(.largeTitle).bold()
                Text("Later: list plans, create/duplicate, reorder items, start workout from plan")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Plans")
        }
    }
}
