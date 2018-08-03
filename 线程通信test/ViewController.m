//
//  ViewController.m
//  线程通信test
//
//  Created by 徐超 on 2018/8/3.
//  Copyright © 2018年 sd. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // 主队列
    // [self getMain];
   
    
    // 测试转线程
    //[self testMain];
    
    
    //[self delayTest];
    
    [self runLoopTest];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)getMain{
    // 开启一哥全局队列的子线程
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 1.开始请求数据
        
        // 2.数据请求完毕
        
        // 主线程更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.view.backgroundColor = [UIColor redColor];
            
        });
        
    });
    
}

- (void)testMain{
    
    dispatch_queue_t  custom_queue  = dispatch_queue_create("concurrentqueue", DISPATCH_QUEUE_CONCURRENT);
    
    for (int i = 0 ; i < 10; i++) {
        
        // 异步
        dispatch_async(custom_queue, ^{
            NSLog(@"## 并行队列 %d ", i);
            
            ///  数据更新完毕回到主线程 线程之间的通信
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"我在主线程");
            });
            
        });
    }
}


- (void)delayTest{
    
    // 线程延迟调用 通信
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSLog(@"延迟后进入主线程");
    });
    
}


//  线程通信的方法
- (void)connectTest{
    // 回到主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
    
    
    // 全局队列 一般用这个处理遍历大数据查询操作
    // DISPATCH_QUEUE_PRIORITY_HIGH  全局队列的优先级
    /// 全局并发队列执行处理大量逻辑时使用
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     
     
    });
    
    
    // 在开发中遇到一些数据需要单线程访问的时候，我们可以采取同步线程的做法来保证数据的正常执行
    // 执行一些数据安全操作写入的时候，需要同步操作，后面所有的任务要等待当前线程的执行
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
          // 同步线程操作可以保证数据的安全完整性
        
    });
    
}


- (void)testThread{
    
    //1. 数据请求完毕回调到主线程，更新UI资源信息  waitUntilDone    设置YES ，代表等待当前线程执行完毕
    [self performSelectorOnMainThread:@selector(dothing:) withObject:@[@"1"] waitUntilDone:YES];
    
    
    //2.将当前的逻辑转到后台线程去执行
    [self performSelectorInBackground:@selector(dothing:) withObject:@[@"2"]];
    
   
    
    // 3.自己定义线程，将当前数据转移到指定的线程内去通信操作

    NSThread *thread = [[NSThread alloc]  init];
    
    [thread start];
    
    
    // 当我们需要在特定的线程内去执行某一些数据的时候，我们需要指定某一个线程操作
    
    [self performSelector:@selector(dothing:) onThread:thread withObject:nil waitUntilDone:YES];
    
    
    // 支持自定义线程通信执行相应的操作
    NSThread *threads = [[NSThread alloc] initWithTarget:self selector:@selector(testThreads) object:nil];
    
    [threads start];
    
    // 当我们需要在特定的线程内去执行某一些数据的时候，我们需要指定某一个线程操作

    [self performSelector:@selector(dothing:) onThread:threads withObject:nil waitUntilDone:YES];
    
    
    
}


- (void)runLoopTest{
    
    //有时候需要线程单独跑一个RunLoop 来保证我们的请求对象存在，不至于会被系统释放掉
    
    NSThread *runLoopThread = [[NSThread alloc]  initWithTarget:self selector:@selector(entryThreaPoint) object:nil];
    
    [runLoopThread start];
    
    [self performSelector:@selector(handelData) onThread:runLoopThread withObject:nil waitUntilDone:YES];
    
}


// 给线程增加一个run loop来保持对象的引用
- (void)entryThreaPoint{
    
    [NSThread currentThread].name = @"自定义线程的名字";
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [runLoop run];
    
    NSLog(@"测试runloop");
}


- (void)handelData{
    
    NSLog(@"# 我是跑在runllop的线程 #");
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
