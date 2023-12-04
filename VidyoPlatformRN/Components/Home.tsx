import React from 'react';

import { View, Button } from 'react-native';
import { HomeProps } from '../App';

const Home = ({navigation}: HomeProps) => {

    return <View style={{
        flex: 1,
        backgroundColor: '#fff',
        alignItems: 'center',
        justifyContent: 'center'
    }}>
        <Button title="Connect to the conference" onPress={() => navigation.navigate('Conference')} />
    </View>;
}


export default Home;