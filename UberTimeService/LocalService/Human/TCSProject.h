#import "_TCSProject.h"

@interface TCSProject : _TCSProject {}

- (void)updateWithName:(NSString *)name
                 color:(NSInteger)color
              archived:(BOOL)archived
     filteredModifiers:(NSInteger)filteredModifiers
               keyCode:(NSInteger)keyCode
             modifiers:(NSInteger)modifiers
                 order:(NSInteger)order
         entityVersion:(int64_t)entityVersion
         remoteDeleted:(BOOL)remoteDeleted
              remoteId:(NSString *)remoteId
            updateTime:(NSDate *)updateTime
         markAsUpdated:(BOOL)markAsUpdated;

@end
