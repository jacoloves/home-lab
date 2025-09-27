# Node Exporter用ユーザー作成
sudo useradd --no-create-home --shell /bin/false node_exporter

# 作業ディレクトリに移動
cd /tmp

# Node Exporterダウンロード
wget https://github.com/prometheus/node_exporter/releases/latest/download/node_exporter-1.8.2.linux-amd64.tar.gz

# 展開
tar xvfz node_exporter-1.8.2.linux-amd64.tar.gz

# バイナリを配置
sudo mv node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# サービスファイル作成
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# systemd設定リロード
sudo systemctl daemon-reload

# サービス有効化・開始
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# 動作確認
sudo systemctl status node_exporter
