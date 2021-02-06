FROM ubuntu:18.04

LABEL maintainer="Sebastian Schmidt"

ENV WINEPREFIX=/wine \
    DEBIAN_FRONTEND=noninteractive \
    PUID=0 \
    PGID=0 \
    SERVERIP="0.0.0.0" \
    SERVERNAME="Balade en Foret" \
    SERVERPORT=27015 \
    QUERYPORT=27016 \
    STEAMPORT=8766 \
    SERVERSTEAMACCOUNT="anonymous" \
    SERVERPASSWORD="banana" \
    SERVERADMINPASSWORD="banana"

ENV serverIP="0.0.0.0"
ENV serverSteamPort="8766"
ENV serverGamePort="27015"
ENV serverQueryPort="27016"
ENV serverName="Balade en Foret"
ENV serverPlayers="8"
ENV enableVAC="off"
ENV serverPassword="banana"
ENV serverPasswordAdmin="banana"
ENV serverSteamAccount="anonymous"
ENV serverAutoSaveInterval="30"
ENV difficulty="Normal"
ENV initType="Continue"
ENV slot="1"
ENV showLogs="on"
ENV serverContact=""
ENV veganMode="off"
ENV vegetarianMode="off"
ENV resetHolesMode="off"
ENV treeRegrowMode="on"
ENV allowBuildingDestruction="on" 
ENV allowEnemiesCreativeMode="off"
ENV allowCheats="off"
ENV realisticPlayerDamage="off"
ENV saveFolderPath="/theforest/saves/"
ENV targetFpsIdle="5"
ENV targetFpsActive="60"


RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y libgnutls30:i386 libldap-2.4-2:i386 libgpg-error0:i386 libxml2:i386 libasound2-plugins:i386 libsdl2-2.0-0:i386 libfreetype6:i386 libdbus-1-3:i386 libsqlite3-0:i386 wget 
    software-properties-common supervisor apt-transport-https xvfb winbind cabextract gpg-agent \
    && wget https://dl.winehq.org/wine-builds/winehq.key \
    && apt-key add winehq.key \
    && apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main' \
    && add-apt-repository ppa:cybermax-dexter/sdl2-backport \
    && apt-get update \
    && apt update && apt install -y winehq-stable \
    && wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x ./winetricks \
    && WINEDLLOVERRIDES="mscoree,mshtml=" wineboot -u \
    && wineserver -w \
    && ./winetricks -q winhttp wsh57 vcrun6sp6

COPY . ./

RUN mkdir /theforest && mkdir /theforest/config

RUN echo "serverIP ${SERVERIP}\n" \
         "serverSteamPort ${STEAMPORT}\n" \
         "serverGamePort ${SERVERPORT}\n" \
         "serverQueryPort ${QUERYPORT}\n" \
         "serverName ${SERVERNAME}\n" \
         "serverPlayers 8\n" \
         "enableVAC off\n" \
         "serverPassword ${SERVERPASSWORD}\n" \
         "serverPasswordAdmin ${SERVERADMINPASSWORD}\n" \
         "serverSteamAccount ${SERVERSTEAMACCOUNT}\n" \
         "serverAutoSaveInterval 30\n" \
         "difficulty Normal\n" \
         "initType Continue\n" \
         "slot 1\n" \
         "showLogs on\n" \
         "serverContact \n" \
         "veganMode off\n" \
         "vegetarianMode off\n" \
         "resetHolesMode off\n" \
         "treeRegrowMode off\n" \
         "allowBuildingDestruction on\n" \
         "allowEnemiesCreativeMode off\n" \
         "allowCheats off\n" \
         "realisticPlayerDamage off\n" \
		 "saveFolderPath /theforest/saves/\n" \
         "targetFpsIdle 5\n" \
         "targetFpsActive 60\n" > /theforest/config/config.cfg

RUN apt-get remove -y software-properties-common apt-transport-https cabextract \
    && rm -rf winetricks /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
    && echo $TIMEZONE > /etc/timezone \
    && chmod +x /usr/bin/steamcmdinstaller.sh /usr/bin/servermanager.sh /wrapper.sh \
    && apt-get clean

RUN groupadd theforest && \
    useradd -r -g theforest theforest
# USER theforest

EXPOSE ${STEAMPORT}/tcp ${STEAMPORT}/udp ${SERVERPORT}/tcp ${SERVERPORT}/udp ${QUERYPORT}/tcp ${QUERYPORT}/udp

VOLUME ["/theforest", "/steamcmd"]

CMD ["supervisord"]
