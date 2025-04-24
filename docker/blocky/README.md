# Install

## Tips 

If 53 is already occupied by a `127.0.0.53` or `127.0.0.54` setup this file

```bash
mkdir /etc/systemd/resolved.conf.d
echo "[Resolve]
DNSStubListener=no" | sudo tee /etc/systemd/resolved.conf.d/no-stub.conf
systemctl restart systemd-resolved
```
