## User Message

Display user-facing messages in SwiftUI.

Usage:

Add the `.showsUserMessages(...)` modifier near the root of your view hierarchy, for example: 

```swift
struct SampleApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .showsUserMessages { message: UserMessage in
                            Text(message.string) // from localized resource or verbatim
                                    .padding()
                                    .background(message.level == .error ? .red : .gray)
                            }
            }
        }
    }
}
```

The modifier will now respond every time a notification named `.userMessage` (default) is sent, by showing the user a pop up of the provided view. 
The messages can be customized in the ViewBuilder (eg. by level) or by applying different modifiers listening to different notfication names.

The convenience extension `showUser()` is available for `String`, `LocalizedStringResource` and `Error`.

```swift 
Button("Do Something") {
    do {
      try await doSomething()
      "Did Something".showUser()
    } catch {
      error.showUser()
    }
}

```

