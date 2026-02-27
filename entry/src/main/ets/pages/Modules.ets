import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

interface ModuleItem {
  id: string;
  title: string;
  tech: string;
  color: string;
  targetUrl: string;
}

@Entry
@Component
struct Modules {
  @State gradientAngle: number = 0;
  private scroller: Scroller = new Scroller();
  @State gpuLoad: number = 12;

  // Tüm Laboratuvarların Veritabanı
  private moduleList: ModuleItem[] = [
    { id: 'mod1', title: 'NESNE TANIMA', tech: 'Lojistik Regresyon', color: '#00FFFF', targetUrl: 'pages/ModelTraining' },
    { id: 'mod2', title: 'GÖRÜNTÜ İŞLEME', tech: 'CNN / Evrişim', color: '#00FF00', targetUrl: 'pages/ImageProcessing' },
    { id: 'mod3', title: 'BÜYÜK DİL MODELLERİ', tech: 'Softmax / LLM', color: '#FF00FF', targetUrl: 'pages/LargeLanguageModels' },
    { id: 'mod4', title: 'SİNİR AĞLARI', tech: 'İleri Besleme / Matris', color: '#FFFF00', targetUrl: 'pages/NeuralNetworks' },
    { id: 'mod5', title: 'PEKİŞTİRMELİ ÖĞRENME', tech: 'Q-Learning / Otonom', color: '#FF4500', targetUrl: 'pages/ReinforcementLearning' },
    { id: 'mod6', title: 'KARAR AĞAÇLARI', tech: 'IoT / Akıllı Bina', color: '#00FFFF', targetUrl: 'pages/DesicionTrees' },
    { id: 'mod7', title: 'ANOMALİ TESPİTİ', tech: 'Z-Score / Siber Güvenlik', color: '#00FF00', targetUrl: 'pages/AnomalyDetection' }
  ];

  aboutToAppear() {
    setInterval(() => {
      animateTo({ duration: 2000, curve: Curve.Linear }, () => {
        this.gradientAngle = (this.gradientAngle + 45) % 360;
      });
    }, 2000);
    setInterval(() => {
      let isSpike = Math.random() > 0.8; // %20 ihtimalle ani yük sıçraması
      let baseLoad = Math.floor(Math.random() * 20) + 5; // 5 ile 25 arası rastgele temel yük

      this.gpuLoad = isSpike ? baseLoad + 40 : baseLoad; // Sıçrama varsa 40 ekle
    }, 1500);
  }



  build() {
    Column() {
      // --- ÜST BİLGİ VE GERİ BUTONU ---
      Row() {
        Text('< Geri').fontFamily('monospace').fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color.White).onClick(() => { router.back(); })
        Blank()
      }.width('100%').padding(20)

      Scroll(this.scroller) {
        Column() {

          // --- 1. SİSTEM TELEMETRİSİ (DASHBOARD HEADER) ---
          Column() {
            Text('AI_CORE_KOMUTA_MERKEZİ_V1.0').fontFamily('monospace').fontSize(16).fontWeight(FontWeight.Bolder).fontColor(Color.White).margin({ bottom: 10 }).width('100%').textAlign(TextAlign.Center)

            Row() {
              Column() {
                Text('SİSTEM').fontFamily('monospace').fontSize(10).fontColor(Color.Gray)
                Text('ONLINE').fontFamily('monospace').fontSize(12).fontColor('#00FF00').fontWeight(FontWeight.Bold)
              }.layoutWeight(1)

              Column() {
                Text('GPU YÜKÜ').fontFamily('monospace').fontSize(10).fontColor(Color.Gray)
                Text(`% ${this.gpuLoad}`).fontFamily('monospace').fontSize(12).fontColor(this.gpuLoad > 50 ? Color.Red : '#00FFFF').fontWeight(FontWeight.Bold)              }.layoutWeight(1)

              Column() {
                Text('AĞ DURUMU').fontFamily('monospace').fontSize(10).fontColor(Color.Gray)
                Text('GÜVENLİ').fontFamily('monospace').fontSize(12).fontColor('#00FF00').fontWeight(FontWeight.Bold)
              }.layoutWeight(1)
            }.width('100%').padding(10).backgroundColor('#050A15').border({ width: 1, color: Color.Gray })
          }.width('95%').margin({ bottom: 25 })

          Text('AKTİF SİMÜLASYON MODÜLLERİ')
            .fontFamily('monospace').fontSize(14).fontColor(Color.Gray).width('95%').textAlign(TextAlign.Start).margin({ bottom: 15 })

          // --- 2. MODÜL KARTLARI (GRID WIDGETS) ---
          Grid() {
            ForEach(this.moduleList, (item: ModuleItem) => {
              GridItem() {
                Button() {
                  Column() {
                    // Kart İçi Süsleme / İkon Yeri
                    Row().width(15).height(15).backgroundColor(item.color).borderRadius(7.5).margin({ bottom: 10 })

                    Text(item.title)
                      .fontFamily('monospace').fontSize(12).fontWeight(FontWeight.Bolder).fontColor(Color.White).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).textAlign(TextAlign.Center).margin({ bottom: 8 })

                    Text(item.tech)
                      .fontFamily('monospace').fontSize(9).fontColor(item.color).fontWeight(FontWeight.Bold).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width('100%').height('100%').padding(10).justifyContent(FlexAlign.Center)
                }
                .backgroundColor('#1C2541')
                .border({ width: 2, color: item.color, style: BorderStyle.Solid })
                .width('100%').height(120).borderRadius(0)
                .onClick(() => {
                  if (item.targetUrl !== '') {
                    router.pushUrl({ url: item.targetUrl });
                  } else {
                    promptAction.showToast({ message: `[HATA]: Bağlantı bulunamadı.`, duration: 2000, bottom: 50 });
                  }
                })
              }
            })
          }
          .columnsTemplate('1fr 1fr') // 2 Sütunlu Grid
          .rowsGap(15).columnsGap(15)
          .width('95%').margin({ bottom: 40 })

        }.width('100%')
      }.layoutWeight(1).width('100%')
    }
    .width('100%').height('100%')
    .linearGradient({ angle: this.gradientAngle, colors: [['#0B132B', 0.0], ['#1C2541', 0.5], ['#0B132B', 1.0]] })
  }
}