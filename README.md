## User Message

Display user facing alerts or notifications in SwiftUI.

Usage:

Add a view modifier near the root of the view hierarchy:
example in your initial view: 

```
struct SampleApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .modifier(ShowUserMessage()) 
            }
        }
    }
}
```

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

Apply multiple modifiers, such as one for info messages one for error


