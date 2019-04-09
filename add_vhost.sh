
echo "Creacion de un vhost simple"
echo "Incluye en httpd.conf con la configuracion de un vhost en el puerto 80, a partir de la plantilla ./files/vhost.conf"
echo "Crea la configuracion http y las carpetas de logs y estaticas"
echo "======================================="

while [ "$DOMINIO" != "i" ] && [ "$DOMINIO" != "g" ] && [ "$DOMINIO" != "p" ]  && [ "$DOMINIO" != "n" ]; do
        read -p "Dominio [i] intranet.gasnaturalfenosa.com [g] gasnaturalfenosa.com [n] net.gasnaturalfenosa.com [p] preproduccion.intranet.gasnaturalfenosa.com :" DOMINIO
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
        read -p "Configurar como SSL? [s|n] :" SSL
done


function ssl {
        cp ./files/ssl-app.conf ${HTTP_CONF}/ssl-${APP}.conf
        echo "Include ${HTTP_CONF}/ssl-${APP}.conf" >> ${HTTP_CONF}/${APP}.conf
        mkdir -p  /logs/apache/${DNS}.${SUFIJO}/ssl
        sed -i "s/_HTTPS_PORT_/${HTTPS_PORT}/g" ${HTTP_CONF}/ssl-${APP}.conf
        cat files/rewrite_ssl.txt >> ${HTTP_CONF}/${APP}.conf
}


function plain {
        cp ./files/plain-app.conf ${HTTP_CONF}/${APP}.conf
        echo "Include ${HTTP_CONF}/${APP}.conf" >> ${HTTP_CONF}/httpd-${APP}.conf
        mkdir -p  /logs/apache/${DNS}.${SUFIJO}/http
}

read -p "Nombre DNS (sin intranet.gasnaturalfenosa.com): " DNS
read -p "Nombre aplicacion: " APP
read -p "Cluster WL: " WL
read -p "Contexto WL (sin /): " CONTEXTO


# Creamos carpetas de logs, estaticos y configuracion

mkdir -p /estaticos/${DNS}.${SUFIJO}

mkdir -p  /logs/apache/${DNS}.${SUFIJO}/http
chown -R admweb.  /logs/apache/${DNS}.${SUFIJO}
chmod -R 775 /logs/apache/${DNS}.${SUFIJO}

mkdir /etc/httpd/conf/${DNS}.${SUFIJO}

# Copiamos las plantillas con las variables

cp ./files/weblogic_app.conf /etc/httpd/conf/${DNS}.${SUFIJO}/weblogic_${APP}.conf
cp ./files/cortesia.conf /etc/httpd/conf/${DNS}.${SUFIJO}/cortesia.conf
cp ./files/vhost.conf /etc/httpd/conf/${DNS}.${SUFIJO}/${APP}.conf

# Parseamos los ficheros de configuracion

sed -i "s/_DNS_/${DNS}/g" /etc/httpd/conf/${DNS}.${SUFIJO}/* /etc/httpd/conf/${DNS}.${SUFIJO}/cortesia.conf
sed -i "s/_APP_/${APP}/g"  /etc/httpd/conf/${DNS}.${SUFIJO}/* /etc/httpd/conf/${DNS}.${SUFIJO}/cortesia.conf
sed -i "s/_WL_/${WL}/g" /etc/httpd/conf/${DNS}.${SUFIJO}/*
sed -i "s/_CONTEXTO_/${CONTEXTO}/g" /etc/httpd/conf/${DNS}.${SUFIJO}/*
sed -i "s/_SUFIJO_/${SUFIJO}/g" /etc/httpd/conf/${DNS}.${SUFIJO}/* /etc/httpd/conf/${DNS}.${SUFIJO}/cortesia.conf
sed -i "s/_HTTP_PORT_/${HTTP_PORT}/g" /etc/httpd/conf/${DNS}.${SUFIJO}/*

#  Backup de httpd.conf y añade el Include
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.`date '+%Y%m%d'`
echo $'\n'# ${APP}$'\n' >> /etc/httpd/conf/httpd.conf
echo Include /etc/httpd/conf/${DNS}.${SUFIJO}/${APP}.conf >> /etc/httpd/conf/httpd.conf
echo "Configuracion para ${APP} creada. Recuerda configurar Webgate en httpd.conf y reiniciar el servicio httpd"

