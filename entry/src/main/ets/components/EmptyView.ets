@Component
export struct EmptyView {
  text: string = '暂无数据';

  build() {
    Column() {
      Text(this.text)
        .fontSize(14)
        .fontColor('#909399')
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

