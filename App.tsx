import React, { useState, useRef, ComponentType } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  Image,
  Animated,
  FlatList,
  ScrollView,
  ListRenderItem,
  ViewStyle,
  TextStyle,
  ImageStyle,
} from 'react-native';
import { TabView, SceneMap, TabBar, Route, NavigationState } from 'react-native-tab-view';

const { width, height } = Dimensions.get('window');
const HEADER_MAX_HEIGHT = 200;
const HEADER_MIN_HEIGHT = 90;
const HEADER_SCROLL_DISTANCE = HEADER_MAX_HEIGHT - HEADER_MIN_HEIGHT;

interface SceneProps {
  scrollY: Animated.Value;
  headerHeight: number;
  tabBarHeight: number;
}

interface Item {
  id: number;
}

function App(){
  const [index, setIndex] = useState<number>(0);
  const [routes] = useState<Route[]>([
    { key: 'recommend', title: '推荐' },
    { key: 'hot', title: '热门' },
    { key: 'latest', title: '最新' },
  ]);

  const scrollY = useRef<Animated.Value>(new Animated.Value(0)).current;

  // 头部动画
  const headerTranslate = scrollY.interpolate({
    inputRange: [0, HEADER_SCROLL_DISTANCE],
    outputRange: [0, -HEADER_SCROLL_DISTANCE],
    extrapolate: 'clamp' as const,
  });

  const headerTitleOpacity = scrollY.interpolate({
    inputRange: [0, HEADER_SCROLL_DISTANCE * 0.7, HEADER_SCROLL_DISTANCE],
    outputRange: [1, 0.3, 0],
    extrapolate: 'clamp' as const,
  });

  // TabBar 动画
  const tabBarTranslate = scrollY.interpolate({
    inputRange: [0, HEADER_SCROLL_DISTANCE],
    outputRange: [HEADER_MAX_HEIGHT, HEADER_MIN_HEIGHT],
    extrapolate: 'clamp' as const,
  });

  // 渲染头部
  const renderHeader = () => (
    <Animated.View
      style={[
        styles.header,
        {
          transform: [{ translateY: headerTranslate }],
        },
      ]}
    >
      <Image
        source={{ uri: 'https://picsum.photos/800/400' }}
        style={styles.headerBackground}
      />
      <Animated.View
        style={[
          styles.headerTitleContainer,
          { opacity: headerTitleOpacity },
        ]}
      >
        <Text style={styles.headerTitle}>嵌套滚动 + TabBar吸顶</Text>
      </Animated.View>
    </Animated.View>
  );

  // 渲染 TabBar
  const renderTabBar = (props: any) => (
    <Animated.View
      style={[
        styles.tabBarContainer,
        {
          transform: [{ translateY: tabBarTranslate }],
        },
      ]}
    >
      <TabBar
        {...props}
        style={styles.tabBar}
        indicatorStyle={styles.indicator}
        labelStyle={styles.label}
        activeColor="#007AFF"
        inactiveColor="#666"
      />
    </Animated.View>
  );

  // 创建可滚动的场景
  const renderScene = ({ route }: { route: Route }) => {
    const SceneComponent = getSceneComponent(route.key);
    return (
      <SceneComponent
        scrollY={scrollY}
        headerHeight={HEADER_MAX_HEIGHT}
        tabBarHeight={48}
      />
    );
  };

  return (
    <View style={styles.container}>
      {renderHeader()}
      <TabView
        navigationState={{ index, routes }}
        renderScene={renderScene}
        renderTabBar={renderTabBar}
        onIndexChange={setIndex}
        initialLayout={{ width }}
        style={styles.tabView}
        swipeEnabled={true}
      />
    </View>
  );
};

// 获取场景组件
const getSceneComponent = (key: string): ComponentType<SceneProps> => {
  switch (key) {
    case 'recommend':
      return RecommendScene;
    case 'hot':
      return HotScene;
    case 'latest':
      return LatestScene;
    default:
      return RecommendScene;
  }
};

// 推荐场景
const RecommendScene: React.FC<SceneProps> = ({ scrollY, headerHeight, tabBarHeight }) => {
  const data: Item[] = Array.from({ length: 100 }).map((_, i) => ({ id: i }));

  const renderItem: ListRenderItem<Item> = ({ item }) => (
    <View style={sceneStyles.item}>
      <View style={sceneStyles.avatar}>
        <Text style={sceneStyles.avatarText}>{item.id}</Text>
      </View>
      <View>
        <Text style={sceneStyles.title}>推荐内容 - 项目 {item.id}</Text>
        <Text style={sceneStyles.subtitle}>这是描述内容</Text>
      </View>
    </View>
  );

  return (
    <Animated.FlatList
      data={data}
      renderItem={renderItem}
      keyExtractor={(item) => item.id.toString()}
      onScroll={Animated.event(
        [{ nativeEvent: { contentOffset: { y: scrollY } } }],
        { useNativeDriver: true }
      )}
      scrollEventThrottle={16}
      contentContainerStyle={{
        paddingTop: headerHeight + tabBarHeight,
      }}
    />
  );
};

// 热门场景
const HotScene: React.FC<SceneProps> = ({ scrollY, headerHeight, tabBarHeight }) => {
  const data: Item[] = Array.from({ length: 100 }).map((_, i) => ({ id: i }));

  const renderItem: ListRenderItem<Item> = ({ item }) => (
    <View style={sceneStyles.gridItem}>
      <View
        style={[
          sceneStyles.gridImage,
          { backgroundColor: getRandomColor() },
        ]}
      >
        <Text style={sceneStyles.gridText}>热门 {item.id}</Text>
      </View>
    </View>
  );

  return (
    <Animated.FlatList
      data={data}
      renderItem={renderItem}
      keyExtractor={(item) => item.id.toString()}
      numColumns={2}
      onScroll={Animated.event(
        [{ nativeEvent: { contentOffset: { y: scrollY } } }],
        { useNativeDriver: true }
      )}
      scrollEventThrottle={16}
      contentContainerStyle={{
        paddingTop: headerHeight + tabBarHeight,
      }}
    />
  );
};

// 最新场景
const LatestScene: React.FC<SceneProps> = ({ scrollY, headerHeight, tabBarHeight }) => {
  const data: Item[] = Array.from({ length: 100 }).map((_, i) => ({ id: i }));

  const renderItem: ListRenderItem<Item> = ({ item }) => (
    <View style={sceneStyles.card}>
      <Text style={sceneStyles.cardTitle}>最新内容 - 项目 {item.id}</Text>
      <Text style={sceneStyles.cardContent}>
        这是详细的内容描述，可以显示多行文本...
      </Text>
    </View>
  );

  return (
    <Animated.FlatList
      data={data}
      renderItem={renderItem}
      keyExtractor={(item) => item.id.toString()}
      onScroll={Animated.event(
        [{ nativeEvent: { contentOffset: { y: scrollY } } }],
        { useNativeDriver: true }
      )}
      scrollEventThrottle={16}
      contentContainerStyle={{
        paddingTop: headerHeight + tabBarHeight,
      }}
    />
  );
};

const getRandomColor = (): string => {
  const colors = [
    '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7',
    '#DDA0DD', '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E9'
  ];
  return colors[Math.floor(Math.random() * colors.length)];
};

interface Styles {
  container: ViewStyle;
  header: ViewStyle;
  headerBackground: ImageStyle;
  headerTitleContainer: ViewStyle;
  headerTitle: TextStyle;
  tabBarContainer: ViewStyle;
  tabBar: ViewStyle;
  indicator: ViewStyle;
  label: TextStyle;
  tabView: ViewStyle;
}

const styles = StyleSheet.create<Styles>({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  header: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: HEADER_MAX_HEIGHT,
    zIndex: 100,
    overflow: 'hidden',
  },
  headerBackground: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    width: null as any,
    height: HEADER_MAX_HEIGHT,
  },
  headerTitleContainer: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: 'flex-end',
    paddingBottom: 20,
    paddingHorizontal: 20,
  },
  headerTitle: {
    color: 'white',
    fontSize: 24,
    fontWeight: 'bold',
  },
  tabBarContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    zIndex: 101,
    backgroundColor: 'white',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  tabBar: {
    backgroundColor: 'white',
    elevation: 0,
  },
  indicator: {
    backgroundColor: '#007AFF',
    height: 3,
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
  },
  tabView: {
    flex: 1,
  },
});

interface SceneStyles {
  item: ViewStyle;
  avatar: ViewStyle;
  avatarText: TextStyle;
  title: TextStyle;
  subtitle: TextStyle;
  gridItem: ViewStyle;
  gridImage: ViewStyle;
  gridText: TextStyle;
  card: ViewStyle;
  cardTitle: TextStyle;
  cardContent: TextStyle;
}

const sceneStyles = StyleSheet.create<SceneStyles>({
  item: {
    flexDirection: 'row',
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
    alignItems: 'center',
  },
  avatar: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: '#007AFF',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  avatarText: {
    color: 'white',
    fontWeight: 'bold',
  },
  title: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 14,
    color: '#666',
  },
  gridItem: {
    flex: 1,
    margin: 8,
    aspectRatio: 1,
  },
  gridImage: {
    flex: 1,
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
  },
  gridText: {
    color: 'white',
    fontWeight: 'bold',
    fontSize: 16,
  },
  card: {
    backgroundColor: 'white',
    marginHorizontal: 16,
    marginVertical: 8,
    padding: 16,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#eee',
  },
  cardTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  cardContent: {
    fontSize: 14,
    color: '#666',
  },
});

export default App;

