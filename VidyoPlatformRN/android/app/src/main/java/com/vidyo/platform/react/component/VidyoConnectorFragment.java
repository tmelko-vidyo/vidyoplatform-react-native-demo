package com.vidyo.platform.react.component;

import static com.vidyo.platform.react.component.VidyoConnectorVideoManager.Events.ON_CONNECTED;
import static com.vidyo.platform.react.component.VidyoConnectorVideoManager.Events.ON_DISCONNECTED;
import static com.vidyo.platform.react.component.VidyoConnectorVideoManager.Events.ON_INITIALIZED;
import static com.vidyo.platform.react.component.VidyoConnectorVideoManager.Events.ON_PARTICIPANTS_CHANGED;
import static com.vidyo.platform.react.component.VidyoConnectorVideoManager.Events.ON_RECORDING_STARTED;
import static com.vidyo.platform.react.component.VidyoConnectorVideoManager.Events.ON_RECORDING_STOPPED;

import android.Manifest;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.fragment.app.Fragment;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.vidyo.VidyoClient.Connector.Connector;
import com.vidyo.VidyoClient.Connector.ConnectorPkg;
import com.vidyo.VidyoClient.Endpoint.ChatMessage;
import com.vidyo.VidyoClient.Endpoint.Participant;

import java.util.ArrayList;

public class VidyoConnectorFragment extends Fragment implements Connector.IConnect,
        Connector.IRegisterParticipantEventListener,
        Connector.IRegisterRecorderInCallEventListener,
        Connector.IRegisterMessageEventListener {

    private final String TAG = "VidyoConnectorFragment";

    private final RCTEventEmitter eventEmitter;
    private VidyoConnectorView vidyoConnectorView;

    private static final int PERMISSIONS_REQUEST_ALL = 0x7c9;

    private static final String[] PERMISSIONS = new String[]{
            Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO
    };

    VidyoConnectorFragment(ThemedReactContext reactContext) {
        super();
        this.eventEmitter = reactContext.getJSModule(RCTEventEmitter.class);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ConnectorPkg.initialize();
        ConnectorPkg.setApplicationUIContext(requireContext().getApplicationContext());
        ActivityCompat.requestPermissions(requireActivity(), PERMISSIONS, PERMISSIONS_REQUEST_ALL);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        vidyoConnectorView = new VidyoConnectorView(requireContext());
        vidyoConnectorView.setConnectListener(this);
        vidyoConnectorView.setParticipantListener(this);
        vidyoConnectorView.setRecordingListener(this);
        vidyoConnectorView.setChatListener(this);

        return vidyoConnectorView;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        WritableMap payload = Arguments.createMap();
        postEvent(ON_INITIALIZED, payload);
    }

    public void connect(String host, String roomKey, String displayName) {
        vidyoConnectorView.connect(host, roomKey, displayName);
    }

    public void disconnect() {
        Log.i(TAG, "disconnect");
        vidyoConnectorView.disconnect();
        ConnectorPkg.setApplicationUIContext(null);
        ConnectorPkg.uninitialize();
        vidyoConnectorView.releaseDevices();
    }

    public void cycleCamera() {
        vidyoConnectorView.cycleCamera();
    }

    public void setMicrophonePrivacy(boolean isMicOn) {
        vidyoConnectorView.setMicrophonePrivacy(isMicOn);
    }

    public void setCameraPrivacy(boolean isCameraOn) {
        vidyoConnectorView.setCameraPrivacy(isCameraOn);
    }

    public void setSpeakerPrivacy(boolean isSpeakerOn) {
        vidyoConnectorView.setSpeakerPrivacy(isSpeakerOn);
    }

    @Override
    public void onSuccess() {
        Log.i(TAG, "onSuccess");
        WritableMap payload = new WritableNativeMap();
        payload.putString("state", "connected");
        postEvent(ON_CONNECTED, payload);
    }

    @Override
    public void onFailure(Connector.ConnectorFailReason connectorFailReason) {
    }

    @Override
    public void onDisconnected(Connector.ConnectorDisconnectReason connectorDisconnectReason) {
        Log.i(TAG, "onDisconnected");
        WritableMap payload = new WritableNativeMap();
        payload.putString("state", "disconnected");
        postEvent(ON_DISCONNECTED, payload);
    }

    @Override
    public void onParticipantJoined(Participant participant) {
    }

    @Override
    public void onParticipantLeft(Participant participant) {
    }

    @Override
    public void onDynamicParticipantChanged(ArrayList<Participant> arrayList) {
        Log.i(TAG, "onDynamicParticipantChanged");
        WritableMap payload = Arguments.createMap();
        WritableArray participants = Arguments.createArray();

        for (Participant participant : arrayList) {
            WritableMap participantMap = Arguments.createMap();
            participantMap.putString("id", participant.id);
            participantMap.putString("name", participant.name);
            participantMap.putString("userId", participant.userId);
            participants.pushMap(participantMap);
        }

        payload.putArray("participants", participants);
        postEvent(ON_PARTICIPANTS_CHANGED, payload);
    }

    @Override
    public void onLoudestParticipantChanged(Participant participant, boolean b) {
    }

    public void postEvent(String eventName, WritableMap payload) {
        Log.i(TAG, "postEvent " + eventName + ", payload: " + payload);
        eventEmitter.receiveEvent(this.getId(), eventName, payload);
    }

    @Override
    public void recorderInCall(boolean hasRecorder, boolean isPaused) {
        Log.i(TAG, "recorderInCall" + hasRecorder + ",b1: " + isPaused);
    }

    @Override
    public void onChatMessageReceived(Participant participant, ChatMessage chatMessage) {
        Log.i(TAG, "onChatMessageReceived: " + chatMessage.body);
        String command = chatMessage.body;

        // Recording
        if (command.equals(VidyoConnectorVideoManager.MessageCommands.RECORDING_STARTED) ||
                command.equals(VidyoConnectorVideoManager.MessageCommands.RECORDING_STOPPED) ||
                command.equals(VidyoConnectorVideoManager.MessageCommands.RECORDING_PAUSED)) {
            processRecordingCommand(command);
        }
    }

    private void processRecordingCommand(String command) {
        Log.i(TAG, "processRecordingCommand " + command);
        boolean recordingStarted = command.equals(VidyoConnectorVideoManager.MessageCommands.RECORDING_STARTED);
        WritableMap payload = new WritableNativeMap();
        if (recordingStarted) {
            postEvent(ON_RECORDING_STARTED, payload);
        } else {
            postEvent(ON_RECORDING_STOPPED, payload);
        }
    }
}
