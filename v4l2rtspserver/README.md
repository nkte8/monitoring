# 本イメージについて  

以下のプロジェクトをdockerコンテナ内でコンパイルするdockerfileです。  
https://github.com/mpromonet/v4l2rtspserver

## 使用方法
詳しいオプション等は元プロジェクトを参照すること
```
sudo docker run --rm --device /dev/video0 -p 8554:8554 -it v4l2rtspserver -H 480 -W 640 -F 30
```