#import "TCSProject.h"
#import "TCSService.h"

@implementation TCSProject

- (BOOL)isActive {
    TCSProject *activeProject =
    [TCSService sharedInstance].activeTimer.project;
    return [self.objectID isEqual:activeProject.objectID];
}

@end
