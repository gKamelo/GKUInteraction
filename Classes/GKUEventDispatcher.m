//
//  GKUEventDispatcher.m
//
//  Copyright (c) 2015 Kamil Grzegorzewicz. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "GKUEventDispatcher.h"

@interface GKUListener : NSObject

+ (instancetype)listenerWithTarget:(id)target action:(SEL)action;

@property (weak, nonatomic, readonly) id target;
@property (assign, nonatomic, readonly) SEL action;

@end

@implementation GKUListener

+ (instancetype)listenerWithTarget:(id)target action:(SEL)action
{
    return [[self alloc] initWithTarget:target action:action];
}

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    self = [super init];
    if (self)
    {
        _target = target;
        _action = action;
    }
    return self;
}

@end


@interface GKUEventDispatcher ()

@property (nonatomic, readonly) NSMutableDictionary *listeners;

@end

@implementation GKUEventDispatcher

+ (instancetype)sharedDispatcher
{
    static GKUEventDispatcher *dispatcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatcher = [[self alloc] init];
    });

    return dispatcher;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _listeners = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addListenerForName:(NSString *)name target:(id)target action:(SEL)action
{
    GKUListener *listener = [GKUListener listenerWithTarget:target action:action];
    NSMutableArray *listenerGroup = self.listeners[name];

    if (!listenerGroup)
    {
        listenerGroup = [NSMutableArray array];
        self.listeners[name] = listenerGroup;
    }

    [listenerGroup addObject:listener];
}

- (void)removeListenerForName:(NSString *)name target:(id)target
{
    NSMutableArray *listenerGroup = self.listeners[name];

    NSUInteger listenerIndex = [listenerGroup indexOfObjectPassingTest:^BOOL(GKUListener *listener, NSUInteger idx, BOOL *stop) {

        if (listener.target == target)
        {
            *stop = YES;
            return YES;
        }

        return NO;
    }];

    if (listenerIndex != NSNotFound)
    {
        [listenerGroup removeObjectAtIndex:listenerIndex];
    }
}

- (void)removeListenersForName:(NSString *)name
{
    if (self.listeners[name])
    {
        [self.listeners removeObjectForKey:name];
    }
}

- (void)removeListenersForTarget:(id)target
{
    NSArray *listenersName = [self.listeners allKeys];

    for (NSString *name in listenersName)
    {
        [self removeListenerForName:name target:target];
    }
}

- (void)removeAllListeners
{
    [self.listeners removeAllObjects];
}

- (void)dispatchEvent:(GKUEvent *)event
{
    NSCAssert(event, @"Event not defined");

    NSString *eventName = event.name;
    NSArray *listenerGroup = [self.listeners[eventName] copy];
    void (*invocation)(id, SEL, GKUEvent *);
    IMP implementation;

    for (GKUListener *listener in listenerGroup)
    {
        implementation = [listener.target methodForSelector:listener.action];
        invocation = (void *)implementation;

        invocation(listener.target, listener.action, event);
    }
}

@end