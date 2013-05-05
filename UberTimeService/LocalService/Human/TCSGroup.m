#import "TCSGroup.h"
#import "TCSProject.h"

@implementation TCSGroup

- (BOOL)isActive {
    
    for (TCSTimedEntity *ent in self.children) {
        if ([ent isKindOfClass:[TCSProject class]]) {
            if ([(TCSProject *)ent isActive]) return YES;
        } else if ([ent isKindOfClass:[TCSGroup class]] && [(TCSGroup *)ent isActive]) {
            return YES;
        }
    }
    return NO;
}

@end
