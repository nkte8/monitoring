# streaming-monitor  
## 設定方法  
```sh
git clone <リポジトリURL>
# <マニフェスト内のイメージの参照先・NFS設定等を修正>
# <config.csvを配置>
kubectl apply -k ./monitoring/manifests/streaming-monitor
```
## config.csvについて  
次のように設定
```csv
<デバイス名(DNS名)>,<各セグメントの動画時間>,<映像の回転設定>,<IPアドレス・オプション>
```
映像の回転設定は以下のいずれかを指定すること  
- Rotate_0  
    - 時計回り 0度（そのままの映像）
- Rotate_90  
    - 時計回り 90度  
- Rotate_180  
    - 時計回り 180度  
- Rotate_270  
    - 時計回り 270度  

### 設定例  
```csv
edge01,5,Rotate_0,192.168.3.31
192.168.3.32,10,Rotate_180
```  
