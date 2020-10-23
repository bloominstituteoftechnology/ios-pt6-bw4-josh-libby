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
@property (nonatomic) NSURL *audioURL;
@property (nonatomic) NSData *img;

- (instancetype)initWithTitle:(NSString *)title bodyText:(NSString *)bodyText timestamp:(NSDate *)timestamp audioURL:(NSURL *)audioURL;

- (instancetype)initWithTitle:(NSString *)title bodyText:(NSString *)bodyText timestamp:(NSDate *)timestamp img:(NSData *)img;

@end

NS_ASSUME_NONNULL_END
