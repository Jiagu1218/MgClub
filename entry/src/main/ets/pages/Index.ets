import { MainTabPage } from './MainTabPage';

@Entry
@ComponentV2
struct Index {
  build() {
    Column() {
      MainTabPage()
    }
    .width('100%')
    .height('100%')
  }
}