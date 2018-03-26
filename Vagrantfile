# frozen_string_literal: true

Vagrant.configure('2') do |config|
  config.vm.box = 'generic/debian9'
  config.vm.network :forwarded_port, guest: 3000, host: 3000

  config.vm.synced_folder '.', '/home/vagrant/app'
  config.ssh.forward_agent = true

  config.vm.provision 'shell', privileged: false, inline: <<~SHELL
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update
    sudo apt-get -qq install -y autoconf bison build-essential libssl-dev \
      libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev \
      libgdbm3 libgdbm-dev git-core postgresql-9.6 postgresql-server-dev-9.6 \
      postgresql-client-9.6

    if [ ! -d "$HOME/.rbenv" ]; then
      echo 'Installing rbenv and ruby-build'
      git clone https://github.com/rbenv/rbenv.git ~/.rbenv
      git clone https://github.com/rbenv/ruby-build.git \
        ~/.rbenv/plugins/ruby-build
      echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
      echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    fi

    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"

    export RUBY_VERSION='2.5.0'
    if [ ! -d "$HOME/.rbenv/versions/$RUBY_VERSION" ]; then
      echo 'Installing ruby and bundler'
      rbenv install $RUBY_VERSION
      rbenv global $RUBY_VERSION
      gem update --system
      bundle config path "$HOME/.bundle"
    fi

    if [ ! -d "$HOME/.gemrc" ]; then
      echo 'gem: --no-ri --no-rdoc' >> ~/.gemrc
    fi

    if ! grep -qe "^cd \\$HOME/app$" "./.bashrc"; then
      echo "cd \\$HOME/app" >> ./.bashrc
    fi
    cd "$HOME/app"

    echo 'Create PostgreSQL user'
    sudo -u postgres createuser --superuser $USER 2>/dev/null

    echo 'Copy config/database.yml-example'
    sed -r \
      -e "s,^( *username: *).*,\\1${USER}," \
      -e "s,^( *password: *).*,\\1null," \
      -e "s,^( *host: *).*,\\1/var/run/postgresql," \
      config/database.yml-example > config/database.yml

    echo 'Run Rails setup'
    ./bin/setup

    echo
    echo "Log into the Vagrant box with \\`vagrant ssh\\`"
    echo "  Run the test suite by \\`./bin/rake\\`"
    echo "  Start Rails server by \\`./bin/rails server\\`"
    echo "Access the site at \\`http://0.0.0.0:3000\\`."
  SHELL
end
