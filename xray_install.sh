###############

echo "Installing Dependencies"

silent() { "$@" >/dev/null 2>&1; }

silent apt-get install -y curl sudo mc
echo "Installed Dependencies"

mkdir -p /app/xray
wget --no-check-certificate https://github.com/minlearn/xray/raw/master/xray.tar.gz -O /tmp/tmp.tar.gz
tar -xzvf /tmp/tmp.tar.gz -C /app/xray xray --strip-components=1
rm -rf /tmp/tmp.tar.gz

cat > /lib/systemd/system/xray.service << 'EOL'
[Unit]
Description=this is xray service,please change/check the /root/token.txt then systemctl restart xray.service
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

cat > /app/xray/config.json << 'EOL'
{
  "log": null,
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api",
        "type": "field"
      },
      {
        "type": "field",
        "port": "443",
        "network": "udp",
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "domain": [
          "www.gstatic.com"
        ],
        "outboundTag": "direct"
      },
      {
        "ip": [
          "geoip:cn"
        ],
        "outboundTag": "blocked",
        "type": "field"
      },
      {
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ],
        "type": "field"
      },
      {
        "type": "field",
        "outboundTag": "xray-wg-warp-v4",
        "domain": [
          "ifconfig.co",
          "yg_kkk"
        ]
      },
      {
        "type": "field",
        "outboundTag": "xray-wg-warp-v6",
        "domain": [
          "ipget.net",
          "yg_kkk"
        ]
      },
      {
        "type": "field",
        "outboundTag": "socks5-warp-v4",
        "domain": [
          "yg_kkk"
        ]
      },
      {
        "type": "field",
        "outboundTag": "socks5-warp-v6",
        "domain": [
          "yg_kkk"
        ]
      },
      {
        "type": "field",
        "outboundTag": "vps-outbound-v4",
        "domain": [
          "api.myip.com",
          "yg_kkk"
        ]
      },
      {
        "type": "field",
        "outboundTag": "vps-outbound-v6",
        "domain": [
          "api64.ipify.org",
          "yg_kkk"
        ]
      },
      {
        "type": "field",
        "outboundTag": "direct",
        "network": "udp,tcp"
      }
    ]
  },
  "dns": null,
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 62789,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "streamSettings": null,
      "tag": "api",
      "sniffing": null
    },
    {
      "listen": null,
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "51163b2c-cf92-11eb-a214-525400715c38",
            "flow": ""
          }
        ],
        "decryption": "none",
        "fallbacks": []
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "serverName": "localhost",
          "rejectUnknownSni": false,
          "minVersion": "1.2",
          "maxVersion": "1.3",
          "cipherSuites": "",
          "certificates": [
            {
              "ocspStapling": 3600,
              "certificateFile": "/app/xray/certs/localhost.crt",
              "keyFile": "/app/xray/certs/localhost.key"
            }
          ],
          "alpn": [
            "http/1.1",
            "h2"
          ],
          "settings": [
            {
              "allowInsecure": false,
              "fingerprint": "",
              "serverName": ""
            }
          ]
        },
        "wsSettings": {
          "path": "/mywebsocket",
          "headers": {
            "Host": "xxx.xxxxxx.com"
          }
        }
      },
      "tag": "inbound-443",
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls",
          "quic"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "blackhole",
      "tag": "blocked"
    },
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIPv4v6"
      }
    },
    {
      "tag": "vps-outbound-v4",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIPv4v6"
      }
    },
    {
      "tag": "vps-outbound-v6",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIPv6v4"
      }
    },
    {
      "tag": "socks5-warp",
      "protocol": "socks",
      "settings": {
        "servers": [
          {
            "address": "127.0.0.1",
            "port": 40000
          }
        ]
      }
    },
    {
      "tag": "socks5-warp-v4",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIPv4v6"
      },
      "proxySettings": {
        "tag": "socks5-warp"
      }
    },
    {
      "tag": "socks5-warp-v6",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIPv6v4"
      },
      "proxySettings": {
        "tag": "socks5-warp"
      }
    },
    {
      "tag": "xray-wg-warp",
      "protocol": "wireguard",
      "settings": {
        "secretKey": "4GRI+uhXHop6U9H5Gi4YbD+5IoBvZ/kLdTdyal/y9EE=",
        "address": [
          "172.16.0.2/32",
          "2606:4700:110:845b:dd5b:5b91:8e5a:60b9/128"
        ],
        "peers": [
          {
            "publicKey": "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
            "allowedIPs": [
              "0.0.0.0/0",
              "::/0"
            ],
            "endpoint": "162.159.192.1:2408"
          }
        ],
        "reserved": [
          197,
          230,
          30
        ]
      }
    },
    {
      "tag": "xray-wg-warp-v4",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIPv4v6"
      },
      "proxySettings": {
        "tag": "xray-wg-warp"
      }
    },
    {
      "tag": "xray-wg-warp-v6",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIPv6v4"
      },
      "proxySettings": {
        "tag": "xray-wg-warp"
      }
    }
  ],
  "transport": null,
  "policy": {
    "system": {
      "statsInboundDownlink": true,
      "statsInboundUplink": true
    },
    "levels": {
      "0": {
        "handshake": 10,
        "connIdle": 100,
        "uplinkOnly": 2,
        "downlinkOnly": 3,
        "bufferSize": 10240
      }
    }
  },
  "api": {
    "services": [
      "HandlerService",
      "LoggerService",
      "StatsService"
    ],
    "tag": "api"
  },
  "stats": {},
  "reverse": null,
  "fakeDns": null
}
EOL

systemctl enable -q --now xray


echo "Cleaning up"
silent apt-get -y autoremove
silent apt-get -y autoclean
echo "Cleaned"

##############
