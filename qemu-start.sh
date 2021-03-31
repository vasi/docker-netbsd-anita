if dd if=/dev/kvm count=0 >/dev/null 2>&1 ; then
    ENABLE_KVM="-enable-kvm"
else
    echo "Warning: Running without KVM acceleration" 1>&2
fi

qemu-system-x86_64 $ENABLE_KVM \
  -m 512 -drive file=/anita/snapshot/wd0.img,media=disk -nographic \
  -monitor telnet:0.0.0.0:4444,server,nowait \
  -serial telnet:localhost:4445,server,nowait \
  -netdev user,id=mynet0,ipv6=off,hostfwd=tcp::$SSH_PORT-:22 -device e1000,netdev=mynet0 &

# Wait for SSH
until ssh -p "$SSH_PORT" -q -oStrictHostKeyChecking=no -oConnectTimeout=5 localhost true; do
  sleep 1
done

# If given a pubkey, allow using it for login
if [ ! -z "$PUBKEY" ]; then
  echo "$PUBKEY" | ssh -p $SSH_PORT localhost \
    dd conv=notrunc oflag=append msgfmt=quiet of=/root/.ssh/authorized_keys
fi
