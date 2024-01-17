## User Message

Display user facing alert type user messages in SwiftUI.

Usage:

Add a view modifier near the root of the view hierarchy:
example in your initial view: 

```
struct SampleApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .showsUserMessages { message in
                            Text(message.string) // from localized resource
                                    .padding()
                                    .background(message.level == .error ? .red : .gray)
                            }
            }
        }
    }
}
```

Now every time a notificaiton of name `.userMessage` (default) is sent the pop will appear. 
Multiple types of alerts can be customized in the ViewBuilder or by applying different modifiers listening to different notfication names.


There is a `showUser()` convenience extension to `String`, `LocalizedStringResource` and `Error`.

``` 
Button("Do Something") {
    do {
      try await doSomething()
      "Did Something".showUser()
    } catch {
      error.showUser()
    }
}

```

