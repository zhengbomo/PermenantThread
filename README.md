# PermenantThread

基于Runloop，让NSThread保活


```swift

let thread = PermenantThread()

// 运行线程
thread.run()

// 向线程添加任务 
thread.execute {
    print("task ------ \(Thread.current)")
}

// 关闭线程
thread.stop()
```
