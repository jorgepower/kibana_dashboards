# kibana_dashboards
Kibana dashboard generation using bash/nodejs using Puppeteer library

## Environment
Centos 7 3.10.0-693.17.1.el7.x86_64

Kibana kibana-6.1.2-1.x86_64

Nodejs v8.9.4

Chrome-linux 534132

Puppeteer 1.0.0


### Environment preparation

#### Prerequisites
Centos 7

Kibana 6.1.2

#### Node, chrome and puppeter installation
curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -

yum -y install nodejs

yum -y install pango.x86_64 libXcomposite.x86_64 libXcursor.x86_64 libXdamage.x86_64 libXext.x86_64 libXi.x86_64 libXtst.x86_64 cups-libs.x86_64 libXScrnSaver.x86_64 libXrandr.x86_64 GConf2.x86_64 alsa-lib.x86_64 atk.x86_64 gtk3.x86_64 ipa-gothic-fonts xorg-x11-fonts-100dpi xorg-x11-fonts-75dpi xorg-x11-utils xorg-x11-fonts-cyrillic xorg-x11-fonts-Type1 xorg-x11-fonts-misc

cd /opt/

git clone https://github.com/scheib/chromium-latest-linux chrome

cd chrome

./update.sh

cd latest

sudo chown root:root chrome_sandbox && chmod 4755 chrome_sandbox

cd /opt/

export CHROME_DEVEL_SANDBOX="/opt/chrome/latest/chrome_sandbox"

export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

npm install --save puppeteer

### Script execution
In order to have weekly dashboards for the last year:

./cybersec_dashboards.sh 52
