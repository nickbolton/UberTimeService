#import "_TCSProject.h"

@protocol PBListViewEntity;

@interface TCSProject : _TCSProject <PBListViewEntity> {}

- (NSString *)displayName:(BOOL)groupFirst;

@end
