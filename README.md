## User Message

Display localized user-facing messages in SwiftUI.

### 1. _Usage_

Add the `.showsUserMessages(...)` modifier near the root of your view hierarchy, for example: 
```swift
struct SampleApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .showUserMessages()            
        }
    }
}
```

Then call `showUser()` to overlay a pop-up alert.
```swift 
do {
    try await doSomething()
    "Did Something".showUser()
} catch {
    error.showUser()
}
```

Any time a notification named `.userMessage` is received the modifier will display the pop-up alert. 
The `showUser()` extension for `String`, `LocalizedStringResource` and `Error` is just a convenience.

![UserMessage Demo](https://github.com/cenkbilgen/UserMessage/assets/6772018/99ec8877-8ba8-49da-8af8-77554a92980d)

---

### 2. _Modifier Arguments_

The modifier has two forms that take different arguments, one uses a default rectangle shaped message view and one that takes a completely custom view.


1. Default Message View
```swift
func showsUserMessages<Border: ShapeStyle>(
  notificationName: Notification.Name = .userMessage,
  location: VerticalAlignment = .top,
  duration: Duration = .seconds(6),
  allowDuplicateMessages: Bool = true,
  maxDisplayedMessagesCount: Int = 5,
  multipleMessageAlignment: HorizontalAlignment = .center,
  backgroundStyle: some ShapeStyle = Material.regular,
  font: Font = .caption.weight(.medium),
  borderStyles: ([UserMessage.Level: Border], default: Border) = ([.error: .red], default: .gray),
  borderWidth: CGFloat = 2,
  shadowRadius: CGFloat = 4) -> some View {}
)
```

2. Custom Message View   
```swift
func showsUserMessages(
  notificationName: Notification.Name = .userMessage,
  location: VerticalAlignment = .top,
  duration: Duration = .seconds(6),
  allowDuplicateMessages: Bool = true,
  maxDisplayedMessagesCount: Int = 5,
  multipleMessageAlignment: HorizontalAlignment = .center,
  @ViewBuilder messageView: @escaping (UserMessage) -> some View) -> some View = {}
)
```

```swift
MainView()
    .showsUserMessages { message: UserMessage in
        Text(message.string) // from localized resource or verbatim
            .padding()
            .background(message.level == .error ? .red : .gray)
       }
    }
```
