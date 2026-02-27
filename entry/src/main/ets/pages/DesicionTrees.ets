import router from '@ohos.router';

// 1. ÇÖZÜM: Karar Ağacı Kutularını bağımsız birer akıllı bileşene dönüştürdük
@Component
struct TreeNode {
  @Prop label: string;
  @Prop isActive: boolean;
  @Prop isResult: boolean = false;

  build() {
    Text(this.label)
      .fontFamily('monospace').fontSize(9).fontWeight(FontWeight.Bold)
      .fontColor(this.isActive ? Color.Black : Color.White)
      // Aktifse Yeşil/Pembe, Pasifse Lacivert
      .backgroundColor(this.isActive ? (this.isResult ? '#FF00FF' : '#00FF00') : '#1C2541')
      .padding(5).textAlign(TextAlign.Center).border({ width: 1, color: Color.White })
      .width('100%').constraintSize({ minHeight: 40 })
  }
}

// 2. ÇÖZÜM: Bağlantı çizgilerini de bağımsız bileşen yaptık
@Component
struct TreeLine {
  build() {
    Text("│\n▼")
      .fontFamily('monospace').fontSize(10).fontColor(Color.Gray).textAlign(TextAlign.Center).width('100%').margin({ top: 2, bottom: 2 })
  }
}

@Entry
@Component
struct DecisionTrees {
  @State gradientAngle: number = 0;
  private scroller: Scroller = new Scroller();

  @State occupancy: boolean = true;
  @State indoorTemp: number = 26;
  @State outdoorTemp: number = 22;
  @State isCheapTariff: boolean = false;

  aboutToAppear() {
    setInterval(() => {
      animateTo({ duration: 2000, curve: Curve.Linear }, () => {
        this.gradientAngle = (this.gradientAngle + 45) % 360;
      });
    }, 2000);
  }

  isStepActive(stepId: string): boolean {
    if (stepId === 'root') return true;

    if (stepId === 'occ_no') return !this.occupancy;
    if (stepId === 'occ_yes') return this.occupancy;

    if (!this.occupancy) return false;

    let isHot = this.indoorTemp > 24;
    let isCold = this.indoorTemp < 20;
    let isIdeal = !isHot && !isCold;

    if (stepId === 'hot') return isHot;
    if (stepId === 'cold') return isCold;
    if (stepId === 'ideal') return isIdeal;

    if (isHot) {
      if (stepId === 'natural_cool') return this.outdoorTemp < this.indoorTemp;
      if (stepId === 'ac_cool') return this.outdoorTemp >= this.indoorTemp;
    }

    if (isCold) {
      if (stepId === 'active_heat') return this.isCheapTariff;
      if (stepId === 'eco_heat') return !this.isCheapTariff;
    }

    return false;
  }

  getFinalDecision(): string {
    if (!this.occupancy) return "SİSTEM STANDBY (Oda Boş)";
    if (this.indoorTemp > 24) {
      return this.outdoorTemp < this.indoorTemp ? "DOĞAL HAVALANDIRMA AÇIK" : "KLİMA (SOĞUTMA) AKTİF";
    }
    if (this.indoorTemp < 20) {
      return this.isCheapTariff ? "AKTİF ISITMA (Tam Güç)" : "ECO ISITMA (Tasarruf Modu)";
    }
    return "OPTİMUM KONFOR (Sistem Beklemede)";
  }

  getDecisionColor(): string {
    let decision = this.getFinalDecision();
    if (decision.includes('STANDBY')) return Color.Gray.toString();
    if (decision.includes('SOĞUTMA') || decision.includes('HAVALANDIRMA')) return '#00FFFF';
    if (decision.includes('ISITMA')) return '#FF4500';
    return '#00FF00';
  }

  build() {
    Column() {
      Scroll(this.scroller) {
        Column() {
          Row() {
            Text('< Geri').fontFamily('monospace').fontSize(18).fontColor(Color.White).fontWeight(FontWeight.Bold).onClick(() => { router.back(); })
            Blank()
          }.width('100%').padding(20)

          Text('AKILLI BİNA OTOMASYONU (IoT)')
            .fontFamily('monospace').fontSize(20).fontWeight(FontWeight.Bolder).fontColor(Color.White).margin({ bottom: 15 })

          Column() {
            Text('SENSÖR GİRDİLERİ (X Vektörü)').fontFamily('monospace').fontColor('#00FFFF').fontSize(14).fontWeight(FontWeight.Bold).margin({ bottom: 15 }).width('100%').textAlign(TextAlign.Start)

            Row() {
              Text(`Hareket Sensörü (Oda Dolu): ${this.occupancy ? 'EVET' : 'HAYIR'}`).fontColor(Color.White).fontSize(12).layoutWeight(1)
              Toggle({ type: ToggleType.Switch, isOn: this.occupancy }).selectedColor('#00FF00').onChange((isOn: boolean) => { this.occupancy = isOn; })
            }.width('100%').margin({ bottom: 10 })

            Row() {
              Text(`Elektrik Tarifesi (Ucuz/Gece): ${this.isCheapTariff ? 'EVET' : 'HAYIR'}`).fontColor(Color.White).fontSize(12).layoutWeight(1)
              Toggle({ type: ToggleType.Switch, isOn: this.isCheapTariff }).selectedColor('#00FF00').onChange((isOn: boolean) => { this.isCheapTariff = isOn; })
            }.width('100%').margin({ bottom: 15 })

            Text(`İç Ortam Sıcaklığı: ${this.indoorTemp.toFixed(1)} °C`).fontColor(Color.White).fontSize(12)
            Slider({ value: this.indoorTemp, min: 10, max: 35, step: 0.5, style: SliderStyle.OutSet }).blockColor('#00FFFF').onChange((v) => { this.indoorTemp = v; })

            Text(`Dış Ortam Sıcaklığı: ${this.outdoorTemp.toFixed(1)} °C`).fontColor(Color.White).fontSize(12).margin({ top: 10 })
            Slider({ value: this.outdoorTemp, min: -5, max: 40, step: 0.5, style: SliderStyle.OutSet }).blockColor('#00FFFF').onChange((v) => { this.outdoorTemp = v; })
          }.width('95%').padding(15).border({ width: 2, color: '#00FFFF' }).margin({ bottom: 20 })

          // 3. ÇÖZÜM: Yeni ve Reaktif Ağaç Mimarisi
          Column() {
            Text('MANTIKSAL KARAR AKIŞI').fontFamily('monospace').fontColor('#00FF00').fontSize(14).fontWeight(FontWeight.Bold).margin({ bottom: 20 }).width('100%').textAlign(TextAlign.Start)

            TreeNode({ label: "Odada Biri Var mı?", isActive: this.isStepActive('root') })
            TreeLine()

            Row() {
              Column() {
                TreeNode({ label: "HAYIR", isActive: this.isStepActive('occ_no') })
                TreeLine()
                TreeNode({ label: "STANDBY\n(Sistem Kapalı)", isActive: this.isStepActive('occ_no'), isResult: true })
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)

              Column() {
                TreeNode({ label: "EVET (İç Sıcaklık?)", isActive: this.isStepActive('occ_yes') })
                TreeLine()

                Row() {
                  Column() {
                    TreeNode({ label: "< 20°C\n(Isıtma)", isActive: this.isStepActive('cold') })
                    TreeLine()
                    TreeNode({ label: "Tarife Ucuz mu?", isActive: this.isStepActive('cold') })
                    Row() {
                      Column(){ TreeLine(); TreeNode({ label: "EVET\nAktif Isıtma", isActive: this.isStepActive('active_heat'), isResult: true }) }.layoutWeight(1).padding(2)
                      Column(){ TreeLine(); TreeNode({ label: "HAYIR\nECO Isıtma", isActive: this.isStepActive('eco_heat'), isResult: true }) }.layoutWeight(1).padding(2)
                    }
                  }.layoutWeight(1).alignItems(HorizontalAlign.Center)

                  Column() {
                    TreeNode({ label: "20-24°C\n(İdeal)", isActive: this.isStepActive('ideal') })
                    TreeLine()
                    TreeNode({ label: "Optimum\nKonfor", isActive: this.isStepActive('ideal'), isResult: true })
                  }.layoutWeight(0.8).alignItems(HorizontalAlign.Center)

                  Column() {
                    TreeNode({ label: "> 24°C\n(Soğutma)", isActive: this.isStepActive('hot') })
                    TreeLine()
                    TreeNode({ label: "Dışarısı Serin mi?", isActive: this.isStepActive('hot') })
                    Row() {
                      Column(){ TreeLine(); TreeNode({ label: "EVET\nDoğal Hava.", isActive: this.isStepActive('natural_cool'), isResult: true }) }.layoutWeight(1).padding(2)
                      Column(){ TreeLine(); TreeNode({ label: "HAYIR\nKlima Aç", isActive: this.isStepActive('ac_cool'), isResult: true }) }.layoutWeight(1).padding(2)
                    }
                  }.layoutWeight(1).alignItems(HorizontalAlign.Center)

                }.width('100%').alignItems(VerticalAlign.Top)

              }.layoutWeight(2.5).alignItems(HorizontalAlign.Center)
            }.width('100%').alignItems(VerticalAlign.Top)

          }.width('95%').padding(15).backgroundColor('#050A15').border({ width: 2, color: '#00FF00', style: BorderStyle.Dashed }).margin({ bottom: 20 })

          Column() {
            Text('HVAC (İKLİMLENDİRME) KOMUTU').fontFamily('monospace').fontColor('#FF00FF').fontSize(12).fontWeight(FontWeight.Bold).margin({ bottom: 10 }).width('100%').textAlign(TextAlign.Start)

            Text(this.getFinalDecision())
              .fontFamily('monospace').fontSize(16).fontWeight(FontWeight.Bolder).fontColor(Color.Black)
              .width('100%').textAlign(TextAlign.Center).backgroundColor(this.getDecisionColor()).padding(20)
          }.width('95%').margin({ bottom: 40 })

        }.width('100%')
      }.layoutWeight(1).width('100%')
    }
    .width('100%').height('100%').linearGradient({ angle: this.gradientAngle, colors: [['#0B132B', 0.0], ['#1C2541', 0.5], ['#0B132B', 1.0]] })
  }
}