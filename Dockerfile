FROM mariadb:latest
ADD dump/ /docker-entrypoint-initdb.d
ENV MYSQL_ROOT_PASSWORD test123
RUN apt-get update && apt-get -y install vim
EXPOSE 3306
CMD ["mysqld"]
