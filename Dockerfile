#tomcat image provided from docker.io
FROM ubuntu

LABEL maintainer="jhumes@ti.com"

ARG UID
ARG GID
ARG USR
ARG IMG_USR_HOME
ARG IMG_USR_SHELL
ARG INSTALL_TYPE
ARG COMPANY
ARG CHROME_REMOTE
ARG CHROME_REMOTE_DESKTOP
ARG OS_UPDATES
ARG EXTRA_PACKAGES

SHELL ["/bin/bash", "-c"]

RUN if [[ "${OS_UPDATES}" = "true" ]] || [[ "${EXTRA_PACKAGES}" = "true" ]]; then apt-get update; fi 
RUN if [[ "${OS_UPDATES}" = "true" ]]; then apt-get -y upgrade; fi 
RUN if [[ "${EXTRA_PACKAGES}" = "true" ]]; then apt-get -y install sudo; fi
RUN if [[ "${EXTRA_PACKAGES}" = "true" ]]; then apt-get -y install vim; fi
RUN if [[ "${EXTRA_PACKAGES}" = "true" ]]; then apt-get -y install git; fi
RUN if [[ "${EXTRA_PACKAGES}" = "true" ]]; then apt-get -y install curl; fi
RUN if [[ "${EXTRA_PACKAGES}" = "true" ]]; then sed -i 's/%sudo.*$/%sudo  ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers; fi

RUN if [[ "${USR}" != "root"  ]]; then groupadd -g "${GID}" "${USR}"; else noop=1; fi
RUN if [[ "${USR}" != "root"  ]]; then useradd -u "${UID}" -g "${GID}" -d ${IMG_USR_HOME} -s ${IMG_USR_SHELL} ${USR}; else noop=1; fi
RUN if [[ "${USR}" != "root" ]]; then usermod -aG sudo ${USR}; fi

RUN if [[ "${CHROME_REMOTE}" = "true" ]]; then echo "will install Chrome Remote Desktop"; fi
RUN if [[ "${CHROME_REMOTE}" = "true" ]]; then curl -L -o chrome-remote-desktop_current_amd64.deb https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb; fi
RUN if [[ "${CHROME_REMOTE}" = "true" ]]; then export DEBIAN_FRONTEND=noninteractive && apt-get install --assume-yes ./chrome-remote-desktop_current_amd64.deb; fi
RUN if [[ "${CHROME_REMOTE}" = "true" ]] && [[ "${CHROME_REMOTE_DESKTOP}" = "XFCE" ]]; then export DEBIAN_FRONTEND=noninteractive && apt install --assume-yes xfce4 desktop-base dbus-x11 xscreensaver; fi
RUN if [[ "${CHROME_REMOTE}" = "true" ]] && [[ "${CHROME_REMOTE_DESKTOP}" = "CINNAMON" ]]; then export DEBIAN_FRONTEND=noninteractive && apt install --assume-yes cinnamon-core desktop-base dbus-x11; fi
RUN if [[ "${CHROME_REMOTE}" = "true" ]] && [[ "${CHROME_REMOTE_DESKTOP}" = "CINNAMON" ]]; then export DEBIAN_FRONTEND=noninteractive && echo "exec /etc/X11/Xsession /usr/bin/cinnamon-session-cinnamon2d" > /etc/chrome-remote-desktop-session; fi
RUN if [[ "${CHROME_REMOTE}" = "true" ]] && [[ "${CHROME_REMOTE_DESKTOP}" = "GNOME" ]]; then export DEBIAN_FRONTEND=noninteractive && apt install --assume-yes  task-gnome-desktop; fi
RUN if [[ "${CHROME_REMOTE}" = "true" ]] && [[ "${CHROME_REMOTE_DESKTOP}" = "GNOME_CLASSIC" ]]; then export DEBIAN_FRONTEND=noninteractive && apt install --assume-yes  task-gnome-desktop; fi
RUN if [[ "${CHROME_REMOTE}" = "true" ]] && [[ "${CHROME_REMOTE_DESKTOP}" = "KDE_PLASMA" ]]; then export DEBIAN_FRONTEND=noninteractive && apt install --assume-yes  task-kde-desktop; fi
 

#COPY if [[ "${INSTALL_TYPE}" = "tomcat" ]]; then  dist/manager-context.xml /usr/local/tomcat/webapps/manager/META-INF/context.xml; else noop=1; fi
#COPY if [[ "${INSTALL_TYPE}" = "tomcat" ]]; then dist/manager-web.xml /usr/local/tomcat/webapps/manager/WEB-INF/web.xml; else noop=1; fi
#RUN if [[ "${INSTALL_TYPE}" = "tomcat" ]]; then rm -fr /usr/local/tomcat/webapps/examples; else noop=1; fi
#RUN if [[ "${INSTALL_TYPE}" = "tomcat" ]]; then rm -fr /usr/local/tomcat/webapps/docs; else noop=1; fi
#RUN if [[ "${INSTALL_TYPE}" = "tomcat" ]]; then mkdir /usr/local/tomcat/properties; else noop=1; fi
#RUN if [[ "${INSTALL_TYPE}" = "tomcat" ]]; then chown -R ${USR}:${USR} /usr/local/tomcat; else noop=1; fi
#RUN if [[ "${INSTALL_TYPE}" = "tomcat" ]]; then chown -R ${USR}:${USR} /opt/java else; noop=1; fi
#
#RUN if [[ "${INSTALL_TYPE}" = "gitlab" ]]; then chown -R ${USR}:${USR} /var/opt/gitlab; else noop=1; fi
#RUN if [[ "${INSTALL_TYPE}" = "gitlab" ]]; then chown -R ${USR}:${USR} /etc/gitlab; else noop=1; fi

## the following are TI specific, not needed outside TI
##RUN if [[ "${INSTALL_TYPE}" = "tomcat" ]] && [[ "${COMPANY}" = "TI" ]]; then mkdir /usr/local/tomcat/tempcerts; fi
#RUN if [[ "${INSTALL_TYPE}" = "tomcat" ]] && [[ "${COMPANY}" = "TI" ]]; then openssl s_client -connect ubid-prod.itg.ti.com:636 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /usr/local/tomcat/tempcerts/ubid-prod.itg.ti.com.crt; ls -lart /usr/local/tomcat/tempcerts; fi
#RUN if [[ "${INSTALL_TYPE}" = "tomcat" ]] && [[ "${COMPANY}" = "TI" ]]; then cd $JAVA_HOME/conf/security && keytool -cacerts -storepass changeit -noprompt -trustcacerts -importcert -alias ldapcert -file /usr/local/tomcat/tempcerts/ubid-prod.itg.ti.com.crt; fi

USER ${USR}
