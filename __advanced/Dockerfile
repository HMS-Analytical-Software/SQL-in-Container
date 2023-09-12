FROM mcr.microsoft.com/mssql/server:2022-latest

# podman needs the user root explicit for using apt-get
USER root

ARG SOURCE_CONNECTION_STR="Server=tcp:ssudemosssqlserver.database.windows.net,1433;Initial Catalog=ssudemosql;Persist Security Info=False;User ID=ssuadmin;Password=ssu5admin1337!;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Integrated Security=False"
ARG SA_PASSWORD=dev_sa1337!
ARG SA_USER=sa
ARG MSSQL_COLLATION=SQL_Latin1_General_CP1_CI_AS
ARG TARGET_DBNAME=Northwind
ARG DACPACS=./src/Northwind.Tests/bin/Debug

ENV ACCEPT_EULA=Y
ENV MSSQL_PID=Developer
ENV MSSQL_TCP_PORT=1433

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
RUN mkdir ./tools
RUN wget https://aka.ms/sqlpackage-linux -O ./tools/sqlpackage-linux.zip
RUN unzip ./tools/sqlpackage-linux -d ./tools/sqlpackage && \
    chmod a+x ./tools/sqlpackage/sqlpackage

# Copy Content to image
COPY ./${DACPACS}/ ./dacpacs/
COPY ./src/Externals ./src/Externals

RUN ./tools/sqlpackage/sqlpackage /Action:Export /SourceConnectionString:"${SOURCE_CONNECTION_STR}" /TargetFile:"./dacpacs/Northwind.Master.bacpac"

# Start server and create Database
RUN (/opt/mssql/bin/sqlservr & ) | grep -q "Service Broker manager has started" && \
    ./tools/sqlpackage/sqlpackage /Action:Import /TargetConnectionString:"Server=localhost;Database=${TARGET_DBNAME};User Id=${SA_USER};Password=${SA_PASSWORD};TrustServerCertificate=true" /SourceFile:"./dacpacs/Northwind.Master.bacpac" && \
	./tools/sqlpackage/sqlpackage /Action:Publish /TargetConnectionString:"Server=localhost;Database=${TARGET_DBNAME};User Id=${SA_USER};Password=${SA_PASSWORD};TrustServerCertificate=true" /SourceFile:"./dacpacs/Northwind.dacpac" /Profile:"./dacpacs/Northwind.publish.xml" && \
    /opt/mssql-tools/bin/sqlcmd -S localhost -U ${SA_USER} -P ${SA_PASSWORD} -d ${TARGET_DBNAME} -i ./src/Externals/tSQLt.PrepareServer.sql && \
    ./tools/sqlpackage/sqlpackage /Action:Publish /TargetConnectionString:"Server=localhost;Database=${TARGET_DBNAME};User Id=${SA_USER};Password=${SA_PASSWORD};TrustServerCertificate=true" /SourceFile:"./dacpacs/tSQLt.2022.dacpac" && \
    ./tools/sqlpackage/sqlpackage /Action:Publish /TargetConnectionString:"Server=localhost;Database=${TARGET_DBNAME};User Id=${SA_USER};Password=${SA_PASSWORD};TrustServerCertificate=true" /SourceFile:"./dacpacs/Northwind.Tests.dacpac" /Profile:"./dacpacs/Northwind.Tests.publish.xml"

# https://stackoverflow.com/questions/31870222/how-can-i-keep-a-container-running-on-kubernetes    
CMD (/opt/mssql/bin/sqlservr &) && \
    exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"