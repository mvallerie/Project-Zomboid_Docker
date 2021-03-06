FROM cm2network/steamcmd:latest

MAINTAINER TuRzAm

# Server Name
ENV SERVERNAME "servertest"
# Admin DB Password (required for the first launch)
ENV ADMINPASSWORD "adminpassword"
# Rcon Password (used to quit the server)
ENV RCON_PASSWORD "rconpassword"
# Steam port
ENV STEAMPORT1  8766
ENV STEAMPORT2  8767
# Game port
ENV GAMEPORT   16261

USER root

# Compiling rcon.c
RUN apt-get update && apt-get install -y gcc
COPY ./rcon.c /home/steam/rcon.c
RUN gcc -o /home/steam/rcon /home/steam/rcon.c
RUN apt-get remove -y --purge gcc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy & rights to folders
COPY update.sh /home/steam/update.sh

RUN chmod 777 /home/steam/update.sh
RUN chmod 777 /home/steam/rcon
RUN mkdir -p /home/steam/Zomboid && chown -R steam /home/steam/Zomboid
RUN mkdir -p /home/steam/projectzomboid && chown -R steam /home/steam/projectzomboid
# Create slink
RUN ln -s /home/steam/projectzomboid /server-files && chown -R steam /server-files
RUN ln -s /home/steam/Zomboid /server-data && chown -R steam /server-data

USER steam

# First run is on anonymous to download the app
RUN /home/steam/steamcmd/steamcmd.sh +login anonymous +quit

# Make server port available to host : (10 slots)
# 8766,8767 : steamport
# 16261 : server port : tcp
# 27015 : Rcon port
EXPOSE ${STEAMPORT1}
EXPOSE ${STEAMPORT2}
EXPOSE ${GAMEPORT}
EXPOSE 27015

# /home/steam/Zomboid : Server Data
# /home/steam/projectzomboid : Server files & exe
#VOLUME [ "/home/steam/Zomboid" , "/home/steam/projectzomboid" ]
VOLUME /server-files
VOLUME /server-data

# Update game (with credential) && launch the game.
ENTRYPOINT ["/home/steam/update.sh"]
