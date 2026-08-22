
## コーディング規約

### Ansible タスク名

`ansible-lint` の `name[casing]` ルールにより、タスク名の先頭は
大文字である必要がある。日本語は大小の区別がないため通過するが、
`node_exporter` のような英字小文字始まりの語を先頭に置くと違反となる。

- NG: `name: node_exporter を導入する`
- OK: `name: パッケージ node_exporter を導入する`
- OK: `name: コレクタを設定する(node_exporter)`

固有名詞は括弧書きで後置するか、日本語の名詞を先頭に補う。
