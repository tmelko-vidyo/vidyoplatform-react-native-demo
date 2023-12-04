import React, { Component } from "react";
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';
import Home from "./Components/Home";
import Conference from "./Components/Conference";
import { createStackNavigator } from '@react-navigation/stack';

type RootStackParamList = {
  Home: undefined;
  Conference: undefined;
};

export type HomeProps = NativeStackScreenProps<RootStackParamList, 'Home'>;
export type ConferenceProps = NativeStackScreenProps<RootStackParamList, 'Conference'>;

const RootStack = createStackNavigator<RootStackParamList>();

export default class App extends Component {
  render() {
    return (
      <NavigationContainer>
        <RootStack.Navigator initialRouteName={"Home"}>
          <RootStack.Screen
            name={"Home"}
            component={Home}
            options={{ headerShown: false }}
          />
          <RootStack.Screen
            name={"Conference"}
            component={Conference}
            options={{
              /* Show the header on the conference */
              headerShown: true,
            }}
          />
        </RootStack.Navigator>
      </NavigationContainer>
    );
  }
}