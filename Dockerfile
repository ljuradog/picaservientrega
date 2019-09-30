FROM mariadb:latest
RUN apt-get update && apt-get -y install cron
ADD dump/ /docker-entrypoint-initdb.d
ADD crontab /etc/cron.d/
RUN crontab /etc/cron.d/crontab
ENV MYSQL_ROOT_PASSWORD test123
EXPOSE 3306
CMD ["mysqld"]
