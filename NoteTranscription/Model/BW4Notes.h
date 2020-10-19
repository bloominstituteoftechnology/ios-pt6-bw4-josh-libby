//
//  BW4Notes.h
//  NoteTranscription
//
//  Created by Josh Kocsis on 10/19/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Notes)
@interface BW4Notes : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *bodyText;
@property (nonatomic) NSDate *timestamp;

@end

NS_ASSUME_NONNULL_END
