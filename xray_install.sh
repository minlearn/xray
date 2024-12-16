###############

echo "Installing Dependencies"
apt-get install -y curl
apt-get install -y sudo
apt-get install -y mc
echo "Installed Dependencies"

mkdir -p /app/xray
wget --no-check-certificate https://github.com/minlearn/xray/raw/master/xray.tar.gz -O /tmp/tmp.tar.gz
tar -xzvf /tmp/tmp.tar.gz -C /app/xray xray --strip-components=1
rm -rf /tmp/tmp.tar.gz

cat > /lib/systemd/system/xray.service << 'EOL'
[Unit]
Description=this is xray service,please change the /root/token.txt then systemctl restart xray.service
After=network.target nss-lookup.target
Wants=network.target nss-lookup.target
Requires=network.target nss-lookup.target

[Service]
Type=simple
ExecStartPre=/usr/bin/bash -c "date=$$(echo -n $$(ip addr |grep $$(ip route show |grep -o 'default via [0-9]\\{1,3\\}.[0-9]\\{1,3\\}.[0-9]\\{1,3\\}.[0-9]\\{1,3\\}.*' |head -n1 |sed 's/proto.*\\|onlink.*//g' |awk '{print $$NF}') |grep 'global' |grep 'brd' |head -n1 |grep -o '[0-9]\\{1,3\\}.[0-9]\\{1,3\\}.[0-9]\\{1,3\\}.[0-9]\\{1,3\\}/[0-9]\\{1,2\\}') |cut -d'/' -f1);PATH=/usr/local/bin:$PATH exec sed -i s/xxx.xxxxxx.com/$${date}/g /app/xray/config.json"
ExecStart=/app/xray/xray -c /app/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOL

systemctl enable -q --now xray


echo "Cleaning up"
apt-get -y autoremove
apt-get -y autoclean
echo "Cleaned"

##############