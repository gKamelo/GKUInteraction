//
//  GKUSignal.m
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

#import "GKUSignal.h"

@interface GKUSlot : NSObject

@property (weak, nonatomic, readonly) id target;
@property (assign, nonatomic, readonly) SEL action;

+ (instancetype)slotWithTarget:(id)target action:(SEL)action;

@end

@implementation GKUSlot

+ (instancetype)slotWithTarget:(id)target action:(SEL)action
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

@interface GKUSignal ()

@property (nonatomic, readonly) NSMutableArray *slots;

@end

@implementation GKUSignal

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _slots = [NSMutableArray array];
    }
    return self;
}

- (void)addSlotForTarget:(id)target action:(SEL)action
{
    GKUSlot *slot = [GKUSlot slotWithTarget:target action:action];

    [self.slots addObject:slot];
}

- (void)removeSlotForTarget:(id)target
{
    NSUInteger index = [self.slots indexOfObjectPassingTest:^BOOL(GKUSlot *slot, NSUInteger idx, BOOL *stop) {

        if (slot.target == target)
        {
            *stop = YES;
            return YES;
        }

        return NO;
    }];

    if (index != NSNotFound)
    {
        [self.slots removeObjectAtIndex:index];
    }
}

- (void)removeSlots
{
    [self.slots removeAllObjects];
}

- (void)emit:(id)argument
{
    void (*invocation)(id, SEL, id);
    IMP implementation;
    NSArray *slots = [self.slots copy];

    for (GKUSlot *slot in slots)
    {
        implementation = [slot.target methodForSelector:slot.action];
        invocation = (void *)implementation;
        invocation(slot.target, slot.action, argument);
    }
}

@end
