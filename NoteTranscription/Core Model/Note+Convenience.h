//
//  Note+Convenience.h
//  NoteTranscription
//
//  Created by Josh Kocsis on 10/25/20.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Note+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface Note (Convenience)

- (instancetype)initWithTitle:(NSString *)title bodyText:(NSString *)bodyText timestamp:(NSDate *)timestamp img:(NSData *)img;

@end

NS_ASSUME_NONNULL_END
