//
//  BottomSheetView.swift
//  WristMap
//

import SwiftUI

private struct BottomSheetView: ViewModifier {
    @Binding var selectedDetent: PresentationDetent
    
    func body(content: Content) -> some View {
        content
            .presentationDetents(
                [
                    SheetDetent.compact,
                    SheetDetent.medium
                ],
                selection: $selectedDetent
            )
            .presentationBackgroundInteraction(
                .enabled(upThrough: SheetDetent.medium)
            )
            .interactiveDismissDisabled()
    }
}

// reusing BottomSheetView for sheets
extension View {
    func bottomSheetStyle(
        selectedDetent: Binding<PresentationDetent>
    ) -> some View {
        self.modifier(
            BottomSheetView(
                selectedDetent: selectedDetent
            )
        )
    }
}
