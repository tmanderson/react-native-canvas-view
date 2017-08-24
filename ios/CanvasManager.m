#import "Animator-Swift.h"
#import <React/RCTViewManager.h>

@interface CanvasManager : RCTViewManager
@end

@implementation CanvasManager

RCT_EXPORT_MODULE()

RCT_EXPORT_VIEW_PROPERTY(active, BOOL)
RCT_EXPORT_VIEW_PROPERTY(strokeColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(strokeWidth, int);
                  
RCT_CUSTOM_VIEW_PROPERTY(paths, NSArray, CanvasView) {
  NSMutableArray *paths = [[RCTConvert NSDictionaryArray:json] mutableCopy];
  if (!paths || ![paths count]) return;
  
  for(int i = 0; i < [paths count]; i++) {
    NSDictionary *path = paths[i];
    UIColor *color = [RCTConvert UIColor:path[@"color"]];
    int width = [RCTConvert int:path[@"width"]];
    NSArray *points = [RCTConvert NSArrayArray:path[@"points"]];
    paths[i] = [[CanvasPath alloc] initWith:color width:width points:points];
  }
  
  [view setPaths:paths];
  [view setNeedsDisplay];
}

- (UIView *)view {
  return [[CanvasView alloc] init];
}

@end
