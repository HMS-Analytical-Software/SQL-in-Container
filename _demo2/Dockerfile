FROM mcr.microsoft.com/mssql/server:2022-latest

# podman needs the user root explicit for using apt-get
USER root

ENV ACCEPT_EULA=Y
ENV MSSQL_PID=Developer
ENV MSSQL_SA_PASSWORD=dev_sa1337!
ENV MSSQL_COLLATION=SQL_Latin1_General_CP1_CI_AS

ARG SA_PASSWORD=dev_sa1337!
ARG SA_USER=sa

ARG TARGET_DBNAME=Northwind
ARG TARGET_TEST_DBNAME=Northwind.Test
ARG DACPACS=../src/Northwind.Tests/bin/Debug



# Prepare apt
RUN  apt-get update -y && \
     apt-get upgrade -y && \
     apt-get dist-upgrade -y && \
     apt-get -y autoremove && \
     apt-get clean

# Install essential tools & libraries
RUN apt-get install unzip && \
    apt-get install libunwind8 && \
    apt-get install libicu66

# Download special tools
## SQL Package
RUN mkdir /tools && \
    wget https://aka.ms/sqlpackage-linux -O /tools/sqlpackage-linux.zip && \
    unzip /tools/sqlpackage-linux -d /tools/sqlpackage && \
    chmod a+x /tools/sqlpackage/sqlpackage

WORKDIR /src
COPY ./src .

# Start server and create Database
RUN (/opt/mssql/bin/sqlservr & ) | grep -q "Service Broker manager has started" && \
    /opt/mssql-tools/bin/sqlcmd -S localhost -U ${SA_USER} -P ${SA_PASSWORD} -i ./instnwnd.sql && \
	/tools/sqlpackage/sqlpackage /Action:Publish /TargetConnectionString:"Server=localhost;Database=${TARGET_DBNAME};User Id=${SA_USER};Password=${SA_PASSWORD};TrustServerCertificate=true" /SourceFile:"./Northwind.dacpac" /Profile:"./Northwind.publish.xml" && \
    /opt/mssql-tools/bin/sqlcmd -S localhost -U ${SA_USER} -P ${SA_PASSWORD} -d ${TARGET_DBNAME} -i ./tSQLt.PrepareServer.sql && \
    /tools/sqlpackage/sqlpackage /Action:Publish /TargetConnectionString:"Server=localhost;Database=${TARGET_DBNAME};User Id=${SA_USER};Password=${SA_PASSWORD};TrustServerCertificate=true" /SourceFile:"./tSQLt.2022.dacpac" && \
    /tools/sqlpackage/sqlpackage /Action:Publish /TargetConnectionString:"Server=localhost;Database=${TARGET_DBNAME};User Id=${SA_USER};Password=${SA_PASSWORD};TrustServerCertificate=true" /SourceFile:"./Northwind.Tests.dacpac" /Profile:"./Northwind.Tests.publish.xml"

# https://stackoverflow.com/questions/31870222/how-can-i-keep-a-container-running-on-kubernetes    
CMD (/opt/mssql/bin/sqlservr &) && \
    exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"