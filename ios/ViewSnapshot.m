#import <React/RCTBridgeModule.h>
#import <React/RCTConvert.h>
#import <React/RCTUIManager.h>

@interface ViewSnapshot : NSObject <RCTBridgeModule>
@end

@implementation ViewSnapshot

RCT_EXPORT_MODULE()

@synthesize bridge = _bridge;
- (dispatch_queue_t)methodQueue
{
  return RCTGetUIManagerQueue();
}

RCT_EXPORT_METHOD(getSnapshot:(nonnull NSNumber*)viewId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
  
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
    UIView *view = viewRegistry[viewId];
    
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSData *data = UIImagePNGRepresentation(image);
      NSString *b64String = [NSString stringWithFormat:@"data:image/%@;base64,%@", @"png", [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
      
      resolve(b64String);
    });
  }];
}


@end
