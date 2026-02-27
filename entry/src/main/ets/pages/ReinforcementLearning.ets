import router from '@ohos.router';

// 1. KURAL: Dönüş tipleri için interface tanımlıyoruz
interface StepResult {
  nextState: number;
  reward: number;
  done: boolean;
}

@Entry
@Component
struct ReinforcementLearning {
  @State gradientAngle: number = 0;
  private scroller: Scroller = new Scroller();

  @State epsilon: number = 1.0;
  private learningRate: number = 0.1;
  private discountFactor: number = 0.9;

  @State isTraining: boolean = false;
  @State episode: number = 0;
  @State robotIndex: number = 0;
  @State lastActionText: string = "Bekleniyor...";

  // 2. KURAL: Tip uyumsuzluğunu gidermek için ResourceColor kullanıyoruz
  @State statusColor: ResourceColor = Color.White;

  private goalIndex: number = 15;
  private pitIndices: number[] = [5, 10];

  private qTable: number[][] = [
    [0,0,0,0], [0,0,0,0], [0,0,0,0], [0,0,0,0],
    [0,0,0,0], [0,0,0,0], [0,0,0,0], [0,0,0,0],
    [0,0,0,0], [0,0,0,0], [0,0,0,0], [0,0,0,0],
    [0,0,0,0], [0,0,0,0], [0,0,0,0], [0,0,0,0]
  ];
  private trainingInterval: number = -1;

  aboutToAppear() {
    setInterval(() => {
      animateTo({ duration: 2000, curve: Curve.Linear }, () => {
        this.gradientAngle = (this.gradientAngle + 45) % 360;
      });
    }, 2000);
  }

  getValidActions(state: number): number[] {
    let actions: number[] = [];
    if (state > 3) actions.push(0);
    if (state % 4 !== 3) actions.push(1);
    if (state < 12) actions.push(2);
    if (state % 4 !== 0) actions.push(3);
    return actions;
  }

  chooseAction(state: number): number {
    let validActions = this.getValidActions(state);

    if (Math.random() < this.epsilon) {
      return validActions[Math.floor(Math.random() * validActions.length)];
    }
    else {
      let bestAction = validActions[0];
      let maxQ = this.qTable[state][bestAction];
      for (let i = 0; i < validActions.length; i++) {
        let a = validActions[i];
        if (this.qTable[state][a] > maxQ) {
          maxQ = this.qTable[state][a];
          bestAction = a;
        }
      }
      return bestAction;
    }
  }

  // 3. KURAL: Interface kullanarak dönüş yapıyoruz
  takeStep(state: number, action: number): StepResult {
    let nextState = state;
    if (action === 0) nextState -= 4;
    else if (action === 1) nextState += 1;
    else if (action === 2) nextState += 4;
    else if (action === 3) nextState -= 1;

    if (nextState === this.goalIndex) {
      return { nextState: nextState, reward: 10, done: true };
    } else if (this.pitIndices.includes(nextState)) {
      return { nextState: nextState, reward: -10, done: true };
    } else {
      return { nextState: nextState, reward: -0.1, done: false };
    }
  }

  toggleTraining() {
    if (this.isTraining) {
      clearInterval(this.trainingInterval);
      this.isTraining = false;
      return;
    }

    this.isTraining = true;

    this.trainingInterval = setInterval(() => {
      let state = this.robotIndex;
      let action = this.chooseAction(state);
      let stepResult = this.takeStep(state, action);

      let nextState = stepResult.nextState;
      let reward = stepResult.reward;
      let done = stepResult.done;

      let currentQ = this.qTable[state][action];
      let maxNextQ = Math.max(...this.qTable[nextState]);

      this.qTable[state][action] = currentQ + this.learningRate * (reward + this.discountFactor * maxNextQ - currentQ);

      this.robotIndex = nextState;
      let actionNames = ["YUKARI", "SAĞ", "AŞAĞI", "SOL"];
      this.lastActionText = `Hamle: ${actionNames[action]} | Ödül: ${reward}`;

      if (done) {
        this.episode++;
        if (this.epsilon > 0.05) {
          this.epsilon *= 0.98;
        }

        if (reward > 0) {
          this.statusColor = '#00FF00';
          this.lastActionText = "HEDEFE ULAŞTI! (+10)";
        } else {
          this.statusColor = '#FF0000';
          this.lastActionText = "TUZAĞA DÜŞTÜ! (-10)";
        }

        setTimeout(() => {
          this.robotIndex = 0;
          this.statusColor = Color.White;
        }, 300);
      }
    }, 100);
  }

  getCellColor(index: number): string {
    if (index === this.goalIndex) return '#00FF00';
    if (this.pitIndices.includes(index)) return '#FF0000';
    return '#1C2541';
  }

  build() {
    Column() {
      Scroll(this.scroller) {
        Column() {
          Row() {
            Text('< Geri').fontFamily('monospace').fontSize(18).fontColor(Color.White).fontWeight(FontWeight.Bold)
              .onClick(() => {
                clearInterval(this.trainingInterval);
                router.back();
              })
            Blank()
          }.width('100%').padding(20)

          Text('PEKİŞTİRMELİ ÖĞRENME (Q-LEARNING)')
            .fontFamily('monospace').fontSize(18).fontWeight(FontWeight.Bolder).fontColor(Color.White).margin({ bottom: 15 }).textAlign(TextAlign.Center)

          Column() {
            Text('OTONOM NAVİGASYON (4x4)').fontFamily('monospace').fontColor('#00FFFF').fontSize(14).fontWeight(FontWeight.Bold).margin({ bottom: 15 }).width('100%').textAlign(TextAlign.Start)

            // 4. KURAL: Grid içinde sayıları dönerken ForEach'i güvenli kullanıyoruz
            Grid() {
              ForEach([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15], (index: number) => {
                GridItem() {
                  Stack() {
                    Row().width('100%').height('100%').backgroundColor(this.getCellColor(index)).border({ width: 1, color: '#0B132B' })

                    if (this.robotIndex === index) {
                      Circle({ width: 30, height: 30 }).fill('#00FFFF').shadow({ radius: 10, color: '#00FFFF' })
                    }
                  }.width('100%').height('100%')
                }.aspectRatio(1)
              })
            }.columnsTemplate('1fr 1fr 1fr 1fr').width('90%').height(300).border({ width: 4, color: Color.Gray })

            Text(this.lastActionText)
              .fontFamily('monospace').fontSize(14).fontWeight(FontWeight.Bold).fontColor(this.statusColor)
              .margin({ top: 15, bottom: 5 })

          }.width('95%').padding(15).backgroundColor('#050A15').border({ width: 2, color: '#00FFFF' }).margin({ bottom: 20 })

          Column() {
            Row() {
              Column() {
                Text('EPİSODE (Deneme)').fontFamily('monospace').fontSize(12).fontColor(Color.Gray)
                Text(this.episode.toString()).fontFamily('monospace').fontSize(24).fontColor(Color.White).fontWeight(FontWeight.Bold)
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)

              Column() {
                Text('EPSILON (Keşif Oranı)').fontFamily('monospace').fontSize(12).fontColor(Color.Gray)
                Text(`% ${(this.epsilon * 100).toFixed(1)}`).fontFamily('monospace').fontSize(24).fontColor('#FF00FF').fontWeight(FontWeight.Bold)
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)
            }.width('100%').margin({ bottom: 20 })

            Button(this.isTraining ? 'EĞİTİMİ DURDUR' : 'OTONOM EĞİTİMİ BAŞLAT')
              .backgroundColor(this.isTraining ? '#FF0000' : '#00FF00')
              .fontColor(Color.Black).fontFamily('monospace').fontWeight(FontWeight.Bolder)
              .width('100%').height(60).borderRadius(0)
              .onClick(() => { this.toggleTraining(); })

          }.width('95%').padding(15).border({ width: 2, color: Color.Gray }).margin({ bottom: 20 })

          Column() {
            Text('Q-ÖĞRENME (BELLMAN DENKLEMİ)').fontFamily('monospace').fontColor('#FF00FF').fontSize(12).fontWeight(FontWeight.Bold).margin({ bottom: 10 }).width('100%').textAlign(TextAlign.Start)

            Text('Q(s, a) \u2190 Q(s, a) + \u03B1 [R + \u03B3 max Q(s\', a\') - Q(s, a)]')
              .fontFamily('monospace').fontSize(11).fontColor('#00FFFF').width('100%').textAlign(TextAlign.Center).backgroundColor('#1C2541').padding(10).margin({ bottom: 10 })

            Text('Robot hata yaptıkça Q-tablosu güncellenir. Keşif oranı düştükçe rastgeleliği bırakır.')
              .fontFamily('monospace').fontSize(10).fontColor(Color.Gray).width('100%').textAlign(TextAlign.Center)
          }.width('95%').padding(15).border({ width: 1, color: Color.Gray }).margin({ bottom: 40 })

        }.width('100%')
      }.layoutWeight(1).width('100%')
    }
    .width('100%').height('100%')
    .linearGradient({ angle: this.gradientAngle, colors: [['#0B132B', 0.0], ['#1C2541', 0.5], ['#0B132B', 1.0]] })
  }
}