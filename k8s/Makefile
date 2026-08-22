# 対象ノードの known_hosts エントリを削除する。
# VM を作り直すとホストキーが変わるため、tofu apply 後に実行する。
.PHONY: clean-hostkeys
clean-hostkeys:
	@for ip in 101 111 112; do \
		ssh-keygen -f $$HOME/.ssh/known_hosts -R "192.168.3.$$ip"; \
	done    
