#import "_TCSTimedEntity.h"

typedef NS_ENUM(NSInteger, TCSTimedEntityColor) {

    TCSTimedEntityColorBlue = 0,
    TCSTimedEntityColorGreen,
    TCSTimedEntityColorYellow,
    TCSTimedEntityColorOrange,
    TCSTimedEntityColorPink,

};

extern TCSTimedEntityColor const kTCSTimedEntityDefaultColor;
extern TCSTimedEntityColor const kTCSTimedEntityMaxColor;

@interface TCSTimedEntity : _TCSTimedEntity {}

@property (nonatomic, readonly, getter = isActive) BOOL active;

- (UIColor *)backgroundColor;
- (UIColor *)backgroundEditColor;
- (UIImage *)dragImage;

+ (UIColor *)backgroundColorForTimerColor:(TCSTimedEntityColor)timerColor;
+ (UIColor *)backgroundEditColorForTimerColor:(TCSTimedEntityColor)timerColor;
+ (UIImage *)dragImageForTimerColor:(TCSTimedEntityColor)timerColor;

- (void)updateWithName:(NSString *)name
                 color:(NSInteger)color
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
