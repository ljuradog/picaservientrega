# Servientrega - abc.Inc
> Entorno: Académico
> Universidad: Pontificia Universidad Javeriana
> Especialización Arquitectura de Software

El proveedor Servientrega ha determinado que la administración de ordenes de envío se hará por medio de una Base de Datos. Para poder hacer uso de este recurso, Servientrega pone a disposición el siguiente contenedor Docker, el cuál le permitirá implementar la integración.

## Características
Se hace entrega de un contenedor con la base de datos, el cual está disponible en el siguiente [enlace](https://cloud.docker.com/u/ljuradog/repository/docker/ljuradog/servientrega)

La imagen cuenta con una Base de Datos MariaDB que expone lo siguiente:
* Funcion **crear_orden**: Esta función recibe un parámetro JSON y registra en la Base de datos la información del envío y el detalle de los elementos a enviar. Por defecto las ordenes quedan con estado 0: Registrado
* Procedimiento almacenado **actualizar_orden**: Este procedimiento actualiza al siguiente estado 10 ordenes registradas en el sistema de manera aleatoria.
* **Cron**: El contenedor cuenta con un Cron, por defecto apagado, con el cual se automatiza el paso entre los estados cada 10 minutos.

## Estados del Envío
A continuación se listan los estados por los que pasa el pedido y su estado previo

* Recibido: Todas las solicitudes inician en este estado
* En Proceso: 5 Solicitudes al azar pasa de Recibido a este estado
* Devuelto: 1 Solicitud al azar pasa de En Proceso a este estado
* Entregado: 3 Solicitudes al azar pasa de En Proceso a este estado

### Siguientes Realeases
* [04/10/19] Se entregará una función que permite consultar hasta 100 ordenes registradas en el sistema de acuerdo a unos filtros establecidos.

## Installation
Se debe realizar en primera medida la descarga de la imagen 
```sh
$ docker pull ljuradog/servientrega
```
El siguiente comando a continuación es para ejecutar el contenedor por primera vez 
```sh
$ docker run --name <nombre contenedor> -p <puerto expuesto>:3306 -d servientrega:latest
```
Donde los parametros son como se describen a continuación:
* **\<nombre contenedor\>**: Es el nombre con el que va a identificar al contenedor en adelante
* **\<puerto expuesto\>**: Puerto por el cual puede realizar la conexión desde un Gestor de Base de datos o desde la propia aplicación
Para el caso en el que el contenedor se llame **servientrega** y conservemos el mismo puerto que está exponiendo el contenedor, **3306**, el comando a ejecutar la primera vez es:
```sh
$ docker run --name servientrega -p 3306:3306 -d servientrega:latest
```
Para detener el contenedor la línea de comando es:
```sh
$ docker container stop servientrega
```
Para volver a iniciar el contenedor la línea de comando es:
```sh
$ docker container start servientrega
```
## Conexión y Uso
### Usuarios y roles
Los usuarios para la imagen compartida son:
* **root**: Usuario administrador que para los entornos de pruebas estará disponible
* **user**: Usuario entregado a la compañía kallsonys para el proceso de integración. Este será el único usuario disponible para la salida en producción y sus alcances son limitados.

Las credenciales son:

|Usuario|Password|
|------|------|
|root|abc123|
|user|123456|

La contraseña del root puede ser seteada por medio de la línea de ambiente MYSQL_ROOT_PASSWORD. En este caso no respetará la contraseña indicada en este manual.

### Funciones.
#### crear_orden
Para crear Orden se recomienda ejecutar el script de la siguiente manera.
```sql
SET @params := JSON_OBJECT(
	'orden', '35',
	'nombre', 'Marco',
	'apellido', 'Suarez',
	'items', JSON_ARRAY(
	    JSON_OBJECT(
			'item_id', 'a1',
			'producto_id', '12',
			'nombre_producto', 'DVD Blue Ray - SONY',
			'part_num', 's/n 98759955',
			'precio', '3401.1',
			'cantidad', '10'
		), 
		JSON_OBJECT(
			'item_id', 'a2',
			'producto_id', '67',
			'nombre_producto', 'Campana cocina - CHALLENGER',
			'part_num', 's/n 98759955',
			'precio', '15401.1',
			'cantidad', '12'
		)
	)
);

SELECT kallsonys.crear_orden(@params);
```
#### actualizar_orden
En caso de que requieran ejecutar manualmente el cambio de estado de las ordenes, esto se puede hacer a través de la línea de comando de la siguiente manera:
```bash
$ user@localhost:/# docker exec -it servientrega bash
$ root@ffd8642876c1:/# mysql --user=user --password=123456 kallsonys --execute "call kallsonys.actualizar_orden();"
```
