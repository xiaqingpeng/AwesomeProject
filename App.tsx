/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import { NewAppScreen } from '@react-native/new-app-screen';
import React, { useEffect, useState } from 'react';
import { StatusBar, StyleSheet, Text, useColorScheme, View } from 'react-native';
import { Button } from 'utils';
import { Battery, BatteryInfoInterface } from 'battery';

import {
  SafeAreaProvider,
  useSafeAreaInsets,
} from 'react-native-safe-area-context';

function App() {
  const isDarkMode = useColorScheme() === 'dark';
  const [batteryInfo, setBatteryInfo] = useState<BatteryInfoInterface | null>(null);

  useEffect(() => {
    // 获取初始电池信息
    const fetchBatteryInfo = async () => {
      const info = await Battery.getBatteryInfo();
      setBatteryInfo(info);
    };

    fetchBatteryInfo();

    // 监听电池状态变化
    const unsubscribe = Battery.addBatteryListener((info) => {
      setBatteryInfo(info);
    });

    // 清理函数
    return () => {
      unsubscribe();
    };
  }, []);

  return (
    <SafeAreaProvider>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      <View style={{ padding: 16 }}>
        <Button title="Press me" onPress={() => console.log('Pressed')} />
        
        {batteryInfo && (
          <View style={styles.batteryInfo}>
            <Text style={styles.batteryTitle}>电池信息</Text>
            <Text>电量: {batteryInfo.level}%</Text>
            <Text>充电状态: {batteryInfo.isCharging ? '充电中' : '未充电'}</Text>
            <Text>低电量模式: {batteryInfo.isLowPower ? '开启' : '关闭'}</Text>
          </View>
        )}
      </View>
    </SafeAreaProvider>
  );
}

function AppContent() {
  const safeAreaInsets = useSafeAreaInsets();

  return (
    <View style={styles.container}>
      <NewAppScreen
        templateFileName="App.tsx"
        safeAreaInsets={safeAreaInsets}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  batteryInfo: {
    marginTop: 20,
    padding: 16,
    backgroundColor: '#f0f0f0',
    borderRadius: 8,
  },
  batteryTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 8,
  },
});

export default App;
