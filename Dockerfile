######## INSTALL ########

# Set the base image
FROM debian:12-slim

# Add non-root user (with `/home/steam` dir)
RUN \
	useradd -m -s /bin/bash steam

# Set environment variables
ENV USER="steam"
ENV HOME="/home/steam"

ARG DEBIAN_FRONTEND=noninteractive

ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"

# Set working directory
WORKDIR $HOME

# Insert Steam prompt answers
RUN \
	echo steam steam/question select "I AGREE"	| debconf-set-selections	&&\
	echo steam steam/license note ''		| debconf-set-selections

# Update the repository and install SteamCMD
COPY sources.list /etc/apt/sources.list
RUN \
	dpkg --add-architecture i386							&&\
	apt-get update -y								&&\
	apt-get install -y --no-install-recommends ca-certificates locales steamcmd	&&\
	rm -rf /var/lib/apt/lists/*

# Add unicode support
RUN \
	sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen				&&\
	locale-gen en_US.UTF-8

# Create symlink for executable
RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd

# Update SteamCMD and verify latest version
RUN steamcmd +quit

# Fix missing directories and libraries
RUN \
	mkdir -p $HOME/.steam								&&\
	ln -s $HOME/.local/share/Steam/steamcmd/linux32 $HOME/.steam/sdk32		&&\
	ln -s $HOME/.local/share/Steam/steamcmd/linux64 $HOME/.steam/sdk64		&&\
	ln -s $HOME/.steam/sdk32/steamclient.so $HOME/.steam/sdk32/steamservice.so	&&\
	ln -s $HOME/.steam/sdk64/steamclient.so $HOME/.steam/sdk64/steamservice.so

# Ensure `steam` home is owned by user `steam`
RUN \
	chown -R $USER:$USER $HOME

# Label
LABEL name="steamcmd-nonroot"
LABEL version="v0.1.0"
LABEL description="SteamCMD docker with default user as `steam`"
LABEL repository="https://github.com/ParkSnoopy/steamcmd-nonroot.git"
LABEL license="GPL-3.0"
LABEL authors="[ ParkSnoopy <117149837+ParkSnoopy@users.noreply.github.com> ]"

# Set default command
USER steam
CMD ["/usr/bin/steamcmd"]
