#import <UIKit/UIKit.h>


@interface UIView (RecursiveFind)
- (UIView *)findFirstSubviewWithClass:(Class)theClass;
- (void)removeAllSubviews;
@end

