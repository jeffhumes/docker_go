FROM ubuntu

LABEL maintainer="jhumes@ti.com"

SHELL ["/bin/bash", "-c"]

ARG UID
ARG GID
ARG USR
ARG IMG_USR_HOME
ARG IMG_USR_SHELL
ARG OS_UPDATES
ARG EXTRA_PACKAGES
ARG INSTALL_TYPE

ARG CHROME_REMOTE
ARG CHROME_REMOTE_DESKTOP

RUN if [[ "${OS_UPDATES}" = "true" ]] || [[ "${EXTRA_PACKAGES}" = "true" ]]; then apt-get update; fi
RUN if [[ "${OS_UPDATES}" = "true" ]]; then apt-get -y upgrade; fi
RUN if [[ "${EXTRA_PACKAGES}" = "true" ]]; then apt-get -y install sudo vim git curl; fi
RUN if [[ "${EXTRA_PACKAGES}" = "true" ]]; then sed -i 's/%sudo.*$/%sudo  ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers; fi


RUN if [[ "${CHROME_REMOTE}" = "true" ]]; then \
        curl -L -o chrome-remote-desktop_current_amd64.deb https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb && \
        export DEBIAN_FRONTEND=noninteractive && \
         apt-get install --assume-yes ./chrome-remote-desktop_current_amd64.deb; fi

RUN if [[ "${CHROME_REMOTE}" = "true" ]] && [[ "${CHROME_REMOTE_DESKTOP}" = "XFCE" ]]; then \
        export DEBIAN_FRONTEND=noninteractive && \
        apt install --assume-yes xfce4 desktop-base dbus-x11 xscreensaver && \
        echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session; fi

RUN if [[ "${CHROME_REMOTE}" = "true" ]] && [[ "${CHROME_REMOTE_DESKTOP}" = "CINNAMON" ]]; then \
        export DEBIAN_FRONTEND=noninteractive && \
        apt install --assume-yes cinnamon-core desktop-base dbus-x11 && \
        echo "exec /etc/X11/Xsession /usr/bin/cinnamon-session-cinnamon2d" > /etc/chrome-remote-desktop-session; fi

RUN if [[ "${CHROME_REMOTE}" = "true" ]] && [[ "${CHROME_REMOTE_DESKTOP}" = "GNOME" ]]; then \
        export DEBIAN_FRONTEND=noninteractive && \
        apt install --assume-yes task-gnome-desktop && \
        echo "exec /etc/X11/Xsession /usr/bin/gnome-session" > /etc/chrome-remote-desktop-session && \
        systemctl disable gdm3.service; fi

RUN if [[ "${CHROME_REMOTE}" = "true" ]] && [[ "${CHROME_REMOTE_DESKTOP}" = "GNOME_CLASSIC" ]]; then \
        export DEBIAN_FRONTEND=noninteractive && \
        apt install --assume-yes task-gnome-desktop && \
        echo "exec /etc/X11/Xsession /usr/bin/gnome-session-classic" > /etc/chrome-remote-desktop-session && \
        systemctl disable gdm3.service; fi

RUN if [[ "${CHROME_REMOTE}" = "true" ]] && [[ "${CHROME_REMOTE_DESKTOP}" = "KDE_PLASMA" ]]; then \
        export DEBIAN_FRONTEND=noninteractive && \
        apt install --assume-yes task-kde-desktop && \
        echo "exec /etc/X11/Xsession /usr/bin/startplasma-x11" > /etc/chrome-remote-desktop-session; fi


RUN if [[ "${USR}" != "root"  ]]; then groupadd -g "${GID}" "${USR}"; else noop=1; fi
RUN if [[ "${USR}" != "root"  ]]; then useradd -u "${UID}" -g "${GID}" -m -d ${IMG_USR_HOME} -s ${IMG_USR_SHELL} ${USR}; else noop=1; fi
RUN if [[ "${USR}" != "root" ]]; then usermod -aG sudo ${USR}; fi

RUN     if [[ "${CHROME_REMOTE}" = "true" ]]; then \
                mkdir -p ${IMG_USR_HOME}/.config/chrome-remote-desktop && \
                chown ${USR}:${USR} ${IMG_USR_HOME}/.config/chrome-remote-desktop && \
                chmod a+rx ${IMG_USR_HOME}/.config/chrome-remote-desktop && \
                touch ${IMG_USR_HOME}/.config/chrome-remote-desktop/host.json && \
                touch ${IMG_USR_HOME}/.chrome-remote-desktop-session && \
                echo "/usr/bin/pulseaudio --start" >> ${IMG_USR_HOME}/.chrome-remote-desktop-session && \
                echo "startxfce4 :1030" >> ${IMG_USR_HOME}/.chrome-remote-desktop-session; fi



#COPY if [[ "${INSTALL_TYPE}" = "tomcat" ]]; then  dist/manager-context.xml /usr/local/tomcat/webapps/manager/META-INF/context.xml; else noop=1; fi
#COPY if [[ "${INSTALL_TYPE}" = "tomcat" ]]; then dist/manager-web.xml /usr/local/tomcat/webapps/manager/WEB-INF/web.xml; else noop=1; fi

RUN if [[ "${INSTALL_TYPE}" = "tomcat" ]]; then \
        rm -fr /usr/local/tomcat/webapps/examples && \
        rm -fr /usr/local/tomcat/webapps/docs && \
        mkdir /usr/local/tomcat/properties && \
        chown -R ${USR}:${USR} /usr/local/tomcat && \
        chown -R ${USR}:${USR} /opt/java; fi

RUN if [[ "${INSTALL_TYPE}" = "gitlab" ]]; then \
        chown -R ${USR}:${USR} /var/opt/gitlab && \
        chown -R ${USR}:${USR} /etc/gitlab; fi

ARG COMPANY

# the following are TI specific, not needed outside TI
RUN if [[ "${INSTALL_TYPE}" = "tomcat" ]] && [[ "${COMPANY}" = "TI" ]]; then \
        mkdir /usr/local/tomcat/tempcerts && \
        openssl s_client -connect ubid-prod.itg.ti.com:636 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /usr/local/tomcat/tempcerts/ubid-prod.itg.ti.com.crt && \
        cd $JAVA_HOME/conf/security && \
        keytool -cacerts -storepass changeit -noprompt -trustcacerts -importcert -alias ldapcert -file /usr/local/tomcat/tempcerts/ubid-prod.itg.ti.com.crt; fi

USER ${USR}
