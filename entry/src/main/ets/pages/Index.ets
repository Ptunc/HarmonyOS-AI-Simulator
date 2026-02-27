import router from '@ohos.router';

@Entry
@Component
struct Index {
  private messages: string[] = [
    "Sisteme hoş geldin. Ben senin AI rehberinim.",
    "Burada yapay zekanın sihrini değil, matematiğini konuşacağız.",
    "Hazırsan, simülasyonları başlatıyorum."
  ];

  private robotImages: Resource[] = [
    $r('app.media.robot1'),
    $r('app.media.robot2'),
    $r('app.media.robot3')
  ];

  @State step: number = 0;
  @State gradientAngle: number = 0;

  aboutToAppear() {
    setInterval(() => {
      if (this.step < 2) {
        this.step += 1;
      }
    }, 3000);

    setInterval(() => {
      animateTo({ duration: 2000, curve: Curve.Linear }, () => {
        this.gradientAngle = (this.gradientAngle + 45) % 360;
      });
    }, 2000);
  }

  build() {
    // Tüm elemanları tutan TEK BİR ana sütun kullanıyoruz
    Column() {

      // 1. ROBOT GÖRSELİ
      Image(this.robotImages[this.step])
        .width('100%')
        .constraintSize({ maxHeight: 350 }) // Görselin dikeyde ekranı tamamen yutmasını engeller
        .objectFit(ImageFit.Contain)
        .animation({ duration: 500, curve: Curve.EaseInOut })
        // DEĞİŞİKLİK: Yazı ile görsel arasına sadece 10 piksellik ufak bir boşluk bıraktık
        .margin({ bottom: 10 })

      // 2. METİN
      Text(this.messages[this.step])
        .fontFamily('monospace')
        .fontSize(22)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .padding({ left: 20, right: 20 })
        .height(80) // Metin değişse de yüksekliği sabit tutar

      // 3. BUTON ALANI (Sabit Yükseklikli Kapsayıcı)
      // Buton sonradan belirdiğinde ekranın yukarı zıplamasını engellemek için Row kullanıyoruz
      Row() {
        if (this.step === 2) {
          Button('EĞİTİMLERE BAŞLA')
            .onClick(() => {
              router.pushUrl({ url: 'pages/Modules' });
            })
            .backgroundColor(Color.White)
            .fontColor('#0B132B')
            .fontFamily('monospace')
            .fontWeight(FontWeight.Bolder)
            .width('80%')
            .height(55)
            .borderRadius(0)
            .transition({ type: TransitionType.Insert, opacity: 0 })
        }
      }
      .width('100%')
      .height(70) // Buton için her zaman hazır bekleyen 70 piksellik alan
      .justifyContent(FlexAlign.Center)

    }
    .width('100%')
    .height('100%')
    // DEĞİŞİKLİK: Ana Column'a Center verdik. Artık Görsel+Metin+Buton grubu ekranın tam ortasında, birbirine yapışık duracak.
    .justifyContent(FlexAlign.Center)
    .linearGradient({
      angle: this.gradientAngle,
      colors: [
        ['#0B132B', 0.0],
        ['#1C2541', 0.5],
        ['#0B132B', 1.0]
      ]
    })
  }
}