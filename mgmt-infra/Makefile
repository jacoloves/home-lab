# 管理ホスト構成管理のタスク定義
.PHONY: help deps lint check apply idempotence test

ANSIBLE_DIR := ansible

help: ## ヘルプを表示する
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

deps: ## 依存コレクションを導入する
	cd $(ANSIBLE_DIR) && ansible-galaxy collection install -r requirements.yml

lint: ## 静的解析を実行する
	cd $(ANSIBLE_DIR) && ansible-lint site.yml

check: ## dry-run で差分を確認する
	cd $(ANSIBLE_DIR) && ansible-playbook site.yml --check --diff --ask-become-pass

apply: ## 構成を適用する
	cd $(ANSIBLE_DIR) && ansible-playbook site.yml --ask-become-pass

idempotence: ## 冪等性を確認する(2回目の実行で changed=0 になるべき)
	cd $(ANSIBLE_DIR) && ansible-playbook site.yml --ask-become-pass \
		| tee /tmp/ansible-idempotence.log
	@grep -q 'changed=0' /tmp/ansible-idempotence.log \
		&& echo "OK: 冪等性を確認しました" \
		|| (echo "NG: 2回目の実行で変更が発生しています" && exit 1)

test: lint check ## lint と dry-run をまとめて実行する

monitoring-up: ## 監視スタックを起動する
	cd compose/monitoring && docker compose up -d

monitoring-down: ## 監視スタックを停止する
	cd compose/monitoring && docker compose down

monitoring-logs: ## 監視スタックのログを表示する
	cd compose/monitoring && docker compose logs -f --tail 50
