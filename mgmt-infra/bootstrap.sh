#!/usr/bin/env bash
#
# 管理ホストの初期セットアップスクリプト
#
# 責務: Ansible が動作する最低限の状態を作ることのみ。
#       実質的な構成管理は ansible/site.yml 側に記述すること。
#       このスクリプトは冪等性を保証しない(初回のみ実行する想定)。
#
set -euo pipefail

echo "==> パッケージリストを更新"
sudo apt-get update

echo "==> 基本パッケージを導入"
sudo apt-get install -y git curl python3 python3-pip pipx

echo "==> pipx のパスを有効化"
pipx ensurepath

echo "==> Ansible を導入(pipx で隔離インストール)"
pipx install --include-deps ansible

echo "==> ansible-lint を導入"
pipx inject --include-apps ansible ansible-lint

echo "==> ~/.local/bin を PATH に追加"
# pipx ensurepath は実行シェルによって書き込み先が変わるため、
# zsh 設定への追記を明示的に行う(重複追記は避ける)
if ! grep -q '.local/bin' "${HOME}/.zshrc" 2>/dev/null; then
    cat <<'PATHCONF' >> "${HOME}/.zshrc"

# pipx でインストールしたコマンドへのパス
export PATH="$HOME/.local/bin:$PATH"
PATHCONF
    echo "    ~/.zshrc に追記しました"
else
    echo "    既に設定済みのためスキップします"
fi

echo ""
echo "完了しました。以下を実行して PATH を反映してください:"
echo "  source ~/.zshrc"
