https://www.zigbee2mqtt.io/guide/installation/01_linux.html#installing

```
# Set up Node.js repository, install Node.js, pnpm and required dependencies
# NOTE 1: Older i386 hardware can work with [unofficial-builds.nodejs.org](https://unofficial-builds.nodejs.org/download/release/v20.9.0/ e.g. Version 20.9.0 should work.
# NOTE 2: For Ubuntu see installing through Snap below.
sudo apt-get install -y curl
sudo curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs git make g++ gcc libsystemd-dev
npm install -g pnpm

# Verify that the correct nodejs and pnpm version has been installed
node --version  # Should output V20.x, V22.X
pnpm --version  # Should output 10.X

cd ~/git
# Clone Zigbee2MQTT repository
git clone --depth 1 https://github.com/Koenkk/zigbee2mqtt.git

# Install dependencies (as user "pi")
cd zigbee2mqtt
pnpm i --frozen-lockfile
```
