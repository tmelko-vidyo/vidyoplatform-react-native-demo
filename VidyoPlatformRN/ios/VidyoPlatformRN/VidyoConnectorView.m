//
//  VidyoConnectorView.m
//  VidyoReactNative
//
//  Created by serhii benedyshyn on 4/21/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VidyoConnectorView.h"
#import "React/UIView+React.h"

static NSString *const CommandMessageRecordingStarted = @"RECORDING_STARTED";
static NSString *const CommandMessageRecordingPaused = @"RECORDING_PAUSED";
static NSString *const CommandMessageRecordingStopped = @"RECORDING_STOPPED";

@interface VidyoConnectorView () {
@private
  VCLocalCamera *lastSelectedCamera;
  BOOL          devicesSelected;
  BOOL          cameraPrivacy;
  BOOL          microphonePrivacy;
  BOOL          speakerPrivacy;
}
@end

@implementation VidyoConnectorView {
  RCTBridge *_bridge;
  RCTEventDispatcher *_eventDispatcher;
  UIView *videoSubview;
}

- (instancetype)initWithBridge:(RCTBridge *)bridge {
  RCTAssertParam(bridge);
  RCTAssertParam(bridge.eventDispatcher);
  
  if ((self = [super initWithFrame:CGRectZero])) {
    _eventDispatcher = bridge.eventDispatcher;
  }
  
  videoSubview = [[UIView alloc] initWithFrame:CGRectZero];
  videoSubview.layer.masksToBounds = YES;
  videoSubview.backgroundColor = [UIColor blueColor];
  [self addSubview:videoSubview];
  
  [VCConnectorPkg vcInitialize];
  [self createVidyoConnector];
  return self;
}

- (void)didMoveToWindow
{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(appWillResignActive:)
                                               name:UIApplicationWillResignActiveNotification
                                             object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(appDidBecomeActive:)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:nil];
  
  [self selectDefaultDevices];
  [self reAssignView];
  [self showView];
  
  self.onInitialized(@{@"status": @"Initialized"});
  
  [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)removeFromSuperview {
  [super removeFromSuperview];
  
  /* Shut down the renderer when we are moving away from view */
  [self hideView];
  [self releaseDevices];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)createVidyoConnector
{
  const char * logLevels = "debug@VidyoClient debug@VidyoConnector fatal error info";
  _connector = [[VCConnector alloc] init:(void *)&videoSubview
                               ViewStyle:VCConnectorViewStyleDefault
                      RemoteParticipants:2
                           LogFileFilter:logLevels
                             LogFileName:[_logFileName  UTF8String]
                                UserData:_userData];
  
  [_connector registerParticipantEventListener:self];
  [_connector registerLocalCameraEventListener:self];
  [_connector registerRecorderInCallEventListener:self];
  [_connector registerMessageEventListener:self];
}

- (void)reactSetFrame:(CGRect)frame {
    [super reactSetFrame: frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for(UIView* view in self.subviews) {
      [view setFrame:CGRectMake(0, 0, self->_videoWidth, self->_videoHeight)];
    }
}

#pragma mark - Application Lifecycle

- (void)appWillResignActive:(NSNotification*)notification {
    if (_connector) {
      if ([_connector getState] == VCConnectorStateConnected) {
        // Connected or connecting to a resource.
        // Enable camera privacy so remote participants do not see a frozen frame.
        [_connector setCameraPrivacy:YES];
      } else {
        // Not connected to a resource.
        // Release camera, mic, and speaker from this app while backgrounded.
        [self releaseDevices];
      }
      
      [_connector setMode:VCConnectorModeBackground];
    }
}

- (void)appDidBecomeActive:(NSNotification*)notification {
    if (_connector) {
        [_connector setMode:VCConnectorModeForeground];

        if (!devicesSelected) {
            // Devices have been released when backgrounding (in appWillResignActive). Re-select them.
            // Select the previously selected local camera and default mic/speaker
            [self selectDefaultDevices];
            [_connector setMicrophonePrivacy:microphonePrivacy];
        }

        // Reestablish camera privacy states
        [_connector setCameraPrivacy: cameraPrivacy];
    }
}

- (void)selectDefaultDevices {
  if (lastSelectedCamera) {
    [_connector selectLocalCamera: lastSelectedCamera];
  } else {
    [_connector selectDefaultCamera];
  }
  
  [_connector selectDefaultMicrophone];
  [_connector selectDefaultSpeaker];
  devicesSelected = YES;
}

- (void)releaseDevices {
  [_connector selectLocalCamera: nil];
  [_connector selectLocalSpeaker: nil];
  [_connector selectLocalMicrophone: nil];
  devicesSelected = NO;
}

- (void)showView {
  dispatch_async(dispatch_get_main_queue(), ^{
    int width  = self->_videoWidth;
    int height = self->_videoHeight;
    [self.connector showViewAt:&self->videoSubview
                             X:0
                             Y:0
                         Width:width
                        Height:height];
    
    const char* options = "{\"SetPipPosition\": {\"x\": \"PipPositionRight\", \"y\": \"PipPositionTop\", \"lockPip\": true}}";
    [self.connector setRendererOptionsForViewId: (void *)&self->videoSubview
                                        Options: options];
    
    [self.connector showViewLabel: (void *)&self->videoSubview
                        ShowLabel: false];
  });
}

 /* Re-attach the renderer to the view */
- (void)reAssignView {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.connector assignViewToCompositeRenderer:(void *)&self->videoSubview
                                        ViewStyle:VCConnectorViewStyleDefault
                               RemoteParticipants:2];
  });
}

 /* Shut down the rendering */
- (void)hideView {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.connector hideView:(void *)&self->videoSubview];
  });
}

- (void)setViewStyle:(VCConnectorViewStyle)viewStyle
{
  _viewStyle = viewStyle;
}

- (void) setVideoWidth:(int)videoWidth
{
  _videoWidth = videoWidth;
}

- (void) setVideoHeight:(int)videoHeight
{
  _videoHeight = videoHeight;
}

- (void)setRemoteParticipants:(int)remoteParticipants
{
  _remoteParticipants = remoteParticipants;
}

- (void)setLogFileFilter:(NSString *)logFileFilter
{
  _logFileFilter = logFileFilter;
}

- (void)setLogFileName:(NSString *)logFileName
{
  _logFileName = logFileName;
}

- (void)setUserData:(int)userData
{
  _userData = userData;
}

- (void)setCameraPrivacy:(BOOL)privacy
{
  cameraPrivacy = privacy;
  [_connector setCameraPrivacy:privacy];
}

- (void)setMicrophonePrivacy:(BOOL)privacy
{
  microphonePrivacy = privacy;
  [_connector setMicrophonePrivacy:privacy];
}

- (void)setSpeakerPrivacy:(BOOL)privacy
{
  speakerPrivacy = privacy;
  [_connector setSpeakerPrivacy:privacy];
}

- (void)cycleCamera
{
  [_connector cycleCamera];
}

- (void)connectToRoomAsGuest:(NSString *)portal RoomKey:(NSString *)roomKey RoomPin:(NSString *)roomPin DisplayName:(NSString *)displayName
{
  [self.connector connectToRoomAsGuest:[portal cStringUsingEncoding:NSASCIIStringEncoding]
                           DisplayName:[displayName cStringUsingEncoding:NSASCIIStringEncoding]
                               RoomKey:[roomKey cStringUsingEncoding:NSASCIIStringEncoding]
                               RoomPin:[roomPin cStringUsingEncoding:NSASCIIStringEncoding]
                     ConnectorIConnect:self];
  
  [self showView];
}

- (void)disconnect
{
  [self.connector disconnect];
}

- (void)onSuccess
{
  if (!self.onConnected) {
    return;
  }
  self.onConnected(@{@"status": @"true", @"reason": @"Connected"});
}

- (void)onDisconnected:(VCConnectorDisconnectReason)reason
{
  if (!self.onDisconnected) {
    return;
  }
  if (reason == VCConnectorDisconnectReasonDisconnected) {
    self.onDisconnected(@{@"reason": @"Disconnected: Succesfully disconnected"});
  } else {
    self.onDisconnected(@{@"reason": @"Disconnected: Unexpected disconnection"});
  }
}

#pragma mark - VCConnectorIRegisterLocalCameraEventListener

-(void) onLocalCameraAdded:(VCLocalCamera*)localCamera {
    if (localCamera != nil && [localCamera getPosition] == VCLocalCameraPositionFront) {
        [_connector selectLocalCamera: localCamera];
    }
}

-(void) onLocalCameraRemoved:(VCLocalCamera*)localCamera {}
    
-(void) onLocalCameraSelected:(VCLocalCamera*)localCamera {
      // If a camera is selected, then update lastSelectedCamera.
      // localCamera will be nil only when backgrounding app while disconnected.
      if (localCamera) {
          lastSelectedCamera = localCamera;
      }
}

-(void) onLocalCameraStateUpdated:(VCLocalCamera*)localCamera State:(VCDeviceState)state {}

- (void)onParticipantJoined:(VCParticipant*)participant
{
  if (!self.onParticipantJoined) {
    return;
  }
  NSDictionary *nsParticipant = @{@"id": participant.id, @"name": participant.name, @"userId": participant.userId};
  self.onParticipantJoined(@{@"participant": nsParticipant});
}

- (void)onParticipantLeft:(VCParticipant*)participant
{
  if (!self.onParticipantLeft) {
    return;
  }
  NSDictionary *nsParticipant = @{@"id": participant.id, @"name": participant.name, @"userId": participant.userId};
  self.onParticipantLeft(@{@"participant": nsParticipant});
}

- (void)onDynamicParticipantChanged:(NSMutableArray*)participants
{
  if (!self.onParticipantsChanged) {
    return;
  }
  NSMutableArray *nsParticipants = [[NSMutableArray alloc] init];

  for (int i = 0; i < [participants count]; i++) {
    VCParticipant *participant = participants[i];
    nsParticipants[i] = @{@"id": participant.id, @"name": participant.name, @"userId": participant.userId};
  }
  NSArray * participantsResult = [NSArray arrayWithArray:nsParticipants];
  self.onParticipantsChanged(@{@"participants": participantsResult});
}

- (void)onLoudestParticipantChanged:(VCParticipant*)participant AudioOnly:(BOOL)audioOnly
{
  if (!self.onLoudestParticipantChanged) {
    return;
  }
  NSDictionary *nsParticipant = @{@"id": participant.id, @"name": participant.name, @"userId": participant.userId};
  self.onLoudestParticipantChanged(@{@"participant": nsParticipant, @"audioOnly": @(audioOnly)});
}

#pragma mark - VCConnectorIRegisterResourceManagerEventListener
-(void) onAvailableResourcesChanged:(unsigned int)cpuEncode CpuDecode:(unsigned int)cpuDecode BandwidthSend:(unsigned int)bandwidthSend BandwidthReceive:(unsigned int)bandwidthReceive
{
  if (!self.onAvailableResourcesChanged) { return; }

  NSDictionary *nsResources = @{@"cpuEncode": [NSNumber numberWithInt: cpuEncode], @"cpuDecode": [NSNumber numberWithInt: cpuDecode], @"bandwidthSend": [NSNumber numberWithInt: bandwidthSend], @"bandwidthReceive": [NSNumber numberWithInt: bandwidthReceive]};
  self.onAvailableResourcesChanged(@{@"resources": nsResources});
}

-(void) onMaxRemoteSourcesChanged:(unsigned int)maxRemoteSources {
  
  if (!self.onMaxRemoteSourcesChanged) { return; }
  
  NSDictionary *nsMaxRemoteSources = @{@"maxRemoteSources": [NSNumber numberWithInt: maxRemoteSources]};
  self.onMaxRemoteSourcesChanged(@{@"resources": nsMaxRemoteSources});
}

- (void)onFailure:(VCConnectorFailReason)reason {}

- (void)onLoudestParticipantChanged:(unsigned int)cpuEncode CpuDecode:(unsigned int)cpuDecode BandwidthSend:(unsigned int)bandwidthSend BandwidthReceive:(unsigned int)bandwidthReceive {
}

- (void)setMode:(VCConnectorMode)mode {}

#pragma mark - VCConnectorIRegisterRecorderInCallEventListener

-(void) recorderInCall:(BOOL)hasRecorder IsPaused:(BOOL)isPaused {}

#pragma mark - VCConnectorIRegisterMessageEventListener

-(void) onChatMessageReceived:(VCParticipant*)participant ChatMessage:(VCChatMessage*)chatMessage {
  NSLog(@"onChatMessageReceived %@", chatMessage.body);
  NSString *command = chatMessage.body;
  
  // Recording
  if ([command isEqualToString:CommandMessageRecordingStarted] ||
      [command isEqualToString:CommandMessageRecordingPaused] ||
      [command isEqualToString:CommandMessageRecordingStopped]) {
    [self processRecordingCommand: command];
  }
}

-(void) processRecordingCommand: (NSString*) command {
  NSLog(@"processRecordingCommand %@", command);
  BOOL recordingStarted = [command isEqualToString: CommandMessageRecordingStarted];
  if (recordingStarted) {
    self.onRecordingStarted(@{});
  } else {
    self.onRecordingStopped(@{});
  }
}

@end
