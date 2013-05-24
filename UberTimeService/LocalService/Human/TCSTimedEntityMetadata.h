#import "_TCSTimedEntityMetadata.h"

@interface TCSTimedEntityMetadata : _TCSTimedEntityMetadata {}

- (void)updateWithColor:(NSInteger)color
               archived:(BOOL)archived
      filteredModifiers:(NSInteger)filteredModifiers
                keyCode:(NSInteger)keyCode
              modifiers:(NSInteger)modifiers
                  order:(NSInteger)order
          entityVersion:(int64_t)entityVersion
               remoteId:(NSString *)remoteId
             updateTime:(NSDate *)updateTime
          markAsUpdated:(BOOL)markAsUpdated;

@end
