#!/bin/bash
#
# ==================================================
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################

BURIQ () {
    curl -sS https://raw.githubusercontent.com/zalsfyn/otw/main/ip > /root/tmp
    data=( `cat /root/tmp | grep -E "^### " | awk '{print $2}'` )
    for user in "${data[@]}"
    do
    exp=( `grep -E "^### $user" "/root/tmp" | awk '{print $3}'` )
    d1=(`date -d "$exp" +%s`)
    d2=(`date -d "$biji" +%s`)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ "$exp2" -le "0" ]]; then
    echo $user > /etc/.$user.ini
    else
    rm -f /etc/.$user.ini > /dev/null 2>&1
    fi
    done
    rm -f /root/tmp
}

MYIP=$(curl -sS ipv4.icanhazip.com)
Name=$(curl -sS https://raw.githubusercontent.com/zalsfyn/otw/main/ip | grep $MYIP | awk '{print $2}')
echo $Name > /usr/local/etc/.$Name.ini
CekOne=$(cat /usr/local/etc/.$Name.ini)

Bloman () {
if [ -f "/etc/.$Name.ini" ]; then
CekTwo=$(cat /etc/.$Name.ini)
    if [ "$CekOne" = "$CekTwo" ]; then
        res="Expired"
    fi
else
res="Permission Accepted..."
fi
}

PERMISSION () {
    MYIP=$(curl -sS ipv4.icanhazip.com)
    IZIN=$(curl -sS https://raw.githubusercontent.com/zalsfyn/otw/main/ip | awk '{print $4}' | grep $MYIP)
    if [ "$MYIP" = "$IZIN" ]; then
    Bloman
    else
    res="Permission Denied!"
    fi
    BURIQ
}
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
PERMISSION
if [ -f /home/needupdate ]; then
red "Your script need to update first !"
exit 0
elif [ "$res" = "Permission Accepted..." ]; then
echo -ne
else
red "Permission Denied!"
exit 0
fi

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(curl -sS ifconfig.me);
MYIP2="s/xxxxxxxxx/$MYIP/g";
ANU=$(ip -o $ANU -4 route show to default | awk '{print $5}');

# Install OpenVPN dan Easy-RSA
apt install openssl iptables iptables-persistent -y >/dev/null 2>&1
mkdir -p /etc/openvpn/server/easy-rsa/
cd /etc/openvpn/
wget -q https://raw.githubusercontent.com/zalsfyn/v1/main/ssh/vpn.zip
unzip -o -P scvps07 vpn.zip >/dev/null 2>&1
rm -f vpn.zip
chown -R root:root /etc/openvpn/server/easy-rsa/

cd
mkdir -p /usr/lib/openvpn/
cp /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so /usr/lib/openvpn/openvpn-plugin-auth-pam.so >/dev/null 2>&1

# nano /etc/default/openvpn
sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/g' /etc/default/openvpn

# restart openvpn dan cek status openvpn
systemctl enable --now openvpn-server@server-tcp-1194 >/dev/null 2>&1
systemctl enable --now openvpn-server@server-udp-2200 >/dev/null 2>&1
/etc/init.d/openvpn restart >/dev/null 2>&1
/etc/init.d/openvpn status >/dev/null 2>&1

# aktifkan ip4 forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

# Buat config client TCP 1194
cat > /etc/openvpn/Tcp.ovpn <<-END
setenv FRIENDLY_NAME "ZALSFYN"
client
dev tun
proto tcp
remote xxxxxxxxx 1194
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END

sed -i $MYIP2 /etc/openvpn/Tcp.ovpn

# Buat config client UDP 2200
cat > /etc/openvpn/Udp.ovpn <<-END
setenv FRIENDLY_NAME "ZALSFYN"
client
dev tun
proto udp
remote xxxxxxxxx 2200
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END

sed -i $MYIP2 /etc/openvpn/Udp.ovpn

# Buat config client SSL
cat > /etc/openvpn/SSL.ovpn <<-END
setenv FRIENDLY_NAME "ZALSFYN"
client
dev tun
proto tcp
remote xxxxxxxxx 442
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END

sed -i $MYIP2 /etc/openvpn/SSL.ovpn

# Buat config client TCP 6969
cat > /etc/openvpn/OHP.ovpn <<-END
setenv FRIENDLY_NAME "ZALSFYN"
client
dev tun
proto tcp
remote xxxxxxxxx 
port 1194
http-proxy xxxxxxxxx 6969
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END

sed -i $MYIP2 /etc/openvpn/OHP.ovpn

cd
# pada tulisan xxx ganti dengan alamat ip address VPS anda 
/etc/init.d/openvpn restart >/dev/null 2>&1

# masukkan certificatenya ke dalam config client OHP 1194
echo '<ca>' >> /etc/openvpn/OHP.ovpn
cat /etc/openvpn/server/ca.crt >> /etc/openvpn/OHP.ovpn
echo '</ca>' >> /etc/openvpn/OHP.ovpn

# Copy config OpenVPN client ke home directory root agar mudah didownload ( ohp 1194 )
cp /etc/openvpn/OHP.ovpn /home/vps/public_html/OHP.ovpn

# masukkan certificatenya ke dalam config client TCP 1194
echo '<ca>' >> /etc/openvpn/Tcp.ovpn
cat /etc/openvpn/server/ca.crt >> /etc/openvpn/Tcp.ovpn
echo '</ca>' >> /etc/openvpn/Tcp.ovpn

# Copy config OpenVPN client ke home directory root agar mudah didownload ( TCP 1194 )
cp /etc/openvpn/Tcp.ovpn /home/vps/public_html/Tcp.ovpn

# masukkan certificatenya ke dalam config client UDP 2200
echo '<ca>' >> /etc/openvpn/Udp.ovpn
cat /etc/openvpn/server/ca.crt >> /etc/openvpn/Udp.ovpn
echo '</ca>' >> /etc/openvpn/Udp.ovpn

# Copy config OpenVPN client ke home directory root agar mudah didownload ( UDP 2200 )
cp /etc/openvpn/Udp.ovpn /home/vps/public_html/Udp.ovpn

# masukkan certificatenya ke dalam config client SSL
echo '<ca>' >> /etc/openvpn/SSL.ovpn
cat /etc/openvpn/server/ca.crt >> /etc/openvpn/SSL.ovpn
echo '</ca>' >> /etc/openvpn/SSL.ovpn

# Copy config OpenVPN client ke home directory root agar mudah didownload ( SSL )
cp /etc/openvpn/SSL.ovpn /home/vps/public_html/SSL.ovpn

#firewall untuk memperbolehkan akses UDP dan akses jalur TCP

sudo iptables -t nat -I POSTROUTING -s 10.6.0.0/24 -o $ANU -j MASQUERADE
sudo iptables -t nat -I POSTROUTING -s 10.7.0.0/24 -o $ANU -j MASQUERADE
sudo iptables-save > /etc/iptables.up.rules
chmod +x /etc/iptables.up.rules

sudo iptables-restore -t < /etc/iptables.up.rules
sudo netfilter-persistent save >/dev/null 2>&1
sudo netfilter-persistent reload >/dev/null 2>&1

# Restart service openvpn
systemctl enable openvpn >/dev/null 2>&1
systemctl start openvpn >/dev/null 2>&1
/etc/init.d/openvpn restart >/dev/null 2>&1

# Delete script
 
cd /home/vps/public_html/
zip cfg.zip Tcp.ovpn Udp.ovpn SSL.ovpn OHP.ovpn > /dev/null 2>&1
cd
cat <<'mySiteOvpn' > /home/vps/public_html/index.html
<!DOCTYPE html>
<html lang="en">

<!-- Simple OVPN Download site -->

<head><meta charset="utf-8" />
<title>OVPN Config Download</title>
<meta name="description" content="Server" />
<meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" name="viewport" />
<meta name="theme-color" content="#000000" />
<style>
* {
margin: 0;
padding: 0;
}
html {
min-height: 100%;
}
body {
background-color: #333;
font-size: 100%;
padding-bottom: 1.5em;
}
header {
background-color: #292929;
background-image: -webkit-linear-gradient(hsla(0,0%,0%,.1), transparent);
box-shadow: inset 0 -10px 30px -10px hsla(0,0%,0%,.5),
0 1px 0 hsla(0,0%,100%,.1);
height: 3em;
margin-bottom: 3em;
}
header div {
margin: 0 auto;
width: 18em;
}
header a {
background: transparent;
box-shadow: none;
color: #888;
display: inline;
font: 1em/3 sans-serif;
position: relative;
top: 0;
text-shadow: 0 2px 2px #000;
}
header a:hover,
header a:focus {
color: #ddd;
}
header a:active {
box-shadow: none;
top: 1px;
-webkit-transition: 0;
}
h1 {
color: hsla(0,0%,0%,.4);
font: bold 3em/1 sans-serif;
margin-bottom: .5em;
text-align: center;
text-shadow: 0 1px 2px hsla(0,0%,100%,.2), 0 0 0 #000;
}
.content {
display: table;
height: 100%;
margin: 0 auto;
width: 80%;
}
ul {
display: table-cell;
list-style: none;
text-align: center;
vertical-align: middle;
}
li {
background-color: #f6f6f6;
background-image: -webkit-radial-gradient(circle, transparent, hsla(0,0%,0%,.25));
background-position: 50% 0%;
background-size: 200% 200%;
border-radius: .5em .5em 0 0;
box-shadow: inset 0 1px 0 #fff,
0 1px 0 1px hsla(0,0%,0%,.25),
0 3px 7px hsla(0,0%,0%,.5);
color: #333;
display: inline-block;
font: bold 1em/1.5 sans-serif;
margin: 1.5em 1.5em 5em;
padding-top: 1.5em;
position: relative;
vertical-align: bottom;
width: 18em;
-webkit-filter: drop-shadow(0 2px 3px hsla(0,0%,0%,.25));
}
li:after,
li:before {
background-color: #bbb;
background-image: -webkit-radial-gradient(circle, transparent, hsla(0,0%,0%,.25));
background-position: 50% 75%;
background-size: 150% 150%;
box-shadow: inset 0 1px 1px 1px hsla(0,0%,100%,.25),
inset 0 -1px 1px 1px hsla(0,0%,0%,.25),
0 2px 2px 1px hsla(0,0%,0%,.4),
0 0 0 1px hsla(0,0%,0%,.5),
2px 2px 3px hsla(0,0%,0%,.25),
-2px 2px 3px hsla(0,0%,0%,.25);
content: '';
height: 2em;
margin-top: .5em;
position: absolute;
top: 50%;
width: .5em;
}
li:after {
border-radius: .25em 100% 100% .25em;
left: -.2em;
}
li:before {
border-radius: 100% .25em .25em 100%;
right: -.2em;
}
p {
margin-bottom: 1.5em;
padding: 0 1.5em;
text-shadow: 0 1px 1px #fff;
}
a {
background-color: #f6f6f6;
border-radius: 0 0 .25em .25em;
box-shadow: inset 0 1px 0 hsla(0,0%,100%,1),
0 0 0 1px hsla(0,0%,0%,.25),
0 6px 10px hsla(0,0%,0%,.5);
color: #888;
display: block;
left: 0;
line-height: 1.5;
padding: 1em 0;
position: absolute;
right: 0;
text-decoration: none;
text-shadow: 0 1px 1px hsla(0,0%,100%,.4);
top: 100%;
-webkit-transform: perspective(500) rotateX(0deg);
-webkit-transform-origin: 50% 0;
-webkit-transition: .1s;
}
li:hover a {
color: #666;
}
a:active {
background-position:50% 100%, 0 0;
box-shadow: inset 0 1px 0 hsla(0,0%,100%,.5),
0 0 0 1px hsla(0,0%,0%,.25),
0 2px 3px hsla(0,0%,0%,.75);
color: #555;
-webkit-transform: perspective(500) rotateX(-10deg);
}
.icon {
background-image: -webkit-linear-gradient(transparent 50%, #6cf 50%);
background-position: 50% 0;
background-size: 200% 200%;
display: block;
height: 1.5em;
font-style: normal;
margin: 0 1.5em 1.5em;
position: relative;
-webkit-transition: .25s;
}
li:hover .icon {
background-position: 50% 100%;
}
.icon:after {
background-color: hsla(0,0%,0%,.15);
box-shadow: 0 1px 1px hsla(0,0%,100%,.6),
0 -1px 1px hsla(0,0%,0%,.1),
inset 0 0 0 1px hsla(0,0%,0%,.15);
color: #eee;
font-size: .8em;
left: 0;
line-height: 1.875;
position: absolute;
right: 0;
text-align: center;
text-shadow: 0 1px 1px hsla(0,0%,0%,.25);
text-transform: uppercase;
}
.icon:before {
background-image: -webkit-linear-gradient(hsla(0,0%,100%,.05), hsla(0,0%,100%,.15) 50%, transparent 50%);
content: '';
height: 100%;
left: 0;
position: absolute;
top: 0;
width: 100%;
}
.TCP:after { 
content: 'TCP';
}
.UDP:after {
content: 'UDP';
}
.OHP:after {
content: 'OHP';
}
.SSL:after {
content: 'SSL';
}
.ZIP:after {
content: 'ZIP';
}
.BLOG:after {
content: 'BLOG';
}
@media (min-width: 52.85em) {
header div {
width: 39em;
}
}
@media (min-width: 79.38em) {
header div {
width: 60em;
}
}
@media (min-width: 105.95em) {
header div {
width: 81em;
}
}
</style>
</head>
<body>

<header>
<div>
<a href="https://dotycat.com/">&larr; Back to DOTYCAT.COM</a>
</div>
</header>
<div class="content">
<ul>
<li>
<i class="icon TCP"></i>
<p>TCP OpenVPN</p>
<a href="http://IP-ADDRESSS:81/Tcp.ovpn">Download</a>
</li>
<li>
<i class="icon UDP"></i>
<p>UDP OpenVPN</p>
<a href="http://IP-ADDRESSS:81/Udp.ovpn">Download</a>
</li>
<li>
<i class="icon SSL"></i>
<p>SSL OpenVPN</p>
<a href="http://IP-ADDRESSS:81/SSL.ovpn">Download</a>
</li>
<li>
<i class="icon OHP"></i>
<p>OHP OpenVPN</p>
<a href="http://IP-ADDRESSS:81/OHP.ovpn">Download</a>
</li>
<li>
<i class="icon ZIP"></i>
<p>OpenVPN ZIP</p>
<a href="http://IP-ADDRESSS:81/cfg.zip">Download</a>
</li>
<li>
<i class="icon BLOG"></i>
<p>DOTYCAT BLOG</p>
<a href="https://www.dotycat.com/">VISIT BLOG</a>
</li>
</ul>
</div>

</body></html>
mySiteOvpn

sed -i "s|IP-ADDRESSS|$(curl -sS ifconfig.me)|g" /home/vps/public_html/index.html

history -c 
rm -f /root/vpn.sh

