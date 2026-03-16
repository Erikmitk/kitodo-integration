# Stage 1: copy pre-built artifacts
FROM scratch AS kitodo-builder-local
COPY build-resources/kitodo.war /data/kitodo.war
COPY build-resources/kitodo.sql /data/kitodo.sql
COPY build-resources/modules/   /data/modules/

# Stage 2: runtime image — Tomcat 10.1 + Java 21 (matches CI)
FROM tomcat:10.1-jdk21-temurin AS kitodo

RUN apt-get update && apt-get install -y --no-install-recommends \
    imagemagick \
    default-mysql-client \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Copy build artifacts
COPY --from=kitodo-builder-local /data/kitodo.war /tmp/kitodo/kitodo.war
COPY --from=kitodo-builder-local /data/kitodo.sql /tmp/kitodo/kitodo.sql
COPY --from=kitodo-builder-local /data/modules/   /opt/kitodo/modules/

# Seed default data files (outside volume — copied into volume at first startup)
COPY kitodo-production/Kitodo/diagrams/ /opt/kitodo-seed/diagrams/
COPY kitodo-production/Kitodo/rulesets/  /opt/kitodo-seed/rulesets/
COPY kitodo-production/Kitodo/scripts/   /opt/kitodo-seed/scripts/

# Copy Flyway migration files from source
COPY kitodo-production/Kitodo-DataManagement/src/main/resources/db/migration /flyway/sql

# Copy operational scripts
COPY docker/wait-for-it.sh  /wait-for-it.sh
COPY docker/deploy.sh       /usr/bin/deploy.sh
COPY docker/startup.sh      /usr/bin/startup.sh
COPY docker/migrate.sh      /usr/bin/migrate.sh
RUN chmod +x /wait-for-it.sh /usr/bin/deploy.sh /usr/bin/startup.sh /usr/bin/migrate.sh

# Kitodo data directory structure
RUN mkdir -p \
    /usr/local/kitodo/config \
    /usr/local/kitodo/diagrams \
    /usr/local/kitodo/import \
    /usr/local/kitodo/logs \
    /usr/local/kitodo/messages \
    /usr/local/kitodo/metadata \
    /usr/local/kitodo/plugins/command \
    /usr/local/kitodo/plugins/import \
    /usr/local/kitodo/plugins/opac \
    /usr/local/kitodo/plugins/step \
    /usr/local/kitodo/plugins/validation \
    /usr/local/kitodo/rulesets \
    /usr/local/kitodo/scripts \
    /usr/local/kitodo/swap \
    /usr/local/kitodo/temp \
    /usr/local/kitodo/users

ENV DB_HOST=kitodo-db \
    DB_PORT=3306 \
    DB_NAME=kitodo \
    DB_USER=kitodo \
    DB_PASSWORD=kitodo \
    ES_HOST=kitodo-es \
    ES_PORT=9200

CMD ["/usr/bin/startup.sh"]
