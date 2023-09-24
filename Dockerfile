# Usamos una imagen base de Java 8, compatible con Spark 1.X
FROM openjdk:8-jdk-slim

# Establecemos algunas variables de entorno
ENV SPARK_VERSION=1.5.2
ENV SPARK_HOME=/opt/spark

# Actualizamos e instalamos las dependencias iniciales
RUN apt-get update && \
    apt-get install -y wget scala apt-transport-https gnupg2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Instalamos Spark
RUN wget https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop2.6.tgz && \
    tar -xzvf spark-$SPARK_VERSION-bin-hadoop2.6.tgz && \
    mv spark-$SPARK_VERSION-bin-hadoop2.6 /opt/spark && \
    rm spark-$SPARK_VERSION-bin-hadoop2.6.tgz 

# Configuramos SBT
RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 && \
    apt-get update && \
    apt-get install -y sbt && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Añadimos spark/bin al PATH
ENV PATH=$SPARK_HOME/bin:$PATH

# Copiamos el programa, el archivo de datos y el archivo build.sbt al contenedor
COPY wordcount.scala /app/wordcount.scala
COPY movies.csv /data/movies.csv
COPY build.sbt /app/build.sbt

# Establecemos el directorio de trabajo
WORKDIR /app

# Compilamos el programa WordCount
RUN sbt package

