# pgnode

This project provides a framework to operate a single node [postgresql](https://www.postgresql.org/) server on a virtual private server (VPS) with continuos backups, and automated recovery using [pgbackrest](https://pgbackrest.org/).

# Requirements

This solution is designed for sub 1gb databases, typically a core service of some sort which provides a source of truth for a single tenant application.

The goals of this project are:

* resilient to machine interruption with minimal data loss
* frequent incremental backups, with full backups for disaster recovery
* automated recovery in the case of interruption
* support for scheduled teardown and rebuild

# Local Development

With the help of [multipass](https://multipass.run/), [minio](https://min.io/) and [cloudinit](https://cloudinit.readthedocs.io/en/latest/index.html) we can simulate a virtual private server (VPS), or EC2 host, with access to S3 compatible object storage for backups and restores.

The requirements for this setup are:

- [multipass](https://multipass.run/)
- [minio](https://min.io/)
- [mkcert](https://github.com/FiloSottile/mkcert)
- pwgen
= GNU sed

All these things can be installed via homebrew on OSX as follows.

```
brew install minio/stable/minio
brew install pwgen
brew install --cask multipass
brew install gsed
brew install mkcert
```

Setup `mkcert` 

```
mkcert -install
```

Now we can run the development environment.

First we generate some certs for minio.

```
make certs
```

Create an store the password for minio locally.

```
make password
```

Create our initial virtual machine, this should spin up, install postgresql and perform a backup.

```
make pgnode-new
```

Log in an check the status of postgresql and pgbackrest.

```
multipass shell
sudo service postgresql status
ps aux | grep postgre[s]
sudo -u postgres pgbackrest --stanza=main --log-level-console=info info
```

Log out of linux, then delete and purge the instance so we can test out the restore process from the data in minio.

```
make pgnode-restore
```

Log in an check the status of postgresql and pgbackrest.

```
multipass shell
sudo service postgresql status
ps aux | grep postgre[s]
sudo -u postgres pgbackrest --stanza=main --log-level-console=info info
```