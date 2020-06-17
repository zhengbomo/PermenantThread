//
//  PermenantThread.swift
//  ThreadTest
//
//  Created by bomo on 2020/6/17.
//  Copyright © 2020 bomo. All rights reserved.
//

import Foundation


// 保活线程（基于NSRunloop）
class PermenantThread2: NSObject {
    private class BlockWrapper: NSObject {
        var block: ()->Void
        init(block: @escaping ()->Void) {
            self.block = block
        }
    }
    
    private var thread: Thread?
    
    private var isStopped = false
    private var isStarted = false
    
    func run() {
        if self.isStopped {
            return
        }
        if self.isStarted {
            return
        }
           
        let thread = Thread { [weak self] in
            // 添加port监听
            RunLoop.current.add(Port(), forMode: .default)
           
            // self没有被释放，并且线程没有被stop
            while !((self?.isStopped) ?? true) {
                RunLoop.current.run(mode: .default, before: .distantFuture)
            }
        }
        self.thread = thread
        self.isStarted = true
        thread.start()
    }
    
    func stop() {
        if let thread = self.thread, !self.isStopped {
            self.isStopped = true
            self.perform(#selector(innerStop), on: thread, with: nil, waitUntilDone: true)
        }
    }
    
    func execute(_ task: @escaping ()->Void) {
        if let thread = self.thread {
            let inner = BlockWrapper(block: task)
            self.perform(#selector(innerExecute(_:)), on: thread, with: inner, waitUntilDone: false)
        }
    }
    
    @objc private func innerStop() {
        // 在线程内部关闭loop
        CFRunLoopStop(CFRunLoopGetCurrent())
        self.thread = nil
    }
    
    @objc private func innerExecute(_ inner: BlockWrapper) {
        inner.block()
    }

    deinit {
        self.stop()
    }
}
