FROM archlinux:latest

RUN pacman -Syu --noconfirm
RUN pacman -S openssh sudo --noconfirm
RUN pacman -S jdk17-openjdk --noconfirm

COPY ./sudoers /etc/sudoers

RUN useradd -rm -d /home/jenkins -s /bin/bash -g root -G wheel jenkins
RUN echo 'jenkins:test' | chpasswd
RUN systemctl enable sshd.service
RUN ssh-keygen -A

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]