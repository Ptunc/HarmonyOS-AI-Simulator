import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

// Görsel veriler için yeni kalıp
interface VisualData {
  id: number;
  img: Resource;
  f1: number; // Arka plandaki gizli öznitelik (örneğin yansıtıcılık)
  f2: number; // Arka plandaki gizli öznitelik (örneğin hız)
  label: number; // 0 veya 1
}

interface Dataset {
  name: string;
  class0: string;
  class1: string;
  trainData: VisualData[];
  testData: VisualData[]; // Test edilecek, daha önce görülmemiş görseller
}

const datasets: Dataset[] = [
  {
    name: "Göktaşı (0) vs Uzay Çöpü (1)",
    class0: "Göktaşı",
    class1: "Uzay Çöpü",
    // EĞİTİM GÖRSELLERİ
    trainData: [
      { id: 1, img: $r('app.media.meteor1'), f1: 0.1, f2: 0.2, label: 0 },
      { id: 2, img: $r('app.media.meteor2'), f1: 0.2, f2: 0.1, label: 0 },
      { id: 3, img: $r('app.media.debris1'), f1: 0.9, f2: 0.8, label: 1 },
      { id: 4, img: $r('app.media.debris2'), f1: 0.85, f2: 0.9, label: 1 }
    ],
    // TEST GÖRSELLERİ (Modelin hiç görmediği resimler)
    testData: [
      { id: 5, img: $r('app.media.meteor_test'), f1: 0.15, f2: 0.3, label: 0 }, // Aslında göktaşı
      { id: 6, img: $r('app.media.debris_test'), f1: 0.95, f2: 0.7, label: 1 }  // Aslında uzay çöpü
    ]
  }
];

@Entry
@Component
struct ModelTraining {
  private scroller: Scroller = new Scroller();

  @State gradientAngle: number = 0;
  @State selectedDatasetIndex: number = 0;
  @State learningRate: number = 0.1;
  @State epochs: number = 50;

  @State w1: number = 0;
  @State w2: number = 0;
  @State bias: number = 0;

  @State isTraining: boolean = false;
  @State isTrained: boolean = false;
  @State terminalLogs: string[] = ["SİSTEM HAZIR. Eğitim veri setini inceleyin ve başlatın."];

  // Test seçimi için durum yönetimi
  @State selectedTestImageIndex: number = -1;
  @State predictionResult: string = "[SİSTEM HAZIR] Test edilecek görseli seçin.";

  aboutToAppear() {
    setInterval(() => {
      animateTo({ duration: 2000, curve: Curve.Linear }, () => {
        this.gradientAngle = (this.gradientAngle + 45) % 360;
      });
    }, 2000);
  }

  startTraining() {
    this.isTraining = true;
    this.isTrained = false;
    this.selectedTestImageIndex = -1;
    this.predictionResult = "[SİSTEM HAZIR] Test edilecek görseli seçin.";
    this.logToTerminal(`Eğitim başlatılıyor...`);

    this.w1 = Math.random();
    this.w2 = Math.random();
    this.bias = Math.random();

    let currentEpoch = 0;
    let data = datasets[this.selectedDatasetIndex].trainData; // Görsel veri setini alıyoruz

    let trainingInterval = setInterval(() => {
      if (currentEpoch >= this.epochs) {
        clearInterval(trainingInterval);
        this.isTraining = false;
        this.isTrained = true;
        this.logToTerminal(`[BAŞARILI] Model eğitildi. Teste hazır.`);

        setTimeout(() => { this.scroller.scrollEdge(Edge.Bottom); }, 300);
        return;
      }

      let totalError = 0;
      for (let i = 0; i < data.length; i++) {
        let x1 = data[i].f1; // Resmin arkasındaki 1. özelliği al
        let x2 = data[i].f2; // Resmin arkasındaki 2. özelliği al
        let target = data[i].label;

        let linearSum = (x1 * this.w1) + (x2 * this.w2) + this.bias;
        let prediction = 1 / (1 + Math.exp(-linearSum));

        let error = target - prediction;
        totalError += Math.abs(error);

        this.w1 += this.learningRate * error * prediction * (1 - prediction) * x1;
        this.w2 += this.learningRate * error * prediction * (1 - prediction) * x2;
        this.bias += this.learningRate * error * prediction * (1 - prediction);
      }

      currentEpoch++;
      if (currentEpoch % Math.ceil(this.epochs / 5) === 0 || currentEpoch === 1) {
        let loss = totalError / data.length;
        this.logToTerminal(`İterasyon: ${currentEpoch}/${this.epochs} | Kayıp: ${loss.toFixed(4)}`);
      }
    }, 50);
  }

  makePrediction() {
    if (this.selectedTestImageIndex === -1) {
      promptAction.showToast({ message: "Lütfen önce test edilecek bir görsel seçin!", duration: 2000 });
      return;
    }

    // Seçilen test görselinin gizli matematiksel değerlerini alıyoruz
    let testImgData = datasets[this.selectedDatasetIndex].testData[this.selectedTestImageIndex];
    let linearSum = (testImgData.f1 * this.w1) + (testImgData.f2 * this.w2) + this.bias;
    let prob = 1 / (1 + Math.exp(-linearSum));

    if (isNaN(prob)) {
      this.predictionResult = "[HATA] Ağırlıklar patladı. LR düşürün.";
      return;
    }

    let ds = datasets[this.selectedDatasetIndex];
    let resultMessage = "";

    if (prob >= 0.5) {
      resultMessage = `[SONUÇ]: ${ds.class1} (%${(prob * 100).toFixed(1)})`;
    } else {
      resultMessage = `[SONUÇ]: ${ds.class0} (%${((1 - prob) * 100).toFixed(1)})`;
    }

    this.predictionResult = resultMessage;
    promptAction.showToast({ message: resultMessage, duration: 3000, bottom: 80 });
  }

  logToTerminal(msg: string) {
    let tempLogs = [...this.terminalLogs, msg];
    if (tempLogs.length > 6) tempLogs.shift();
    this.terminalLogs = tempLogs;
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        Row() {
          Text('< Geri').fontFamily('monospace').fontSize(18).fontColor(Color.White).fontWeight(FontWeight.Bold).onClick(() => { router.back(); })
          Blank()
        }.width('100%').padding(20)

        Text('ASTRONOMİK SINIFLANDIRMA')
          .fontFamily('monospace').fontSize(20).fontWeight(FontWeight.Bolder).fontColor(Color.White).margin({ bottom: 20 })

        // --- 1. EĞİTİM VERİ SETİ GALERİSİ ---
        Column() {
          Text('EĞİTİM GÖRSELLERİ (Veri Seti)').fontFamily('monospace').fontColor(Color.Gray).fontSize(14).margin({ bottom: 10 }).width('100%').textAlign(TextAlign.Start)

          List({ space: 10 }) {
            ForEach(datasets[this.selectedDatasetIndex].trainData, (data: VisualData) => {
              ListItem() {
                Column() {
                  Image(data.img).width(80).height(80).objectFit(ImageFit.Cover).borderRadius(8)
                  Text(data.label === 0 ? datasets[this.selectedDatasetIndex].class0 : datasets[this.selectedDatasetIndex].class1)
                    .fontFamily('monospace').fontSize(10).fontColor(Color.White).margin({ top: 5 })
                }
              }
            })
          }
          .listDirection(Axis.Horizontal) // Resimleri yan yana dizer
          .width('100%').height(110)
        }
        .width('90%').padding(15).border({ width: 2, color: Color.White }).margin({ bottom: 20 })

        // --- 2. HİPERPARAMETRELER VE EĞİTİM BUTONU ---
        Column() {
          Text(`İTERASYON (EPOCH): ${this.epochs}`).fontFamily('monospace').fontColor(Color.White).fontSize(14)
          Slider({ value: this.epochs, min: 10, max: 200, step: 10, style: SliderStyle.OutSet }).blockColor(Color.White).trackColor('#1C2541').selectedColor(Color.White).width('100%').onChange((val) => { if (!this.isTraining) this.epochs = val; })

          Text(`ÖĞRENME ORANI (LR): ${this.learningRate.toFixed(2)}`).fontFamily('monospace').fontColor(Color.White).fontSize(14).margin({ top: 10 })
          Slider({ value: this.learningRate, min: 0.01, max: 0.5, step: 0.01, style: SliderStyle.OutSet }).blockColor(Color.White).trackColor('#1C2541').selectedColor(Color.White).width('100%').onChange((val) => { if (!this.isTraining) this.learningRate = val; }).margin({ bottom: 20 })

          Button(this.isTraining ? 'AĞ EĞİTİLİYOR...' : 'AĞI EĞİT')
            .backgroundColor(this.isTraining ? Color.Gray : '#00FF00').fontColor(Color.Black).fontFamily('monospace').fontWeight(FontWeight.Bold).width('100%').height(50).borderRadius(0)
            .onClick(() => { if (!this.isTraining) this.startTraining(); })
        }
        .width('90%').padding(15).border({ width: 2, color: Color.White }).margin({ bottom: 20 })

        // --- 3. CANLI TERMİNAL ---
        Column() {
          List({ space: 5 }) {
            ForEach(this.terminalLogs, (log: string) => {
              ListItem() { Text(`> ${log}`).fontFamily('monospace').fontSize(12).fontColor(Color.White) }
            })
          }.width('100%').height(100)
          Divider().color(Color.Gray).margin({ top: 10, bottom: 10 })
          Text(`w1: ${this.w1.toFixed(3)} | w2: ${this.w2.toFixed(3)} | bias: ${this.bias.toFixed(3)}`).fontFamily('monospace').fontSize(12).fontColor('#00FFFF')
        }
        .width('90%').backgroundColor('#050A15').border({ width: 2, color: Color.Gray }).padding(10).margin({ bottom: 20 })

        // --- 4. GÖRSEL TEST PANELİ ---
        if (this.isTrained) {
          Column() {
            Text('MODELİ TEST ET').fontFamily('monospace').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#00FF00').margin({ bottom: 15 })
            Text('Aşağıdan test edilecek bir görsel seçin:').fontFamily('monospace').fontColor(Color.Gray).fontSize(12).margin({ bottom: 10 })

            // Test görselleri galerisi
            List({ space: 15 }) {
              ForEach(datasets[this.selectedDatasetIndex].testData, (data: VisualData, index: number) => {
                ListItem() {
                  Image(data.img)
                    .width(90).height(90).objectFit(ImageFit.Cover).borderRadius(8)
                  // Seçili olan resme kalın yeşil bir çerçeve ekliyoruz
                    .border({ width: this.selectedTestImageIndex === index ? 4 : 0, color: '#00FF00' })
                    .onClick(() => {
                      this.selectedTestImageIndex = index;
                      this.predictionResult = "[SİSTEM HAZIR] Tahmin bekleniyor...";
                    })
                }
              })
            }
            .listDirection(Axis.Horizontal)
            .width('100%').height(100).margin({ bottom: 20 })

            Button('SEÇİLİ GÖRSELİ TAHMİN ET')
              .backgroundColor(this.selectedTestImageIndex === -1 ? Color.Gray : '#00FFFF').fontColor(Color.Black).fontFamily('monospace').fontWeight(FontWeight.Bold).width('100%').height(50).borderRadius(0)
              .onClick(() => { this.makePrediction(); })

            Text(this.predictionResult)
              .fontFamily('monospace').fontSize(14).fontWeight(FontWeight.Bold).fontColor(Color.Black)
              .backgroundColor(this.predictionResult.includes('HAZIR') ? Color.White : (this.predictionResult.includes('HATA') ? Color.Red : '#00FF00'))
              .padding(10).margin({ top: 15 }).width('100%').textAlign(TextAlign.Center)
          }
          .width('90%').padding(15).border({ width: 2, color: '#00FF00', style: BorderStyle.Dashed }).margin({ bottom: 40 })
        }

      }
      .width('100%')
    }
    .width('100%').height('100%')
    .linearGradient({ angle: this.gradientAngle, colors: [['#0B132B', 0.0], ['#1C2541', 0.5], ['#0B132B', 1.0]] })
  }
}