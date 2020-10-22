//
//  BW4Notes.m
//  NoteTranscription
//
//  Created by Josh Kocsis on 10/19/20.
//

#import "BW4Notes.h"

@implementation BW4Notes


- (instancetype)initWithTitle:(NSString *)title bodyText:(NSString *)bodyText timestamp:(NSDate *)timestamp audioURL:(NSURL *)audioURL
{
    if (self = [super init]) {
        _title = title;
        _bodyText = bodyText;
        _timestamp = timestamp;
        _audioURL = audioURL;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title bodyText:(NSString *)bodyText timestamp:(NSDate *)timestamp img:(NSData *)img
{
    if (self = [super init]) {
        _title = title;
        _bodyText = bodyText;
        _timestamp = timestamp;
        _img = img;
    }
    return self;
}

@end
