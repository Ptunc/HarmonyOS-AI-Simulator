import router from '@ohos.router';

interface TokenItem {
  word: string;
  logit: number;
  probability: number;
}

@Entry
@Component
struct LargeLanguageModels {
  @State gradientAngle: number = 0;
  @State temperature: number = 1.0;
  @State contextText: string = "Yapay zeka dünyayı ele ...";

  @State tokens: TokenItem[] = [
    { word: "geçirmeyecek", logit: 5.2, probability: 0 },
    { word: "geçirecek", logit: 4.5, probability: 0 },
    { word: "boyayacak", logit: 1.2, probability: 0 },
    { word: "yiyor", logit: -0.5, probability: 0 }
  ];

  aboutToAppear() {
    this.calculateSoftmax();

    setInterval(() => {
      animateTo({ duration: 2000, curve: Curve.Linear }, () => {
        this.gradientAngle = (this.gradientAngle + 45) % 360;
      });
    }, 2000);
  }

  calculateSoftmax() {
    let t = Math.max(this.temperature, 0.01);
    let sumExp = 0;

    for (let token of this.tokens) {
      sumExp += Math.exp(token.logit / t);
    }

    let tempTokens = [...this.tokens];
    for (let i = 0; i < tempTokens.length; i++) {
      let expVal = Math.exp(tempTokens[i].logit / t);
      tempTokens[i].probability = (expVal / sumExp) * 100;
    }

    this.tokens = tempTokens.sort((a, b) => b.probability - a.probability);
  }

  generateNextToken() {
    let rand = Math.random() * 100;
    let cumulative = 0;
    let selectedWord = this.tokens[0].word;

    for (let token of this.tokens) {
      cumulative += token.probability;
      if (rand <= cumulative) {
        selectedWord = token.word;
        break;
      }
    }

    this.contextText += " " + selectedWord;
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          Text('< Geri').fontFamily('monospace').fontSize(18).fontColor(Color.White).fontWeight(FontWeight.Bold).onClick(() => { router.back(); })
          Blank()
        }.width('100%').padding(20)

        Text('BÜYÜK DİL MODELLERİ (LLM)')
          .fontFamily('monospace').fontSize(20).fontWeight(FontWeight.Bolder).fontColor(Color.White).margin({ bottom: 15 })

        Column() {
          Text('MEVCUT BAĞLAM (INPUT CONTEXT):').fontFamily('monospace').fontColor(Color.Gray).fontSize(12).margin({ bottom: 10 }).width('100%').textAlign(TextAlign.Start)

          Text(this.contextText)
            .fontFamily('monospace').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#00FFFF')
            .width('100%').padding(15).backgroundColor('#050A15').border({ width: 2, color: '#00FFFF' })
        }.width('95%').margin({ bottom: 20 })

        Column() {
          Text(`SICAKLIK (TEMPERATURE): ${this.temperature.toFixed(2)}`).fontFamily('monospace').fontColor(Color.White).fontSize(14).fontWeight(FontWeight.Bold)

          Slider({ value: this.temperature, min: 0.1, max: 2.0, step: 0.1, style: SliderStyle.OutSet })
            .blockColor('#00FF00').trackColor('#1C2541').selectedColor('#00FF00').width('100%')
            .onChange((val) => {
              this.temperature = val;
              this.calculateSoftmax();
            })

          Text("Düşük: Robotik ve Kesin | Yüksek: Yaratıcı ve Halüsinatif")
            .fontFamily('monospace').fontSize(10).fontColor(Color.Gray).margin({ top: 5 })
        }.width('95%').padding(15).border({ width: 2, color: Color.Gray }).margin({ bottom: 20 })

        Column() {
          Text('SONRAKİ KELİME OLASILIKLARI (NEXT TOKEN PROBABILITIES)').fontFamily('monospace').fontColor('#00FF00').fontSize(12).fontWeight(FontWeight.Bold).margin({ bottom: 15 }).width('100%').textAlign(TextAlign.Start)

          ForEach(this.tokens, (token: TokenItem) => {
            Column() {
              Row() {
                Text(`"${token.word}"`).fontFamily('monospace').fontSize(14).fontColor(Color.White).fontWeight(FontWeight.Bold)
                Blank()
                Text(`%${token.probability.toFixed(1)}`).fontFamily('monospace').fontSize(14).fontColor('#00FF00')
              }.width('100%').margin({ bottom: 5 })

              Stack({ alignContent: Alignment.Start }) {
                Row().width('100%').height(15).backgroundColor('#1C2541')
                Row().width(`${token.probability}%`).height(15).backgroundColor('#00FF00')
                  .animation({ duration: 200, curve: Curve.EaseOut })
              }.width('100%')
            }.width('100%').margin({ bottom: 15 })
          })

          // DÜZELTİLEN KISIM
          Text('MATEMATİK: Softmax(x_i) = exp(x_i / T) / \u2211 exp(x_j / T)')
            .fontFamily('monospace').fontSize(11).fontColor(Color.Gray).width('100%').textAlign(TextAlign.Center).margin({ top: 10 })

        }.width('95%').padding(15).backgroundColor('#0B132B').border({ width: 2, color: '#00FF00', style: BorderStyle.Dashed }).margin({ bottom: 20 })

        Button('SIRADAKİ KELİMEYİ TAHMİN ET (GENERATE)')
          .backgroundColor('#00FFFF').fontColor(Color.Black).fontFamily('monospace').fontWeight(FontWeight.Bolder).width('95%').height(60).borderRadius(0)
          .onClick(() => { this.generateNextToken(); })
          .margin({ bottom: 40 })

      }.width('100%')
    }
    .width('100%').height('100%')
    .linearGradient({ angle: this.gradientAngle, colors: [['#0B132B', 0.0], ['#1C2541', 0.5], ['#0B132B', 1.0]] })
  }
}