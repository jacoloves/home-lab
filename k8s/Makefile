ANSIBLE_DIR := ansible
TOFU_DIR    := tofu
NODE_IPS    := 101 111 112

.PHONY: check apply lint clean-hostkeys

## Ansible の dry-run
check:
	cd $(ANSIBLE_DIR) && ansible-playbook site.yml --check --diff

## Ansible の適用
apply:
	cd $(ANSIBLE_DIR) && ansible-playbook site.yml

## 静的解析
lint:
	cd $(ANSIBLE_DIR) && ansible-lint

## VM 再作成後にホストキーを削除する
clean-hostkeys:
	@for ip in $(NODE_IPS); do \
		ssh-keygen -f $$HOME/.ssh/known_hosts -R "192.168.3.$$ip"; \
	done
