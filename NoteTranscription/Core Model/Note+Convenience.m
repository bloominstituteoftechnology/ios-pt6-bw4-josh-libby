//
//  Note+Convenience.m
//  NoteTranscription
//
//  Created by Josh Kocsis on 10/25/20.
//

#import "Note+Convenience.h"
#import <CoreData/CoreData.h>
#import "NoteTranscription-Swift.h"

@class BW4CoreDataStack;

@implementation Note (Convenience)

- (instancetype)initWithTitle:(NSString *)title bodyText:(NSString *)bodyText timestamp:(NSDate *)timestamp img:(NSData *)img 
{
    self = [self initWithContext:BW4CoreDataStack.sharedStack.mainContext];
    if (self) {
        self.title = [title copy];
        self.bodyText = [bodyText copy];
        self.timestamp = [timestamp copy];
        self.img = [img copy];
    }
    return self;
}

@end
