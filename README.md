# dev_fin

## 開発環境

MariaDB / Valkey / Python(FastAPI + scikit-learn) を Docker Compose で構築。

```bash
cp .env.example .env  # 初回のみ (値は必要に応じて変更)
docker compose up -d --build
```

- API: http://localhost:8000 (ヘルスチェック: `/health`)
- `app/src` を編集すると即座にリロードされる (uvicorn --reload)
- MariaDB / Valkey のデータは named volume (`mariadb_data`, `valkey_data`) で永続化

停止: `docker compose down` (データを消す場合は `-v` を追加)

## Kubernetes (kind) 環境

ローカル kind クラスタに同じ構成 (mariadb / valkey / api) をデプロイできる。
compose.yaml とは別ポート (8080) を使うため併用可能。

```bash
brew install kind        # 初回のみ
./scripts/k8s-up.sh      # クラスタ作成 + イメージビルド + デプロイ
```

- API: http://localhost:8080 (ヘルスチェック: `/health`)
- `app/src` は kind ノードに hostPath マウントされ、編集は即座に反映される (uvicorn --reload)
- MariaDB / Valkey のデータは PVC (`mariadb-data`, `valkey-data`) で永続化
- 環境変数/パスワードは `.env` から Secret `app-env` として同期される

コード変更後にイメージの再ビルドが必要な場合 (依存追加時など) は `./scripts/k8s-up.sh` を再実行する。

停止:
```bash
./scripts/k8s-down.sh                 # namespace のみ削除 (クラスタは残す)
./scripts/k8s-down.sh --delete-cluster  # クラスタごと削除
```



## task
- clone データ取得のジョブ追加
- 必要最低限の予測API
- marimo開発環境の構築
- valkeyはsession管理用
- APIの認証関連どうする？
