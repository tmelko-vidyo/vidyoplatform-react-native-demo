package com.vidyo.platform.react.component;

import static com.vidyo.platform.react.component.VidyoConnectorVideoManager.Events.ON_CONNECTED;
import static com.vidyo.platform.react.component.VidyoConnectorVideoManager.Events.ON_DISCONNECTED;
import static com.vidyo.platform.react.component.VidyoConnectorVideoManager.Events.ON_INITIALIZED;
import static com.vidyo.platform.react.component.VidyoConnectorVideoManager.Events.ON_PARTICIPANTS_CHANGED;
import static com.vidyo.platform.react.component.VidyoConnectorVideoManager.Events.ON_RECORDING_STARTED;
import static com.vidyo.platform.react.component.VidyoConnectorVideoManager.Events.ON_RECORDING_STOPPED;

import android.util.Log;
import android.view.Choreographer;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringDef;
import androidx.fragment.app.FragmentActivity;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.util.Map;

import expo.modules.core.logging.Logger;

public class VidyoConnectorVideoManager extends ViewGroupManager<FrameLayout> {
    public static String TAG = "VidyoConnectorVideoManager";

    @Retention(RetentionPolicy.SOURCE)
    @StringDef({
            ON_INITIALIZED,
            ON_CONNECTED,
            ON_DISCONNECTED,
            ON_PARTICIPANTS_CHANGED,
            ON_RECORDING_STARTED,
            ON_RECORDING_STOPPED
    })

    public @interface Events {
        String ON_INITIALIZED = "onInitialized";
        String ON_CONNECTED = "onConnected";
        String ON_DISCONNECTED = "onDisconnected";
        String ON_PARTICIPANTS_CHANGED = "onParticipantsChanged";
        String ON_RECORDING_STARTED = "onRecordingStarted";
        String ON_RECORDING_STOPPED = "onRecordingStopped";
    }

    public @interface Commands {
        String INITIALIZE = "initialize";
        String CONNECT = "connect";
        String DISCONNECT = "disconnect";
        String CYCLE_CAMERA = "cycleCamera";
        String SET_MICROPHONE_PRIVACY = "setMicrophonePrivacy";
        String SET_CAMERA_PRIVACY = "setCameraPrivacy";
        String SET_SPEAKER_PRIVACY = "setSpeakerPrivacy";
    }

    public @interface MessageCommands {
        String RECORDING_STARTED = "RECORDING_STARTED";
        String RECORDING_PAUSED = "RECORDING_PAUSED";
        String RECORDING_STOPPED = "RECORDING_STOPPED";
    }

    public static final String REACT_CLASS = "VidyoModule";

    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }

    ThemedReactContext reactContext;

    private VidyoConnectorFragment vidyoConnectorFragment;

    private int propWidth;
    private int propHeight;

    @ReactProp(name = "videoWidth")
    public void setVideoWidth(FrameLayout view, int videoWidth) {
        propWidth = videoWidth;
    }

    @ReactProp(name = "videoHeight")
    public void setVideoHeight(FrameLayout view, int videoHeight) {
        propHeight = videoHeight;
    }

    @NonNull
    @Override
    protected FrameLayout createViewInstance(@NonNull ThemedReactContext reactContext) {
        this.reactContext = reactContext;
        return new FrameLayout(reactContext);
    }

    public void createFragment(FrameLayout root, int reactNativeViewId) {
        ViewGroup parentView = (ViewGroup) root.findViewById(reactNativeViewId);
        setupLayout(parentView);

        vidyoConnectorFragment = new VidyoConnectorFragment(reactContext);
        FragmentActivity activity = (FragmentActivity) reactContext.getCurrentActivity();
        activity.getSupportFragmentManager()
                .beginTransaction()
                .replace(reactNativeViewId, vidyoConnectorFragment, String.valueOf(reactNativeViewId))
                .commit();
    }

    public void setupLayout(View view) {
        Log.i(TAG, "setupLayout");
        Choreographer.getInstance().postFrameCallback(new Choreographer.FrameCallback() {
            @Override
            public void doFrame(long frameTimeNanos) {
                manuallyLayoutChildren(view);
                view.getViewTreeObserver().dispatchOnGlobalLayout();
                Choreographer.getInstance().removeFrameCallback(this);
            }
        });
    }

    public void manuallyLayoutChildren(View view) {
        Log.i(TAG, "Measure layout: " + propWidth + "x" + propHeight);

        view.measure(
                View.MeasureSpec.makeMeasureSpec(propWidth, View.MeasureSpec.EXACTLY),
                View.MeasureSpec.makeMeasureSpec(propHeight, View.MeasureSpec.EXACTLY));
        view.layout(0, 0, propWidth, propHeight);
    }

    @Override
    public void receiveCommand(@NonNull FrameLayout view, String command, @Nullable ReadableArray args) {
        Log.i(TAG, "receiveCommand: " + command + ", " + args);
        super.receiveCommand(view, command, args);
        switch (command) {
            case Commands.INITIALIZE:
                createFragment(view, args.getInt(0));
                break;
            case Commands.CONNECT:
                String host = args.getString(0);
                String roomKey = args.getString(1);
                String displayName = args.getString(2);
                vidyoConnectorFragment.connect(host, roomKey, displayName);
                break;
            case Commands.DISCONNECT:
                vidyoConnectorFragment.disconnect();
                break;
            case Commands.CYCLE_CAMERA:
                vidyoConnectorFragment.cycleCamera();
                break;
            case Commands.SET_MICROPHONE_PRIVACY:
                boolean isMicOn = args.getBoolean(0);
                vidyoConnectorFragment.setMicrophonePrivacy(isMicOn);
                break;
            case Commands.SET_CAMERA_PRIVACY:
                boolean isCameraOn = args.getBoolean(0);
                vidyoConnectorFragment.setCameraPrivacy(isCameraOn);
                break;
            case Commands.SET_SPEAKER_PRIVACY:
                boolean isSpeakerOn = args.getBoolean(0);
                vidyoConnectorFragment.setSpeakerPrivacy(isSpeakerOn);
                break;
        }
    }

    @Nullable
    @Override
    public Map getExportedCustomBubblingEventTypeConstants() {
        return MapBuilder.builder()
                .put(ON_INITIALIZED, MapBuilder.of("phasedRegistrationNames", MapBuilder.of("bubbled", ON_INITIALIZED)))
                .put(ON_CONNECTED, MapBuilder.of("phasedRegistrationNames", MapBuilder.of("bubbled", ON_CONNECTED)))
                .put(ON_DISCONNECTED, MapBuilder.of("phasedRegistrationNames", MapBuilder.of("bubbled", ON_DISCONNECTED)))
                .put(ON_PARTICIPANTS_CHANGED, MapBuilder.of("phasedRegistrationNames", MapBuilder.of("bubbled", ON_PARTICIPANTS_CHANGED)))
                .put(ON_RECORDING_STARTED, MapBuilder.of("phasedRegistrationNames", MapBuilder.of("bubbled", ON_RECORDING_STARTED)))
                .put(ON_RECORDING_STOPPED, MapBuilder.of("phasedRegistrationNames", MapBuilder.of("bubbled", ON_RECORDING_STOPPED)))
                .build();

    }
}
