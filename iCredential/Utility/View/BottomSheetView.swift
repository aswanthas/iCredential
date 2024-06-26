//
//  BottomSheetView.swift
//  iCridentialsSaver
//
//  Created by Aswanth K on 15/06/24.
//

import SwiftUI
import Combine

enum DragState {
    case inactive
    case dragging(translation: CGSize)

    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }

    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}

struct BottomSheetView<Content: View>: View {
    @GestureState private var dragState = DragState.inactive
    @State private var isKeyboardPresented = false
    @State private var keyboardHeight: CGFloat = 0 // Track keyboard height
    @Binding var isShown: Bool
    var modalHeight: CGFloat = 400
    var cornerRadius: CGFloat = 0
    var isEnableTapBackLayer: Bool = true
    var isEnableDrag: Bool = true
    var content: () -> Content

    private func onDragEnded(drag: DragGesture.Value) {
        let dragThreshold = modalHeight * (2/3)
        if drag.predictedEndTranslation.height > dragThreshold ||
            drag.translation.height > dragThreshold {
            isShown = false
        }
    }

    var body: some View {
        let drag = DragGesture()
            .updating($dragState) { drag, state, transaction in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)
        
        return Group {
            ZStack {
                // Background
                GeometryReader { gr in
                    Spacer()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: gr.size.width, height: gr.size.height)
                        .background(isShown ?
                                    Color.black.opacity(
                                        0.5 * fraction_progress(lowerLimit: 0,
                                                                upperLimit: Double(modalHeight),
                                                                current: Double(dragState.translation.height),
                                                                inverted: true)) : Color.clear)
                        .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
                        .gesture(
                            TapGesture()
                                .onEnded { _ in
                                    if isKeyboardPresented {
                                        hideKeyboard()
                                    } else {
                                        if isEnableTapBackLayer {
                                            self.isShown = false
                                        }
                                    }
                                }
                        )
                }

                // Foreground
                VStack {
                    Spacer()
                    ZStack {
                        Color.white.opacity(1.0)
                            .frame(width: UIScreen.main.bounds.size.width, height: modalHeight)
                            .cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
                            .shadow(radius: 5)
                        self.content()
                            .padding(.bottom, 16)
                            .frame(width: UIScreen.main.bounds.size.width, height: modalHeight)
                            .clipped()
                    }
                    .offset(y: isShown ? (
                        // Combine drag and keyboard offsets
                        dragState.isDragging && dragState.translation.height >= 1
                        ? dragState.translation.height - keyboardHeight
                        : -keyboardHeight
                    ) : modalHeight)
                    .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
                    .if(isEnableDrag, transform: { view in
                        view
                            .gesture(drag)
                    })
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onReceive(keyboardPublisher) { isVisible in
                if isVisible {
                    // Update keyboard height using notification data
                    self.keyboardHeight = getKeyboardHeight()
                } else {
                    self.keyboardHeight = 0
                }
                self.isKeyboardPresented = isVisible
            }
            .onAppear {
                // Add observers to track keyboard height changes
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        self.keyboardHeight = keyboardFrame.height
                    }
                }

                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    self.keyboardHeight = 0
                }
            }
            .onDisappear {
                // Remove observers when the view disappears
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            }
            .onChange(of: isShown) { newValue in
                if !newValue {
                    // Hide the keyboard when isShown becomes false
                    hideKeyboard()
                }
            }
        }
    }

    // Helper function to get keyboard height
    private func getKeyboardHeight() -> CGFloat {
        // This method calculates the keyboard height from the keyboard notification
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.bottom ?? 0
    }
}

// Helper Functions and Extensions

func fraction_progress(lowerLimit: Double = 0, upperLimit: Double, current: Double,
                       inverted: Bool = false) -> Double {
    var val: Double = 0
    if current >= upperLimit {
        val = 1
    } else if current <= lowerLimit {
        val = 0
    } else {
        val = (current - lowerLimit) / (upperLimit - lowerLimit)
    }
    return inverted ? (1 - val) : val
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorners(radius: radius, corners: corners))
    }
}

struct RoundedCorners: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}

extension View {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers
            .Merge(
                NotificationCenter.default
                    .publisher(for: UIResponder.keyboardWillShowNotification)
                    .map { _ in true },
                NotificationCenter.default
                    .publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in false })
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

