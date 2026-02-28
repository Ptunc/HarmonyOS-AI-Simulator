# 🧠 HarmonyOS AI & Machine Learning Simulator

Bu proje, **ArkTS** ve **ArkUI** kullanılarak geliştirilmiş, 7 farklı yapay zeka ve makine öğrenmesi modelini canlı olarak simüle eden interaktif bir mobil laboratuvar uygulamasıdır. 

Karmaşık matematiksel modelleri "kara kutu" olmaktan çıkarıp, parametrelerin (ağırlıklar, sıcaklık, epsilon vb.) sonuçları nasıl değiştirdiğini gerçek zamanlı olarak gösterir. Arayüz; gereksiz görsel karmaşadan uzak, odaklanmayı kolaylaştıran minimalist bir "Komuta Merkezi" temasıyla tasarlanmıştır.

## 🚀 Özellikler ve Simülasyon Modülleri

Uygulama, her biri farklı bir AI disiplinini temsil eden 7 ana modülden oluşur:

1. **Evrişimli Sinir Ağları (CNN):** Piksel matematiği ve kernel evrişimleriyle görüntü işleme ve kenar bulma (Edge Detection) simülasyonu.
2. **Büyük Dil Modelleri (LLM):** Softmax algoritması ve "Temperature" (Sıcaklık) hiperparametresi ile kelime tahmin olasılıklarının görselleştirilmesi.
3. **Derin Sinir Ağları (DNN):** Ağır sanayi sensörlerinden alınan verilerle, matris çarpımı (Forward Propagation) ve ReLU/Softmax aktivasyonlarının canlı hesaplanması.
4. **Pekiştirmeli Öğrenme (Q-Learning):** 4x4 bir ızgara üzerinde Bellman Denklemi kullanarak çukurlardan kaçmayı ve hedefe ulaşmayı sıfırdan öğrenen otonom ajan simülasyonu.
5. **Karar Ağaçları (Decision Trees):** Sensör verilerini (PIR, sıcaklık, tarife) kullanarak iklimlendirme sistemini yöneten akıllı bina (IoT) karar algoritması.
6. **Anomali Tespiti (Z-Score):** Ağ trafiği, gecikme ve paket kaybı verilerini kullanarak olası siber saldırıları (DDoS/Sızma) standart sapma ile tespit eden istatistiksel model.
7. **Nesne Tanıma:** Lojistik Regresyon tabanlı temel sınıflandırma modeli.

## 🛠 Mimari ve Teknolojiler

* **Dil & Çerçeve:** ArkTS, HarmonyOS, ArkUI
* **Durum Yönetimi (State Management):** Canlı UI güncellemeleri için `@State` ve `@Prop` dekoratörleri kullanılarak "Sığ Gözlem" (Shallow Observe) engelleri aşıldı.


## 📸 Ekran Görüntüleri

| Komuta Merkezi (Dashboard) | Q-Learning (Otonom Robot) | LLM (Softmax Olasılıkları) |

<img width="617" height="1226" alt="Ekran görüntüsü 2026-02-28 170309" src="https://github.com/user-attachments/assets/7144a904-77e0-4d3a-99cc-6a6aed27417b" />
<img width="620" height="1215" alt="Ekran görüntüsü 2026-02-28 170333" src="https://github.com/user-attachments/assets/c8801426-7b2d-44ad-a2f8-f711ab684177" />
<img width="596" height="1211" alt="Ekran görüntüsü 2026-02-28 170451" src="https://github.com/user-attachments/assets/791f51ad-34c5-4ab7-9285-f340f9cc415b" />
