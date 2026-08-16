//
//  BottomSheetView.swift
//  WristMap
//

import SwiftUI

private struct BottomSheetView: ViewModifier {
    let detents: [PresentationDetent]
    @Binding var selectedDetent: PresentationDetent
    
    init(
        detents: [PresentationDetent] = [
            SheetDetent.compact,
            SheetDetent.medium
        ],
        selectedDetent: Binding<PresentationDetent>
    ) {
        self.detents = detents
        self._selectedDetent = selectedDetent
    }
    
    func body(content: Content) -> some View {
        content
            .presentationDetents(
                Set(detents),
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
        detents: [PresentationDetent] = [
            SheetDetent.compact,
            SheetDetent.medium
        ],
        selectedDetent: Binding<PresentationDetent>
    ) -> some View {
        self.modifier(
            BottomSheetView(
                detents: detents,
                selectedDetent: selectedDetent
            )
        )
    }
}
