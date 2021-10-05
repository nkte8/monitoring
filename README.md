# monitor について

サーバのモニタリングに関するプロダクトの学習・開発を目的としたプロジェクトです。

## streaming-serverについて  

RaspberryPiのカメラモジュールを用いた、監視カメラ・映像配信サービスです。

### サービスのセットアップ   
RaspberryPi上にk8s環境およびgitlabサーバがあること、カメラモジュールのセットアップを完了している前提としています。  

1) gitlab環境に本プロジェクトをcloneし、`gitlab-ci.yaml`によってコンテナをビルドする。  

2) すべてのyamlファイル内の`**.template.spec.containers.image`を、各々のコンテナレジストリに設定し直す。

3) カメラモジュールのあるノードに、k8s上でnodeラベル`device: camera`を付与する

4) サービスを起動する
```sh
kubectl apply -k ./monitor/manifests/streaming-server/base/
```
