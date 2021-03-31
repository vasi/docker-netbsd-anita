# QEMU-based NetBSD docker images

Runs NetBSD in emulation, using QEMU, so you can test easily on NetBSD. Inspired by [madworx/netbsd](https://hub.docker.com/r/madworx/netbsd/).

Available on Docker Hub as [vasi/netbsd](https://hub.docker.com/r/vasi/netbsd). Source is on [GitHub](https://github.com/vasi/docker-netbsd-anita).

## Usage

### Run a command
```
docker run --rm vasi/netbsd uname -a
```

### Get a shell

```
docker run --rm --ti vasi/netbsd sh
```

### Run in background, login with SSH

```
docker run -p 127.0.0.1:2222:22 --rm -ti --name netbsd --device=/dev/kvm -e PUBKEY="$(ssh-add -L | head -n1)" -d vasi/netbsd
ssh -oStrictHostKeyChecking=no -p 2222 root@localhost
```

## Comparison to madworx/netbsd

This is very similar to madworx/netbsd. The difference is that madworx's project boots from NFS, while this one uses [a fork](https://github.com/vasi/anita) of [Anita](https://www.gson.org/netbsd/anita/) to auto-install NetBSD onto a virtual disk.

There are pros and cons to this approach:

Pros:
* More realistic/"normal" NetBSD installation
* Faster disk
* No weird NFS symptoms

Cons:
* Harder to change files in the VM
* Each Docker layer that changes the virtual disk snapshot has to copy the whole snapshot
