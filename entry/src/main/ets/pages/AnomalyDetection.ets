import router from '@ohos.router';

@Entry
@Component
struct AnomalyDetection {
  @State gradientAngle: number = 0;
  private scroller: Scroller = new Scroller();

  // Ağ Trafiği Sensör Verileri (Girdiler)
  @State latency: number = 20; // Gecikme (ms)
  @State packetLoss: number = 0; // Paket Kaybı (%)
  @State trafficSize: number = 50; // Trafik Hacmi (MB/s)

  // Normal Kabul Edilen Değerler (Geçmiş Ortalama)
  private normalLatency: number = 20;
  private normalTraffic: number = 50;

  aboutToAppear() {
    setInterval(() => {
      animateTo({ duration: 2000, curve: Curve.Linear }, () => {
        this.gradientAngle = (this.gradientAngle + 45) % 360;
      });
    }, 2000);
  }

  // Anomali Skorunu Hesaplama (0 - 100 arası risk yüzdesi)
  getAnomalyScore(): number {
    // Sapmaları normalize ediyoruz
    let latencyDeviation = Math.max(0, this.latency - this.normalLatency) / 480;
    let packetLossDeviation = this.packetLoss / 20;
    let trafficDeviation = Math.max(0, this.trafficSize - this.normalTraffic) / 950;

    // Ağırlıklı risk toplamı (Paket kaybı ve olağanüstü trafik en riskli olanlardır)
    let totalScore = (latencyDeviation * 0.3 + packetLossDeviation * 0.4 + trafficDeviation * 0.3) * 100;

    return Math.max(0, Math.min(100, totalScore));
  }

  // Tehdit Durumu Metni
  getStatusText(): string {
    let score = this.getAnomalyScore();
    if (score > 70) return "KRİTİK ANOMALİ (Olası DDoS/Sızma)";
    if (score > 40) return "ŞÜPHELİ TRAFİK (İzleniyor)";
    return "NORMAL (Ağ Güvenli)";
  }

  // Durum Rengi
  getStatusColor(): ResourceColor {
    let score = this.getAnomalyScore();
    if (score > 70) return '#FF0000'; // Kırmızı
    if (score > 40) return '#FFA500'; // Turuncu
    return '#00FF00'; // Yeşil
  }

  build() {
    Column() {
      Scroll(this.scroller) {
        Column() {
          // --- ÜST BİLGİ ---
          Row() {
            Text('< Geri').fontFamily('monospace').fontSize(18).fontColor(Color.White).fontWeight(FontWeight.Bold).onClick(() => { router.back(); })
            Blank()
          }.width('100%').padding(20)

          Text('ANOMALİ TESPİTİ (SİBER GÜVENLİK)')
            .fontFamily('monospace').fontSize(18).fontWeight(FontWeight.Bolder).fontColor(Color.White).margin({ bottom: 15 }).textAlign(TextAlign.Center)

          // --- 1. AĞ METRİKLERİ KONTROLÜ ---
          Column() {
            Text('CANLI AĞ TRAFİĞİ GİRDİLERİ').fontFamily('monospace').fontColor('#00FFFF').fontSize(14).fontWeight(FontWeight.Bold).margin({ bottom: 15 }).width('100%').textAlign(TextAlign.Start)

            Text(`Gecikme (Ping): ${this.latency.toFixed(0)} ms`).fontColor(Color.White).fontSize(12)
            Slider({ value: this.latency, min: 10, max: 500, step: 10, style: SliderStyle.OutSet }).blockColor('#00FFFF').onChange((v) => { this.latency = v; })

            Text(`Paket Kaybı: %${this.packetLoss.toFixed(1)}`).fontColor(Color.White).fontSize(12).margin({ top: 10 })
            Slider({ value: this.packetLoss, min: 0, max: 20, step: 0.5, style: SliderStyle.OutSet }).blockColor('#00FFFF').onChange((v) => { this.packetLoss = v; })

            Text(`Trafik Hacmi: ${this.trafficSize.toFixed(0)} MB/s`).fontColor(Color.White).fontSize(12).margin({ top: 10 })
            Slider({ value: this.trafficSize, min: 10, max: 1000, step: 10, style: SliderStyle.OutSet }).blockColor('#00FFFF').onChange((v) => { this.trafficSize = v; })
          }.width('95%').padding(15).border({ width: 2, color: '#00FFFF' }).margin({ bottom: 20 })

          // --- 2. GÖRSEL RİSK ANALİZİ (BAR CHART) ---
          Column() {
            Text('İSTATİSTİKSEL SAPMA (Z-SCORE ANALİZİ)').fontFamily('monospace').fontColor('#00FF00').fontSize(14).fontWeight(FontWeight.Bold).margin({ bottom: 20 }).width('100%').textAlign(TextAlign.Start)

            // Risk Barı
            Stack({ alignContent: Alignment.Start }) {
              Row().width('100%').height(30).backgroundColor('#1C2541').border({ width: 1, color: Color.Gray })

              Row()
                .width(`${this.getAnomalyScore()}%`)
                .height(30)
                .backgroundColor(this.getStatusColor())
                .animation({ duration: 300, curve: Curve.EaseOut })
            }.width('100%').margin({ bottom: 10 })

            Row() {
              Text('0%').fontFamily('monospace').fontSize(10).fontColor(Color.Gray)
              Blank()
              Text(`Anomali Skoru: %${this.getAnomalyScore().toFixed(1)}`).fontFamily('monospace').fontSize(12).fontColor(Color.White).fontWeight(FontWeight.Bold)
              Blank()
              Text('100%').fontFamily('monospace').fontSize(10).fontColor(Color.Gray)
            }.width('100%')

          }.width('95%').padding(15).backgroundColor('#050A15').border({ width: 2, color: '#00FF00', style: BorderStyle.Dashed }).margin({ bottom: 20 })

          // --- 3. NİHAİ SİSTEM KARARI ---
          Column() {
            Text('GÜVENLİK DUVARI DURUMU (WAF)').fontFamily('monospace').fontColor('#FF00FF').fontSize(12).fontWeight(FontWeight.Bold).margin({ bottom: 10 }).width('100%').textAlign(TextAlign.Start)

            Text(this.getStatusText())
              .fontFamily('monospace').fontSize(16).fontWeight(FontWeight.Bolder).fontColor(Color.Black)
              .width('100%').textAlign(TextAlign.Center).backgroundColor(this.getStatusColor()).padding(20)
              .animation({ duration: 300, curve: Curve.EaseOut })

            Text('Matematik: Z = (X - \u03BC) / \u03C3')
              .fontFamily('monospace').fontSize(10).fontColor(Color.Gray).width('100%').textAlign(TextAlign.Center).margin({ top: 15 })
          }.width('95%').margin({ bottom: 40 })

        }.width('100%')
      }.layoutWeight(1).width('100%')
    }
    .width('100%').height('100%')
    .linearGradient({ angle: this.gradientAngle, colors: [['#0B132B', 0.0], ['#1C2541', 0.5], ['#0B132B', 1.0]] })
  }
}