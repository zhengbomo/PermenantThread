//
//  PermenantThread2.swift
//  ThreadTest
//
//  Created by bomo on 2020/6/17.
//  Copyright © 2020 bomo. All rights reserved.
//

import Foundation


// 保活线程（基于CFRunloop）
class PermenantThread: NSObject {
    private class BlockWrapper: NSObject {
        var block: ()->Void
        init(block: @escaping ()->Void) {
            self.block = block
        }
    }
    
    private var thread: Thread? = Thread {
        // 1. 创建上下文
        var context = CFRunLoopSourceContext()
        // 2. 创建source
        let source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context)
        // 3. 添加source到runloop
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .defaultMode)
        // 4. 执行完source后不返回（只有CFRunLoopStop的时候返回）
        CFRunLoopRunInMode(CFRunLoopMode.defaultMode, CFTimeInterval.greatestFiniteMagnitude, false)
    }
    
    private var isStarted = false
    
    func run() {
        if self.isStarted {
            return
        }
        
        self.thread?.start()
        self.isStarted = true
    }
    
    func stop() {
        if let thread = self.thread {
            self.perform(#selector(innerStop), on: thread, with: nil, waitUntilDone: true)
        }
        self.thread = nil
    }
    
    func execute(_ task: @escaping ()->Void) {
        if let thread = self.thread {
            let inner = BlockWrapper(block: task)
            self.perform(#selector(innerExecute(_:)), on: thread, with: inner, waitUntilDone: false)
        }
    }
    
    @objc private func innerStop() {
        // 在线程内部关闭runloop
        CFRunLoopStop(CFRunLoopGetCurrent())
        
    }
    
    @objc private func innerExecute(_ inner: BlockWrapper) {
        inner.block()
    }

    deinit {
        self.stop()
    }
}
