.PHONY: check
check:
	@test -f .password || { echo 'password does not exist, run 'make password' to create one!'; exit 1; }

.PHONY: password
password:
	@pwgen -1 -s 24 1 | tr -d '\n' > .password

certs:
	@mkdir -p .certs
	@mkcert -cert-file .certs/public.crt -key-file .certs/private.key minio.localhost localhost
.PHONY: certs

.PHONY: minio
minio: check
	@mkdir -p storage/pgnode-backups
	MINIO_ROOT_USER=admin MINIO_ROOT_PASSWORD=$(shell cat .password) minio server ./storage --console-address ":9001" --certs-dir .certs

.PHONY: pgnode-new
pgnode-new: check
	@gsed -r 's/(repo1-s3-key-secret).*$$/\1=$(shell cat .password)/' cloud_config_new.yaml > cloud_config_new_launch.yaml
	@multipass launch lts --name primary --cloud-init cloud_config_new_launch.yaml

.PHONY: pgnode-restore
pgnode-restore: check
	@gsed -r 's/(repo1-s3-key-secret).*$$/\1=$(shell cat .password)/' cloud_config_restore.yaml > cloud_config_restore_launch.yaml
	@multipass launch lts --name primary --cloud-init cloud_config_restore_launch.yaml

.PHONY: pgnode-delete
pgnode-delete: check
	@multipass delete primary -p