import router from '@ohos.router';

interface ForwardPassResult {
  H1: number[];
  Output: number[];
}

@Entry
@Component
struct NeuralNetworks {
  @State gradientAngle: number = 0;
  private scroller: Scroller = new Scroller();

  @State pressure: number = 0.5;
  @State temperature: number = 0.5;
  @State vibration: number = 0.5;

  private W1: number[][] = [
    [ 0.8, -0.5,  0.2],
    [-0.4,  0.9, -0.1],
    [ 0.3,  0.5,  0.8],
    [-0.7, -0.2,  0.9]
  ];
  private B1: number[] = [-0.1, 0.2, -0.5, 0.1];

  private W2: number[][] = [
    [ 0.5,  0.4, -0.8, -0.6],
    [-0.6, -0.5,  0.9,  0.8]
  ];
  private B2: number[] = [0.5, -0.5];

  aboutToAppear() {
    setInterval(() => {
      animateTo({ duration: 2000, curve: Curve.Linear }, () => {
        this.gradientAngle = (this.gradientAngle + 45) % 360;
      });
    }, 2000);
  }

  relu(x: number): number {
    return Math.max(0, x);
  }

  softmax(logits: number[]): number[] {
    let maxLogit = Math.max(...logits);
    let exps = logits.map(l => Math.exp(l - maxLogit));
    let sumExps = exps.reduce((a, b) => a + b, 0);
    return exps.map(e => e / sumExps);
  }

  calculateForwardPass(): ForwardPassResult {
    let X = [this.pressure, this.temperature, this.vibration];
    let H1 = [0, 0, 0, 0];

    for (let i = 0; i < 4; i++) {
      let dotProduct = 0;
      for (let j = 0; j < 3; j++) {
        dotProduct += this.W1[i][j] * X[j];
      }
      H1[i] = this.relu(dotProduct + this.B1[i]);
    }

    let Z2 = [0, 0];
    for (let i = 0; i < 2; i++) {
      let dotProduct = 0;
      for (let j = 0; j < 4; j++) {
        dotProduct += this.W2[i][j] * H1[j];
      }
      Z2[i] = dotProduct + this.B2[i];
    }

    let Output = this.softmax(Z2);

    return { H1: H1, Output: Output };
  }

  build() {
    // ÇÖZÜM: Scroll'u saran, tüm ekranı kaplayan ve renkleri barındıran Ana Sütun eklendi
    Column() {
      Scroll(this.scroller) {
        Column() {
          Row() {
            Text('< Geri').fontFamily('monospace').fontSize(18).fontColor(Color.White).fontWeight(FontWeight.Bold).onClick(() => { router.back(); })
            Blank()
          }.width('100%').padding(20)

          Text('DERİN SİNİR AĞLARI (MATRİS)')
            .fontFamily('monospace').fontSize(20).fontWeight(FontWeight.Bolder).fontColor(Color.White).margin({ bottom: 15 }).textAlign(TextAlign.Center)

          Column() {
            Text('GİRDİ VEKTÖRÜ (X): İŞ MAKİNESİ').fontFamily('monospace').fontColor('#00FFFF').fontSize(12).fontWeight(FontWeight.Bold).margin({ bottom: 15 }).width('100%').textAlign(TextAlign.Start)

            Text(`Basınç [x1]: ${this.pressure.toFixed(2)}`).fontFamily('monospace').fontColor(Color.White).fontSize(12)
            Slider({ value: this.pressure, min: 0, max: 1, step: 0.05, style: SliderStyle.OutSet }).blockColor('#00FFFF').trackColor('#1C2541').selectedColor('#00FFFF').onChange((val) => { this.pressure = val; })

            Text(`Sıcaklık [x2]: ${this.temperature.toFixed(2)}`).fontFamily('monospace').fontColor(Color.White).fontSize(12).margin({ top: 10 })
            Slider({ value: this.temperature, min: 0, max: 1, step: 0.05, style: SliderStyle.OutSet }).blockColor('#00FFFF').trackColor('#1C2541').selectedColor('#00FFFF').onChange((val) => { this.temperature = val; })

            Text(`Titreşim [x3]: ${this.vibration.toFixed(2)}`).fontFamily('monospace').fontColor(Color.White).fontSize(12).margin({ top: 10 })
            Slider({ value: this.vibration, min: 0, max: 1, step: 0.05, style: SliderStyle.OutSet }).blockColor('#00FFFF').trackColor('#1C2541').selectedColor('#00FFFF').onChange((val) => { this.vibration = val; })
          }.width('95%').padding(15).border({ width: 2, color: '#00FFFF' }).margin({ bottom: 20 })

          Column() {
            Text('1. GİZLİ KATMAN (4 Nöron)').fontFamily('monospace').fontColor('#00FF00').fontSize(12).fontWeight(FontWeight.Bold).margin({ bottom: 10 }).width('100%').textAlign(TextAlign.Start)
            Text('H^(1) = ReLU(W^(1) \u00B7 X + b^(1))').fontFamily('monospace').fontColor(Color.Gray).fontSize(10).margin({ bottom: 15 }).width('100%').textAlign(TextAlign.Center)

            Row() {
              Column() {
                Text('W1(4x3)').fontFamily('monospace').fontSize(10).fontColor(Color.Gray).margin({ bottom: 5 })
                Grid() {
                  ForEach(this.W1.flat(), (val: number) => {
                    GridItem() { Text(val.toFixed(1)).fontFamily('monospace').fontSize(10).fontColor(Color.White).border({ width: 1, color: '#1C2541' }).width('100%').textAlign(TextAlign.Center).padding(2) }
                  })
                }.columnsTemplate('1fr 1fr 1fr').width(110).backgroundColor('#050A15').border({ width: 1, color: Color.Gray })
              }

              Text('\u00B7').fontFamily('monospace').fontSize(24).fontColor(Color.White).margin(5)

              Column() {
                Text('X(3x1)').fontFamily('monospace').fontSize(10).fontColor(Color.Gray).margin({ bottom: 5 })
                Column() {
                  Text(this.pressure.toFixed(2)).fontFamily('monospace').fontSize(10).fontColor('#00FFFF').padding(2)
                  Text(this.temperature.toFixed(2)).fontFamily('monospace').fontSize(10).fontColor('#00FFFF').padding(2)
                  Text(this.vibration.toFixed(2)).fontFamily('monospace').fontSize(10).fontColor('#00FFFF').padding(2)
                }.border({ width: 1, color: '#00FFFF' }).backgroundColor('#050A15').width(40)
              }

              Text('+B1\u2794').fontFamily('monospace').fontSize(12).fontColor(Color.Gray).margin(5)

              Column() {
                Text('H1(4x1)').fontFamily('monospace').fontSize(10).fontColor(Color.Gray).margin({ bottom: 5 })
                Column() {
                  ForEach(this.calculateForwardPass().H1, (val: number) => {
                    Text(val.toFixed(2)).fontFamily('monospace').fontSize(10).fontColor(val > 0 ? '#00FF00' : Color.Gray).padding(2)
                  })
                }.border({ width: 1, color: '#00FF00' }).backgroundColor('#050A15').width(40)
              }
            }.width('100%').justifyContent(FlexAlign.Center).margin({ bottom: 10 })

          }.width('95%').padding(15).backgroundColor('#0B132B').border({ width: 2, color: '#00FF00', style: BorderStyle.Dashed }).margin({ bottom: 20 })

          Column() {
            Text('ÇIKTI KATMANI (Output Layer)').fontFamily('monospace').fontColor('#FF00FF').fontSize(12).fontWeight(FontWeight.Bold).margin({ bottom: 10 }).width('100%').textAlign(TextAlign.Start)
            Text('Y = Softmax(W^(2) \u00B7 H^(1) + b^(2))').fontFamily('monospace').fontColor(Color.Gray).fontSize(10).margin({ bottom: 15 }).width('100%').textAlign(TextAlign.Center)

            Row() {
              Column() {
                Text('NORMAL').fontFamily('monospace').fontSize(12).fontColor(Color.White).fontWeight(FontWeight.Bold)
                Text(`% ${(this.calculateForwardPass().Output[0] * 100).toFixed(1)}`)
                  .fontFamily('monospace').fontSize(24).fontColor('#00FFFF').fontWeight(FontWeight.Bolder)
                  .margin({ top: 5 })
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)

              Column() {
                Text('ARIZA').fontFamily('monospace').fontSize(12).fontColor(Color.White).fontWeight(FontWeight.Bold)
                Text(`% ${(this.calculateForwardPass().Output[1] * 100).toFixed(1)}`)
                  .fontFamily('monospace').fontSize(24).fontColor(this.calculateForwardPass().Output[1] > 0.5 ? Color.Red : Color.Gray).fontWeight(FontWeight.Bolder)
                  .margin({ top: 5 })
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)
            }.width('100%')

          }.width('95%').padding(15).border({ width: 2, color: '#FF00FF' }).margin({ bottom: 40 })

        }.width('100%')
      }.layoutWeight(1).width('100%')
    }
    .width('100%').height('100%') // Ekranı tam kapla
    .linearGradient({ angle: this.gradientAngle, colors: [['#0B132B', 0.0], ['#1C2541', 0.5], ['#0B132B', 1.0]] }) // Renkleri geri getir
  }
}