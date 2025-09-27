# Proxmox監視システム構築ガイド

## システム概要

### 構成
- **監視基盤**: Prometheus + Grafana (LXCコンテナ)
- **監視対象**: Proxmox母艦、開発サーバー、ブログサーバー
- **メトリクス収集**: Node Exporter

### ネットワーク構成
```
192.168.3.100 - Proxmox母艦 (proxmox-home)
192.168.3.13  - 開発サーバー (dev-server)
192.168.3.14  - ブログサーバー (blog-server)
192.168.3.xxx - Prometheusコンテナ (動的IP/DHCP)
```

## 1. LXCコンテナ作成

### コンテナ仕様
```
CT ID: 104
名前: prometheus-server
テンプレート: Ubuntu 22.04 LTS
CPU: 2コア
メモリ: 4GB
ディスク: 30GB
ネットワーク: vmbr0 (DHCP)
特権: 非特権 (unprivileged)
```

### 基本セットアップ
```bash
# システム更新
apt update && apt upgrade -y

# 必要パッケージインストール
apt install -y curl wget git vim nano htop

# Docker インストール
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Docker Compose インストール
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

## 2. Prometheus + Grafana 構築

### ディレクトリ構造
```
/opt/monitoring/
├── docker-compose.yml
├── prometheus/
│   └── prometheus.yml
└── grafana/
    └── provisioning/
        └── datasources/
            └── prometheus.yml
```

### Docker Compose設定
```yaml
# /opt/monitoring/docker-compose.yml
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus:/etc/prometheus
      - prometheus_data:/prometheus
    command:
      - --config.file=/etc/prometheus/prometheus.yml
      - --storage.tsdb.path=/prometheus
      - --storage.tsdb.retention.time=30d
      - --web.console.libraries=/usr/share/prometheus/console_libraries
      - --web.console.templates=/usr/share/prometheus/consoles
      - --web.enable-lifecycle
    user: "65534:65534"

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
      - GF_INSTALL_PLUGINS=grafana-piechart-panel
      - GF_USERS_ALLOW_SIGN_UP=false

volumes:
  prometheus_data:
  grafana_data:
```

### Prometheus設定
```yaml
# /opt/monitoring/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  # Self monitoring
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Proxmox母艦
  - job_name: 'proxmox-host'
    static_configs:
      - targets: ['192.168.3.100:9100']
    scrape_interval: 30s

  # 開発サーバー  
  - job_name: 'dev-server'
    static_configs:
      - targets: ['192.168.3.13:9100']
    scrape_interval: 30s

  # ブログサーバー
  - job_name: 'blog-server'
    static_configs:
      - targets: ['192.168.3.14:9100']
    scrape_interval: 30s
```

### Grafana データソース設定
```yaml
# /opt/monitoring/grafana/provisioning/datasources/prometheus.yml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
```

## 3. Node Exporter設置

### 各サーバーでの共通設定手順

```bash
# 1. ユーザー作成
sudo useradd --no-create-home --shell /bin/false node_exporter

# 2. Node Exporterダウンロード
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/latest/download/node_exporter-1.8.2.linux-amd64.tar.gz
tar xvfz node_exporter-1.8.2.linux-amd64.tar.gz

# 3. バイナリ配置
sudo mv node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# 4. systemdサービス作成
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=<SERVER_IP>:9100
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# 5. サービス有効化・開始
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# 6. ファイアウォール設定
sudo ufw allow from 192.168.3.0/24 to any port 9100

# 7. 動作確認
sudo systemctl status node_exporter
sudo netstat -tlnp | grep :9100
curl http://localhost:9100/metrics | head -5
```

### サーバー別設定

#### Proxmox母艦 (192.168.3.100)
```bash
ExecStart=/usr/local/bin/node_exporter --web.listen-address=192.168.3.100:9100
```

#### 開発サーバー (192.168.3.13)
```bash
ExecStart=/usr/local/bin/node_exporter --web.listen-address=192.168.3.13:9100
```

#### ブログサーバー (192.168.3.14)
```bash
ExecStart=/usr/local/bin/node_exporter --web.listen-address=192.168.3.14:9100
```

## 4. 接続情報

### アクセスURL
```
Prometheus: http://<コンテナIP>:9090
Grafana:    http://<コンテナIP>:3000
```

### Grafana認証情報
```
ユーザー名: admin
パスワード: admin123
```

### ポート構成
```
9090: Prometheus WebUI
3000: Grafana WebUI
9100: Node Exporter (各サーバー)
```

## 5. 監視メトリクス例

### よく使用するPromQLクエリ

#### CPU使用率
```promql
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

#### メモリ使用率
```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

#### ディスク使用量（ルートパーティション）
```promql
100 - ((node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100)
```

#### ロードアベレージ
```promql
node_load1
```

#### ネットワーク受信
```promql
irate(node_network_receive_bytes_total{device!="lo"}[5m])
```

## 6. トラブルシューティング

### よくある問題と解決法

#### Node ExporterがIPv6でしか起動しない
```bash
# 解決法: IPv4を明示的に指定
ExecStart=/usr/local/bin/node_exporter --web.listen-address=<IP_ADDRESS>:9100
```

#### 接続拒否エラー
```bash
# ファイアウォール確認
sudo ufw status
sudo ufw allow from 192.168.3.0/24 to any port 9100
```

#### Prometheus設定リロード
```bash
curl -X POST http://localhost:9090/-/reload
```

#### Docker Compose操作
```bash
# 起動
docker-compose up -d

# 停止
docker-compose down

# ログ確認
docker-compose logs -f prometheus
docker-compose logs -f grafana
```

## 7. 今後の拡張

### IaC化 (Ansible)
- Node Exporter自動インストール
- 設定ファイル自動生成
- 新サーバー自動監視対象追加

### 追加監視項目
- ルーター/ネットワーク機器 (SNMP)
- アプリケーション固有メトリクス
- ログ監視 (Loki + Promtail)

### アラート設定
- Alertmanager導入
- メール/Slack通知
- 閾値ベースアラート

---

構築日: 2025-09-06  
環境: Proxmox VE 9.0.3, Ubuntu 22.04 LTS
