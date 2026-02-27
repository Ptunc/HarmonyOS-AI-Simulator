import router from '@ohos.router';

interface FilterItem {
  id: number;
  name: string;
  fullName: string;
  image: Resource;
  kernel: number[];
  inputPixels: number[];
}

@Entry
@Component
struct ImageProcessing {
  @State gradientAngle: number = 0;
  @State selectedIndex: number = 0;

  private filters: FilterItem[] = [
    {
      id: 0,
      name: "ORİJİNAL\n(Birim)",
      fullName: "Birim Matris (Identity Kernel)",
      image: $r('app.media.drums_original'),
      kernel: [0, 0, 0, 0, 1, 0, 0, 0, 0],
      inputPixels: [50, 50, 200, 50, 200, 200, 50, 200, 200]
    },
    {
      id: 1,
      name: "BULANIK\n(Mean)",
      fullName: "Ortalama Bulanıklaştırma (Mean Box Blur)",
      image: $r('app.media.drums_blur'),
      kernel: [0.11, 0.11, 0.11, 0.11, 0.11, 0.11, 0.11, 0.11, 0.11],
      inputPixels: [50, 50, 200, 50, 200, 200, 50, 200, 200]
    },
    {
      id: 2,
      name: "KESKİN\n(Sharpen)",
      fullName: "Yüksek Geçirgenli Keskinleştirme (Sharpening Laplacian)",
      image: $r('app.media.drums_sharpen'),
      kernel: [0, -1, 0, -1, 5, -1, 0, -1, 0],
      inputPixels: [50, 50, 200, 50, 200, 200, 50, 200, 200]
    },
    {
      id: 3,
      name: "KENAR BULMA\n(Laplacian)",
      fullName: "Omni-directional Kenar Tespiti (Laplacian Operator)",
      image: $r('app.media.drums_edge'),
      kernel: [-1, -1, -1, -1, 8, -1, -1, -1, -1],
      inputPixels: [50, 50, 200, 50, 200, 200, 50, 200, 200]
    }
  ];

  aboutToAppear() {
    setInterval(() => {
      animateTo({ duration: 2000, curve: Curve.Linear }, () => {
        this.gradientAngle = (this.gradientAngle + 45) % 360;
      });
    }, 2000);
  }

  calculateOutput(): number {
    let filter = this.filters[this.selectedIndex];
    let sum = 0;
    for (let i = 0; i < 9; i++) {
      sum += filter.inputPixels[i] * filter.kernel[i];
    }
    return Math.max(0, Math.min(255, Math.round(sum)));
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          Text('< Geri').fontFamily('monospace').fontSize(18).fontColor(Color.White).fontWeight(FontWeight.Bold).onClick(() => { router.back(); })
          Blank()
        }.width('100%').padding(20)

        Text('EVRİŞİMLİ SİNİR AĞLARI (CNN)')
          .fontFamily('monospace').fontSize(20).fontWeight(FontWeight.Bolder).fontColor(Color.White).margin({ bottom: 15 })

        Column() {
          Text(this.filters[this.selectedIndex].fullName)
            .fontFamily('monospace').fontSize(12).fontColor(Color.Gray).margin({ bottom: 5, top: 5 })
          Image(this.filters[this.selectedIndex].image)
            .width('100%').height(220).objectFit(ImageFit.Cover).border({ width: 2, color: Color.White })
        }.width('95%').margin({ bottom: 20 })

        Column() {
          Text('EVRİŞİM KERNELİ SEÇİN:').fontFamily('monospace').fontColor(Color.Gray).fontSize(12).margin({ bottom: 10 }).width('100%').textAlign(TextAlign.Start)

          Grid() {
            ForEach(this.filters, (filter: FilterItem) => {
              GridItem() {
                Button() {
                  Column() {
                    Text(filter.name.split('\n')[0])
                      .fontFamily('monospace').fontSize(13).fontWeight(FontWeight.Bolder)
                      .fontColor(this.selectedIndex === filter.id ? Color.Black : Color.White)
                      .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })

                    Text(filter.name.split('\n')[1] || '')
                      .fontFamily('monospace').fontSize(10).fontWeight(FontWeight.Normal)
                      .fontColor(this.selectedIndex === filter.id ? '#212121' : Color.Gray)
                      .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width('100%').padding(5)
                }
                .backgroundColor(this.selectedIndex === filter.id ? '#00FF00' : 'transparent')
                .border({ width: 1, color: this.selectedIndex === filter.id ? '#00FF00' : Color.White })
                .width('100%').height(60).borderRadius(0)
                .onClick(() => { this.selectedIndex = filter.id; })
              }
            })
          }
          .columnsTemplate('1fr 1fr 1fr 1fr')
          .rowsGap(10).columnsGap(8)
          .width('100%')
        }.width('95%').padding(10).border({ width: 2, color: Color.Gray }).margin({ bottom: 20 })

        Column() {
          Text('PİKSEL MATEMATİĞİ SİMÜLATÖRÜ (Zil Kenarı Sample)').fontFamily('monospace').fontColor('#00FFFF').fontSize(14).fontWeight(FontWeight.Bold).margin({ bottom: 20 }).width('100%').textAlign(TextAlign.Start)

          Row() {
            Column() {
              Text('Girdi (3x3)').fontFamily('monospace').fontSize(10).fontColor(Color.Gray).margin({ bottom: 5 })
              Grid() {
                ForEach(this.filters[this.selectedIndex].inputPixels, (pixel: number) => {
                  GridItem() {
                    Text(pixel.toString())
                      .fontFamily('monospace').fontSize(12).fontWeight(FontWeight.Bold).fontColor(pixel > 128 ? Color.Black : Color.White)
                      .width('100%').height('100%').textAlign(TextAlign.Center)
                      .backgroundColor(`rgb(${pixel}, ${pixel}, ${pixel})`)
                  }
                })
              }.columnsTemplate('1fr 1fr 1fr').width(90).height(90).border({ width: 1, color: Color.Gray })
            }.layoutWeight(1)

            Text('*').fontFamily('monospace').fontSize(30).fontWeight(FontWeight.Bold).fontColor(Color.White).margin(10)

            Column() {
              Text('Kernel (3x3)').fontFamily('monospace').fontSize(10).fontColor(Color.Gray).margin({ bottom: 5 })
              Grid() {
                ForEach(this.filters[this.selectedIndex].kernel, (value: number) => {
                  GridItem() {
                    Text(value.toFixed(value < 1 ? 2 : 0))
                      .fontFamily('monospace').fontSize(12).fontWeight(FontWeight.Bold).fontColor(Color.White)
                      .width('100%').height('100%').textAlign(TextAlign.Center).border({ width: 1, color: '#1C2541' })
                  }
                })
              }.columnsTemplate('1fr 1fr 1fr').width(90).height(90).backgroundColor('#050A15').border({ width: 2, color: '#00FFFF' })
            }.layoutWeight(1)

            Text('=').fontFamily('monospace').fontSize(30).fontWeight(FontWeight.Bold).fontColor(Color.White).margin(10)

            Column() {
              Text('Sonuç').fontFamily('monospace').fontSize(10).fontColor(Color.Gray).margin({ bottom: 5 })
              // DEĞİŞEN KISIM: Fonksiyonu doğrudan özellikleri belirlerken çağırıyoruz
              Text(this.calculateOutput().toString())
                .fontFamily('monospace').fontSize(16).fontWeight(FontWeight.Bolder).fontColor(this.calculateOutput() > 128 ? Color.Black : Color.White)
                .width(60).height(60).textAlign(TextAlign.Center).borderRadius(30)
                .backgroundColor(`rgb(${this.calculateOutput()}, ${this.calculateOutput()}, ${this.calculateOutput()})`)
                .border({ width: 2, color: '#00FF00' })
            }.layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 20 })
          .justifyContent(FlexAlign.Center)

          Text('FORMÜL: Yeni_Piksel = \u2211 (Girdi_i * Kernel_i)')
            .fontFamily('monospace').fontSize(11).fontColor('#00FF00').width('100%').textAlign(TextAlign.Center).backgroundColor('#050A15').padding(8)

        }
        .width('95%').padding(15).backgroundColor('#0B132B').border({ width: 2, color: '#00FFFF', style: BorderStyle.Dashed }).margin({ bottom: 30 })

      }
      .width('100%')
    }
    .width('100%').height('100%')
    .linearGradient({ angle: this.gradientAngle, colors: [['#0B132B', 0.0], ['#1C2541', 0.5], ['#0B132B', 1.0]] })
  }
}