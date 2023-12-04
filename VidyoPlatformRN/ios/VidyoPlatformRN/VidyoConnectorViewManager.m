//
//  VidyoConnectorViewManager.m
//  VidyoReactNative
//
//  Created by serhii benedyshyn on 4/21/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VidyoConnectorView.h"
#import "VidyoConnectorViewManager.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <React/RCTBridge.h>
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>

@implementation VidyoConnectorViewManager : RCTViewManager

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(VidyoModule)

RCT_CUSTOM_VIEW_PROPERTY(viewStyle, NSString*, VidyoConnectorView) {
  [view setViewStyle:[[RCTConvert NSString:json] isEqual: @"ViewStyleTiles"] ? VCConnectorViewStyleTiles : VCConnectorViewStyleDefault];
}
RCT_CUSTOM_VIEW_PROPERTY(remoteParticipants, NSString*, VidyoConnectorView) {
  [view setRemoteParticipants:[RCTConvert int:json]];
}
RCT_CUSTOM_VIEW_PROPERTY(logFileFilter, NSString*, VidyoConnectorView) {
  [view setLogFileFilter:[RCTConvert NSString:json]];
}
RCT_CUSTOM_VIEW_PROPERTY(logFileName, NSString*, VidyoConnectorView) {
  [view setLogFileName:[RCTConvert NSString:json]];
}
RCT_CUSTOM_VIEW_PROPERTY(userData, NSString*, VidyoConnectorView) {
  [view setUserData:[RCTConvert int:json]];
}
RCT_CUSTOM_VIEW_PROPERTY(cameraPrivacy, NSString*, VidyoConnectorView) {
  [view setCameraPrivacy:[RCTConvert BOOL:json]];
}
RCT_CUSTOM_VIEW_PROPERTY(microphonePrivacy, NSString*, VidyoConnectorView) {
  [view setMicrophonePrivacy:[RCTConvert BOOL:json]];
}
RCT_CUSTOM_VIEW_PROPERTY(mode, NSString*, VidyoConnectorView) {
  // Not implemented [not required]
}
RCT_CUSTOM_VIEW_PROPERTY(videoWidth, NSString*, VidyoConnectorView) {
  [view setVideoWidth:[RCTConvert int:json]];
}
RCT_CUSTOM_VIEW_PROPERTY(videoHeight, NSString*, VidyoConnectorView) {
  [view setVideoHeight:[RCTConvert int:json]];
}

RCT_EXPORT_VIEW_PROPERTY(onInitialized,         RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onConnected,           RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onDisconnected,        RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onParticipantsChanged, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onRecordingStarted,    RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onRecordingStopped,    RCTBubblingEventBlock)

RCT_EXPORT_VIEW_PROPERTY(onAvailableResourcesChanged, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onMaxRemoteSourcesChanged,   RCTBubblingEventBlock)

RCT_EXPORT_METHOD(initialize:(nonnull NSNumber*)reactTag
                  ViewId:(nonnull NSNumber*) viewId)
{
  [self.bridge.uiManager addUIBlock:
   ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry){
    VidyoConnectorView *view = viewRegistry[reactTag];
    if (![view isKindOfClass:[VidyoConnectorView class]]) {
      RCTLogError(@"Invalid view returned from registry, expecting VidyoConnectorView, got: %@", view);
    }
  }];
}

RCT_EXPORT_METHOD(connect:(nonnull NSNumber*)reactTag
                  Portal:(NSString*)portal
                  RoomKey:(NSString*)roomKey
                  DisplayName:(NSString*)displayName)
{
  [self.bridge.uiManager addUIBlock:
   ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry){
    VidyoConnectorView *view = viewRegistry[reactTag];
    if (![view isKindOfClass:[VidyoConnectorView class]]) {
      RCTLogError(@"Invalid view returned from registry, expecting VidyoConnectorView, got: %@", view);
    }
    
    [view connectToRoomAsGuest:portal RoomKey:roomKey RoomPin:@"" DisplayName:displayName];
  }];
}

RCT_EXPORT_METHOD(disconnect:(nonnull NSNumber*)reactTag)
{
  [self.bridge.uiManager addUIBlock:
   ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry){
    VidyoConnectorView *view = viewRegistry[reactTag];
    if (![view isKindOfClass:[VidyoConnectorView class]]) {
      RCTLogError(@"Invalid view returned from registry, expecting VidyoConnectorView, got: %@", view);
    }
    [view disconnect];
  }];
}

RCT_EXPORT_METHOD(cycleCamera:(nonnull NSNumber*)reactTag)
{
  [self.bridge.uiManager addUIBlock:
   ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry){
    VidyoConnectorView *view = viewRegistry[reactTag];
    if (![view isKindOfClass:[VidyoConnectorView class]]) {
      RCTLogError(@"Invalid view returned from registry, expecting VidyoConnectorView, got: %@", view);
    }
    [view cycleCamera];
  }];
}

RCT_EXPORT_METHOD(setCameraPrivacy:(nonnull NSNumber*)reactTag
                  CameraPrivacy:(BOOL)isOn)
{
  [self.bridge.uiManager addUIBlock:
   ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry){
    VidyoConnectorView *view = viewRegistry[reactTag];
    if (![view isKindOfClass:[VidyoConnectorView class]]) {
      RCTLogError(@"Invalid view returned from registry, expecting VidyoConnectorView, got: %@", view);
    }
    [view setCameraPrivacy:isOn];
  }];
}

RCT_EXPORT_METHOD(setMicrophonePrivacy:(nonnull NSNumber*)reactTag
                  MicrophonePrivacy:(BOOL)isOn)
{
  [self.bridge.uiManager addUIBlock:
   ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry){
    VidyoConnectorView *view = viewRegistry[reactTag];
    if (![view isKindOfClass:[VidyoConnectorView class]]) {
      RCTLogError(@"Invalid view returned from registry, expecting VidyoConnectorView, got: %@", view);
    }
    [view setMicrophonePrivacy:isOn];
  }];
}

RCT_EXPORT_METHOD(setSpeakerPrivacy:(nonnull NSNumber*)reactTag
                  SpeakerPrivacy:(BOOL)isOn)
{
  [self.bridge.uiManager addUIBlock:
   ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry){
    VidyoConnectorView *view = viewRegistry[reactTag];
    if (![view isKindOfClass:[VidyoConnectorView class]]) {
      RCTLogError(@"Invalid view returned from registry, expecting VidyoConnectorView, got: %@", view);
    }
    [view setSpeakerPrivacy:isOn];
  }];
}

- (UIView *)view
{
  if (vidyoView == nil) {
    vidyoView = [[VidyoConnectorView alloc] initWithBridge:self.bridge];
  }
  
  return vidyoView;
}

@end
