@Component
export struct SkillTag {
  name: string;
  status: number;

  private getBgColor(): string {
    if (this.status === 2) return '#E8F5E9';
    if (this.status === 1) return '#E6F0FF';
    return '#f4f3f3';
  }

  private getTextColor(): string {
    if (this.status === 2) return '#28A745';
    if (this.status === 1) return '#007DFF';
    return '#909399';
  }

  build() {
    Row({ space: 4 }) {
      if (this.status === 2) {
        Text('✓').fontSize(12).fontColor('#28A745').fontWeight(FontWeight.Bold)
      } else if (this.status === 1) {
        Text('▶').fontSize(12).fontColor('#007DFF').fontWeight(FontWeight.Bold)
      }
      Text(this.name)
        .fontSize(12)
        .fontColor(this.getTextColor())
    }
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .borderRadius(8)
    .backgroundColor(this.getBgColor())
  }
}

