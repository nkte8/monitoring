# monitor について

サーバのモニタリングに関するプロダクトの学習・開発を目的としたプロジェクトです。

## streaming-monitorについて  

RaspberryPiのカメラモジュールを用いた、監視カメラ・映像配信サービスです。

### サービスのセットアップ   
RaspberryPi上にk8s環境およびgitlabサーバがあること、カメラモジュールのセットアップを完了している前提としています。  

1) gitlab環境に本プロジェクトをcloneし、`gitlab-ci.yaml`によってコンテナをビルドする。  

2) エッジデバイスに`monitoring/manifests/client/docker-compose.yaml`を配布し、起動する。

3) すべてのyamlファイル内の`**.template.spec.containers.image`を、各々のコンテナレジストリに設定し直す。

4) すべてのyamlファイル内の`volumes.name:video-out`および`volumes.name:video`の設定を各自クラスタの設定に合わせる。

5) config.csvおよびrtsp2hlsマニフェストのDeploymentのレプリカ数をエッジデバイスと一致させる。

6) サービスを起動する
```sh
kubectl apply -k ./monitoring/manifests/streaming-monitor
```
