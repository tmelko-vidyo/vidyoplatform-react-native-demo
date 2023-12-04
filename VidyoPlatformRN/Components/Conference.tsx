import React, { useEffect } from 'react';
import { View, Button, Dimensions } from 'react-native';
import VidyoViewWrapper from './VidyoConnectorView';
import { ConferenceProps } from '../App';

const Conference = ({ navigation }: ConferenceProps) => {

    const { height: scrHeight, width: scrWidth } = Dimensions.get('screen');

    useEffect(() => {
        console.debug("Conference Opened");
        return () => {
            console.debug("Conference Closed");
        }
    }, []);

    return <View style={{
        width: "100%",
        height: "100%",
        backgroundColor: "rgba(11, 11, 100, 0.5)"
    }}>
        <VidyoViewWrapper
            videoWidth={scrWidth}
            videoHeight={scrHeight}
            onInitialized={(event) => {

            }}
            onConnected={(event) => {

            }}
            onDisconnected={(event) => {

            }}
            onParticipantsChanged={(event) => {

            }}
            onRecordingStarted={(event) => {

            }}
            onRecordingStopped={(event) => {

            }} />
        {/* <Button title="Back Home" onPress={() => navigation.navigate('Home')} /> */}
    </View>;
}

export default Conference;