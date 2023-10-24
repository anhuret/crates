FROM fedora

ENV GOPRIVATE="github.com/anhuret,gitlab.com/onuris"
ENV CGO_ENABLED="0"

ARG VERS
ARG NAME
ARG UIDN

LABEL name=$NAME
LABEL version=$VERS
LABEL description="GO and JS development environmant"
LABEL maintainer="Ruslan Sendecky <r.sendecky@gmail.com>"

RUN dnf -y --setopt=install_weak_deps=False install go git neovim tmux nodejs yarnpkg openssh fish
RUN dnf -y clean all
RUN ln -sf /usr/bin/nvim /usr/bin/nv
RUN ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime

RUN useradd -m $UIDN && usermod -a -G wheel $UIDN
RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nopass

USER $UIDN
WORKDIR /home/$UIDN

RUN ssh-keygen -q -f ~/.ssh/id_rsa -t ed25519 -N ''

RUN mkdir -p ~/.config/nvim/ ~/.local/share/nvim/site/plugins
COPY fragments/nvim/init.vim .config/nvim/
RUN curl -sfLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN nvim --headless +PlugInstall +qa &> /dev/null && \
    nvim --headless +GoInstallBinaries +qa &> /dev/null
RUN yarn global add prettier

COPY fragments/home/profile .bash_profile
COPY fragments/home/tmux.conf .tmux.conf
COPY fragments/home/gitconfig .gitconfig
COPY fragments/fish/ .config/fish/functions/

USER root

RUN chown -R $UIDN:$UIDN /home/$UIDN

USER $UIDN

CMD ["/bin/bash", "-l"]
