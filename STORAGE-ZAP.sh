echo "Enter private key:"
read -r KEY
echo "ENTER RPC:"
read -r RPC
echo "ENTER SleepTIME:"
read -r SleepTIME

sleep $SleepTIME

sudo apt-get update
sudo apt-get install -y clang cmake build-essential openssl pkg-config libssl-dev jq git bc

cd $HOME && \
ver="1.22.0" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile && \
source ~/.bash_profile && \
go version
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"
git clone -b v1.0.0 https://github.com/0glabs/0g-storage-node.git
cd $HOME/0g-storage-node
git stash
git fetch --all --tags
git checkout v1.0.0
git submodule update –init
mkdir -p /root/0g-storage-node/target/release
wget http://195.201.198.8:12385/zgs_node
mv zgs_node /root/0g-storage-node/target/release/zgs_node && chmod +x /root/0g-storage-node/target/release/zgs_node
wget http://195.201.198.8:12385/config-testnet-turbo.toml
mv config-testnet-turbo.toml /root/0g-storage-node/run/config-testnet-turbo.toml
sudo tee /etc/systemd/system/zgstorage.service > /dev/null <<EOF
[Unit]
Description=ZGS Node
After=network.target

[Service]
User=root
WorkingDirectory=/root/0g-storage-node/run
ExecStart=/root/0g-storage-node/target/release/zgs_node --config /root/0g-storage-node/run/config-testnet-turbo.toml
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
sed -i "s|^network_enr_address = \".*\"|network_enr_address = \"$(curl -s 2ip.ru)\"|" /root/0g-storage-node/run/config-testnet-turbo.toml
sed -i "s|^blockchain_rpc_endpoint = \".*\"| blockchain_rpc_endpoint = \"${RPC}\"|" /root/0g-storage-node/run/config-testnet-turbo.toml
sed -i "s|^miner_key = \".*\"|miner_key = \"${KEY}\"|" /root/0g-storage-node/run/config-testnet-turbo.toml
systemctl daemon-reload && systemctl enable zgstorage && systemctl start zgstorage
