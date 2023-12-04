import React from "react";
import { findNodeHandle, Platform, requireNativeComponent, UIManager } from "react-native";

const VidyoView = requireNativeComponent("VidyoModule");

type Props = {
  videoWidth: number;
  videoHeight: number;
  onInitialized: (e: any) => void;
  onConnected: (e: any) => void;
  onDisconnected: (e: any) => void;
  onParticipantsChanged: (e: any) => void;
  onRecordingStarted: (e: any) => void;
  onRecordingStopped: (e: any) => void;
};

export default class VidyoViewWrapper extends React.Component<Props> {
  private static isAndroid() {
    return Platform.OS === "android";
  }

  componentDidMount() {
    this.initialize();
  }

  private runCommand = (event: string, args: any) => {
    console.log("runCommand ", event, args);
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.videoView),
      //@ts-ignore //ts definition requires a number, but it also works with strings
      event,
      args,
    );
  };

  public initialize = () => {
    this.runCommand("initialize", [findNodeHandle(this.videoView)]);
  };

  public setCameraPrivacy = (isOn: boolean) => {
    this.runCommand("setCameraPrivacy", [isOn]);
  };

  public setMicrophonePrivacy = (isOn: boolean) => {
    this.runCommand("setMicrophonePrivacy", [isOn]);
  };

  public setSpeakerPrivacy = (isOn: boolean) => {
    this.runCommand("setSpeakerPrivacy", [isOn]);
  };

  public connect = (host: string, roomKey: string, displayName: string) => {
    this.runCommand("connect", [host, roomKey, displayName]);
  };

  public cycleCamera = () => {
    this.runCommand("cycleCamera", []);
  };

  public disconnect = () => {
    this.runCommand("disconnect", []);
  };

  private videoView: any;

  render() {
    return (
      <VidyoView
        ref={(ref) => (this.videoView = ref)}
        //@ts-ignore
        style={{ width: this.props.videoWidth, height: this.props.videoHeight }}
        videoWidth={this.props.videoWidth}
        videoHeight={this.props.videoHeight}
        onInitialized={this.props.onInitialized}
        onConnected={this.props.onConnected}
        onDisconnected={this.props.onDisconnected}
        onParticipantsChanged={this.props.onParticipantsChanged}
        onRecordingStarted={this.props.onRecordingStarted}
        onRecordingStopped={this.props.onRecordingStopped}
      />
    );
  }
}
