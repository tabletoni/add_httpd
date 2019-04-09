
echo "Creacion de un vhost simple"
echo "======================================="
read -p "Nombre DNS (sin asnaturalfenosa.com): " DNS
read -p "Nombre aplicacion: " APP
read -p "Cluster WL: " WL
read -p "Contexto WL (sin /): " CONTEXTO

SUFIJO="gasnaturalfenosa.com"

# Creamos carpetas de logs  y configuracion

mkdir -p /estaticos/${DNS}.${SUFIJO}

mkdir -p  /logs/apache/${DNS}.${SUFIJO}/http
chown -R admweb.  /logs/apache/${DNS}.${SUFIJO}
chmod -R 775 /logs/apache/${DNS}.${SUFIJO}

mkdir /etc/httpd/conf/${DNS}.${SUFIJO}
cp ./files/weblogic_app.conf /etc/httpd/conf/${DNS}.${SUFIJO}/weblogic_${APP}.conf
cp ./files/vhost.conf /etc/httpd/conf/${DNS}.${SUFIJO}/${APP}.conf

# Parseamos y copiamos los ficheros de configuracion

sed -i "s/_DNS_/${DNS}/g" /etc/httpd/conf/${DNS}.${SUFIJO}/*
sed -i "s/_APP_/${APP}/g"  /etc/httpd/conf/${DNS}.${SUFIJO}/* 
sed -i "s/_WL_/${WL}/g" /etc/httpd/conf/${DNS}.${SUFIJO}/*
sed -i "s/_CONTEXTO_/${CONTEXTO}/g" /etc/httpd/conf/${DNS}.${SUFIJO}/*
sed -i "s/_SUFIJO_/${SUFIJO}/g" /etc/httpd/conf/${DNS}.${SUFIJO}/* 
sed -i "s/_HTTP_PORT_/${HTTP_PORT}/g" /etc/httpd/conf/${DNS}.${SUFIJO}/*

cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.`date '+%Y%m%d'`
echo $'\n'# ${APP}$'\n' >> /etc/httpd/conf/httpd.conf
echo Include /etc/httpd/conf/${DNS}.${SUFIJO}/${APP}.conf >> /etc/httpd/conf/httpd.conf
echo "Si lleva OAM, recuerda configurar Webgate"

