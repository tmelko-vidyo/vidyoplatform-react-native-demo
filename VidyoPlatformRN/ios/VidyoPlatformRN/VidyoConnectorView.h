//
//  VidyoConnectorView.h
//  VidyoReactNative
//
//  Created by serhii benedyshyn on 4/21/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#ifndef VidyoConnectorView_h
#define VidyoConnectorView_h

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Lmi/VidyoClient/VidyoConnector_Objc.h"
#import <React/RCTComponent.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTUtils.h>

@class RCTEventDispatcher;

@interface VidyoConnectorView : UIView<VCConnectorIConnect, VCConnectorIRegisterParticipantEventListener, VCConnectorIRegisterLocalCameraEventListener, VCConnectorIRegisterRecorderInCallEventListener, VCConnectorIRegisterMessageEventListener>

@property (nonatomic, strong) VCConnector          *connector;

@property (nonatomic, assign) VCConnectorViewStyle viewStyle;
@property (nonatomic, assign) int                  remoteParticipants;
@property (nonatomic, assign) NSString*            logFileFilter;
@property (nonatomic, assign) NSString*            logFileName;
@property (nonatomic, assign) int                  userData;
@property (nonatomic, assign) int                  videoWidth;
@property (nonatomic, assign) int                  videoHeight;

@property (nonatomic, copy) RCTBubblingEventBlock onInitialized;
@property (nonatomic, copy) RCTBubblingEventBlock onConnected;
@property (nonatomic, copy) RCTBubblingEventBlock onDisconnected;
@property (nonatomic, copy) RCTBubblingEventBlock onParticipantJoined;
@property (nonatomic, copy) RCTBubblingEventBlock onParticipantLeft;
@property (nonatomic, copy) RCTBubblingEventBlock onParticipantsChanged;
@property (nonatomic, copy) RCTBubblingEventBlock onLoudestParticipantChanged;
@property (nonatomic, copy) RCTBubblingEventBlock onRecordingStarted;
@property (nonatomic, copy) RCTBubblingEventBlock onRecordingStopped;

@property (nonatomic, copy) RCTBubblingEventBlock onAvailableResourcesChanged;
@property (nonatomic, copy) RCTBubblingEventBlock onMaxRemoteSourcesChanged;

@property (nonatomic, copy) RCTBubblingEventBlock onRecordingStart;
@property (nonatomic, copy) RCTBubblingEventBlock onRecordingStop;

- (instancetype)initWithBridge:(RCTBridge *)bridge NS_DESIGNATED_INITIALIZER;

- (void)showView;
- (void)setViewStyle:(VCConnectorViewStyle)viewStyle;
- (void)setVideoWidth:(int)videoWidth;
- (void)setVideoHeight:(int)videoHeight;
- (void)setRemoteParticipants:(int)remoteParticipants;
- (void)setLogFileFilter:(NSString *)logFileFilter;
- (void)setLogFileName:(NSString *)logFileName;
- (void)setUserData:(int)userData;

- (void)setCameraPrivacy:(BOOL)cameraPrivacy;
- (void)setMicrophonePrivacy:(BOOL)microphonePrivacy;
- (void)setSpeakerPrivacy:(BOOL)speakerPrivacy;
- (void)setMode:(VCConnectorMode)mode;
- (void)cycleCamera;

- (void)connectToRoomAsGuest:(NSString *)portal
                     RoomKey:(NSString *)roomKey
                     RoomPin:(NSString *)roomPin
                 DisplayName:(NSString *)displayName;
- (void)disconnect;

- (void)onSuccess;
- (void)onFailure:(VCConnectorFailReason)reason;
- (void)onDisconnected:(VCConnectorDisconnectReason)reason;

- (void)onParticipantJoined:(VCParticipant*)participant;
- (void)onParticipantLeft:(VCParticipant*)participant;
- (void)onDynamicParticipantChanged:(NSMutableArray*)participants;
- (void)onLoudestParticipantChanged:(VCParticipant*)participant AudioOnly:(BOOL)audioOnly;

- (void)onLoudestParticipantChanged:(unsigned int)cpuEncode CpuDecode:(unsigned int)cpuDecode BandwidthSend:(unsigned int)bandwidthSend BandwidthReceive:(unsigned int)bandwidthReceive;
-(void) onMaxRemoteSourcesChanged:(unsigned int)maxRemoteSources;

@end

#endif /* VidyoConnectorView_h */
