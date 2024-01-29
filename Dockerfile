FROM docker.io/library/archlinux:latest

# update and install sudo git base-devel
RUN pacman -Syu --noconfirm && \
  pacman -S --noconfirm sudo git base-devel

# create user al with password al and create home directory
RUN useradd -m -p $(openssl passwd -1 al) al

# add user al to sudoers
RUN echo "al ALL=(ALL) ALL" >> /etc/sudoers

# no sudo password for user al
RUN echo "al ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# switch to user al
USER al

# switch to home directory
WORKDIR /home/al

# install nix
RUN sh <(curl -L https://nixos.org/nix/install) --no-daemon --yes 

# install yay
RUN echo "adding chaotic-aur repository" && \
  git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && \
  makepkg -si --noconfirm && \
  cd .. && \
  rm -rf yay-bin

# add chaotic-aur repository
RUN echo "adding chaotic-aur repository" && \
  sudo pacman-key --init && \
  sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com && \
  sudo pacman-key --lsign-key 3056513887B78AEB && \
  sudo pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' && \
  sudo pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' && \
  echo -e "[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n" | sudo tee -a /etc/pacman.conf && \
  echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" | sudo tee -a /etc/pacman.conf && \
  sudo pacman -Syu --noconfirm

