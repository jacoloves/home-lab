ANSIBLE_DIR := ansible

.PHONY: check apply lint

## Ansible の dry-run
check:
	cd $(ANSIBLE_DIR) && ansible-playbook site.yml --check --diff

## Ansible の適用
apply:
	cd $(ANSIBLE_DIR) && ansible-playbook site.yml

## 静的解析
lint:
	cd $(ANSIBLE_DIR) && ansible-lint
