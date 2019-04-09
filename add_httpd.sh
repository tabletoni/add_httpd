##########################
#
# CREACION DE SERVICIO SYSTEMD HTTP
# 
# V2.2
# 
# - Preparado para Webgate 11G
#
##########################

if [ "$EUID" -ne 0 ]
  then echo "Debe ejecutarse con permisos root"
  exit
fi

echo "================================"
echo "Creacion de nueva instancia http"
echo "================================"


# Recogida de datos

while [ "$DOMINIO" != "i" ] && [ "$DOMINIO" != "g" ] && [ "$DOMINIO" != "p" ]  && [ "$DOMINIO" != "n" ]; do
       read -p "Dominio [i] intranet.gasnaturalfenosa.com [g] gasnaturalfenosa.com [n] net.gasnaturalfenosa.com [p] preproduccion.intranet.gasnaturalfenosa.com : " DOMINIO
done

if [ $DOMINIO == "i" ]; then
 SUFIJO="intranet.gasnaturalfenosa.com"
fi
if [ $DOMINIO == "g" ]; then
 SUFIJO="gasnaturalfenosa.com"
fi
if [ $DOMINIO == "p" ]; then
 SUFIJO="preproduccion.intranet.gasnaturalfenosa.com"
fi
if [ $DOMINIO == "n" ]; then
 SUFIJO="net.gasnaturalfenosa.com"
fi

while [ "$SSL" != "s" ] && [ "$SSL" != "n" ]; do
        read -p "Configurar como SSL? [s|n]: " SSL
done

read -p "Nombre DNS (sin dominio): " DNS
read -p "Nombre aplicacion: " APP
read -p "Puerto HTTP: " HTTP_PORT
if [ $SSL == "s" ]; then
        read -p "Puerto HTTPS: " HTTPS_PORT
fi
read -p "Cluster WL: " WL
read -p "Contexto WL ( sin /): " CONTEXTO

while [ "$CORTESIA" != "s" ] && [ "$CORTESIA" != "n" ]; do
        read -p "Configurar pagina de cortesia? [s|n]: " CORTESIA
done

while [ "$WEBGATE" != "s" ] && [ "$WEBGATE" != "n" ]; do
        read -p "Configurar Webgate? [s|n]: " WEBGATE
done


#HTTP_CONF=/opt/rh/httpd24/etc/httpd/conf/${DNS}.${SUFIJO}
HTTP_CONF=/etc/httpd/conf/${DNS}.${SUFIJO}

# Funciones

function ssl {
        cp ./files/ssl-app.conf ${HTTP_CONF}/ssl-${APP}.conf
        echo "Include ${HTTP_CONF}/ssl-${APP}.conf" >> ${HTTP_CONF}/httpd-${APP}.conf
        mkdir -p  /logs/apache/${DNS}.${SUFIJO}/ssl
        sed -i "s/_HTTPS_PORT_/${HTTPS_PORT}/g" ${HTTP_CONF}/ssl-${APP}.conf
        cat files/rewrite_ssl.txt >> ${HTTP_CONF}/httpd-${APP}.conf
}


function plain {
        cp ./files/plain-app.conf ${HTTP_CONF}/${APP}.conf
        echo "Include ${HTTP_CONF}/${APP}.conf" >> ${HTTP_CONF}/httpd-${APP}.conf
        mkdir -p  /logs/apache/${DNS}.${SUFIJO}/http
}

function cortesia {
        cp ./files/cortesia.conf ${HTTP_CONF}
        echo "Include ${HTTP_CONF}/cortesia.conf" >> ${HTTP_CONF}/httpd-${APP}.conf
}

function webgate {
	cp ./files/webgate.conf ${HTTP_CONF}
        echo "Include ${HTTP_CONF}/webgate.conf" >> ${HTTP_CONF}/httpd-${APP}.conf	
}
# Creamos carpetas de logs, estaticos y configuracion

mkdir -p /estaticos/${DNS}.${SUFIJO}
mkdir /estaticos/${DNS}.${SUFIJO}/monitor
mkdir /estaticos/${DNS}.${SUFIJO}/mantenimiento
mkdir ${HTTP_CONF}


cp ./files/weblogic_app.conf ${HTTP_CONF}/weblogic_${APP}.conf
cp ./files/httpd-app.service /usr/lib/systemd/system/httpd-${APP}.service
cp ./files/httpd-app.conf ${HTTP_CONF}/httpd-${APP}.conf
cp ./files/checkDO.html /estaticos/${DNS}.${SUFIJO}/monitor

if [ "$SSL" == "s" ]; then
        ssl
else    plain
fi
if [ "$CORTESIA" == "s" ]; then
      	cortesia
fi
if [ "$WEBGATE" == "s" ]; then
        webgate
fi
chown -R admweb.  /logs/apache/${DNS}.${SUFIJO}
chmod -R 775 /logs/apache/${DNS}.${SUFIJO}


# Parseamos y copiamos los ficheros de configuracion

sed -i "s/_DNS_/${DNS}/g" ${HTTP_CONF}/*.conf /usr/lib/systemd/system/httpd-${APP}.service
sed -i "s/_APP_/${APP}/g"  ${HTTP_CONF}/*.conf /usr/lib/systemd/system/httpd-${APP}.service
sed -i "s/_WL_/${WL}/g" ${HTTP_CONF}/*.conf
sed -i "s/_CONTEXTO_/${CONTEXTO}/g" ${HTTP_CONF}/*.conf
sed -i "s/_SUFIJO_/${SUFIJO}/g" ${HTTP_CONF}/*.conf /usr/lib/systemd/system/httpd-${APP}.service
sed -i "s/_HTTP_PORT_/${HTTP_PORT}/g" ${HTTP_CONF}/*.conf

# Levantamos el servicio

echo "Iniciando apache..."
systemctl enable httpd-${APP}.service
systemctl start httpd-${APP}.service
systemctl status httpd-${APP}.service
