package com.vidyo.platform.react.component;

import android.content.Context;
import android.view.ViewTreeObserver;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.vidyo.VidyoClient.Connector.Connector;

public class VidyoConnectorView extends FrameLayout implements ViewTreeObserver.OnGlobalLayoutListener  {
    private final String TAG = "MyVidyoConnectorView";

    private final Connector mVidyoConnector;
    private Connector.IConnect connectListener;
    private Connector.IRegisterRecorderInCallEventListener recordingListener;

    public VidyoConnectorView(@NonNull Context context) {
        super(context);
        mVidyoConnector = new Connector(
                this,
                Connector.ConnectorViewStyle.VIDYO_CONNECTORVIEWSTYLE_Default,
                2,
                "warning all@VidyoConnector info@VidyoClient",
                "",
                0);
        mVidyoConnector.setMode(Connector.ConnectorMode.VIDYO_CONNECTORMODE_Foreground);
        mVidyoConnector.setLogLevel(
                Connector.ConnectorLoggerType.VIDYO_CONNECTORLOGGERTYPE_FILE,
                Connector.ConnectorLogLevel.VIDYO_CONNECTORLOGLEVEL_PRODUCTION);
        String rendererOptions = "{\"SetPipPosition\": {\"x\": \"PipPositionRight\", \"y\": \"PipPositionTop\", \"lockPip\":true}}";
        mVidyoConnector.showViewLabel(this, false);
        mVidyoConnector.setRendererOptionsForViewId(this, rendererOptions);
        mVidyoConnector.selectDefaultMicrophone();
        mVidyoConnector.selectDefaultSpeaker();
        getViewTreeObserver().addOnGlobalLayoutListener(this);
    }

    public void setConnectListener(Connector.IConnect connectListener) {
        this.connectListener = connectListener;
    }

    public void setParticipantListener(Connector.IRegisterParticipantEventListener participantListener) {
        mVidyoConnector.registerParticipantEventListener(participantListener);
    }

    public void setRecordingListener(Connector.IRegisterRecorderInCallEventListener recordingListener) {
        mVidyoConnector.registerRecorderInCallEventListener(recordingListener);
    }

    public void setChatListener(Connector.IRegisterMessageEventListener chatListener) {
        mVidyoConnector.registerMessageEventListener(chatListener);
    }

    public void connect(String host, String roomKey, String displayName) {
        mVidyoConnector.connectToRoomAsGuest(host, displayName, roomKey, "", connectListener);
    }

    public void disconnect() {
        mVidyoConnector.disconnect();
        mVidyoConnector.unregisterParticipantEventListener();
        mVidyoConnector.unregisterRecorderInCallEventListener();
        mVidyoConnector.unregisterMessageEventListener();
        mVidyoConnector.disable();
    }

    public void releaseDevices() {
        mVidyoConnector.selectLocalCamera(null);
        mVidyoConnector.selectLocalMicrophone(null);
        mVidyoConnector.selectLocalSpeaker(null);
    }

    public void cycleCamera() {
        mVidyoConnector.cycleCamera();
    }

    public void setMicrophonePrivacy(boolean isMicOn) {
        mVidyoConnector.setMicrophonePrivacy(isMicOn);
    }
    public void setCameraPrivacy(boolean isCameraOn) {
        mVidyoConnector.setCameraPrivacy(isCameraOn);
    }
    public void setSpeakerPrivacy(boolean isSpeakerOn) {
        mVidyoConnector.setSpeakerPrivacy(isSpeakerOn);
    }

    private boolean viewDidSet = false;
    @Override
    public void onGlobalLayout() {
        if (!viewDidSet) {
            viewDidSet = true;
            int width = getWidth();
            int height = getHeight();
            mVidyoConnector.showViewAt(this, 0, 0, width, height);
        }
    }
}
