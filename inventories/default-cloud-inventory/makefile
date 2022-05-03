
.PHONY: decrypt
decrypt:
	ansible-vault decrypt ./**/*.yml --vault-password-file .vault_pass

.PHONY: encrypt
encrypt:
	ansible-vault encrypt ./**/*.yml --vault-password-file .vault_pass