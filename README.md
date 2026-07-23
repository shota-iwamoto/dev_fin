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



## task
- clone データ取得のジョブ追加
- 必要最低限の予測API
- marimo開発環境の構築
- valkeyはsession管理用
- APIの認証関連どうする？
