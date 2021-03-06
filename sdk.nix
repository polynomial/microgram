# SDK is meant to be a bridge between software packages and apps.
#
# `sdk` attribute replaces all uses of `pkgs` within App modules.
# This makes the interface between the two entities thin enough to be able to
# replace any component of it at any point in time or evaluate environment
# configuration without relying on nixpkgs at all.
#
# Values returned by these functions are exported as the `sdk` attribute
# in arguments of every Apps' function.
rec {
  #
  # Use only this attribute. The rest is "exported" for debugging convenience.
  #
  sdk = fns // exports // { inherit sdk-env phpPackages; };

  sdk-env = pkgs.buildEnv {
    name = "sdk";
    paths = lib.filter lib.isDerivation (lib.attrValues (exports // { inherit phpPackages; }));
    ignoreCollisions = true;
  };

  nixpkgs-config = {
    allowUnfree = true;

    php = {
      apxs2  = false; # apache support
      ldap   = false; # openldap
      mssql  = false; # freetds
      bz2    = false; pdo_pgsql = false; postgresql = false;
      sqlite = false; xsl       = false;

      bcmath    = true; curl     = true; exif    = true; fpm     = true;
      ftp       = true; gd       = true; gettext = true; intl    = true;
      libxml2   = true; mbstring = true; mcrypt  = true; mhash   = true;
      mysql     = true; mysqli   = true; openssl = true; pcntl   = true;
      pdo_mysql = true; readline = true; soap    = true; sockets = true;
      zip       = true; zlib     = true;
    };

    packageOverrides = pkgs: rec {
      inherit (ugpkgs) erlang imagemagick linux nix;
      mysql = ugpkgs.mariadb;
      php = ugpkgs.php54;
      git = pkgs.gitMinimal;
      go = pkgs.go_1_4;
      glibcLocales = pkgs.glibcLocales.override {
        allLocales = false;
        locales = ["en_US.UTF-8/UTF-8"];
      };
      gnupg = pkgs.gnupg.override {
        pinentry = null;
        x11Support = false; openldap = null; libusb = null;
      };
      python27 = pkgs.python27.override {
        x11Support = false;
      };
      python3 = pkgs.python3.override {
        libX11 = null;
        tk = null; tcl = null;
      };
      python34 = pkgs.python34.override {
        libX11 = null;
        tk = null; tcl = null;
      };
      qemu = pkgs.qemu.override {
        pulseSupport = false;
        sdlSupport = false;
        spiceSupport = false;
      };
    };
  };

  pkgs = import <nixpkgs> {
    system = "x86_64-linux";
    config = nixpkgs-config;
  };

  module = {
    system.activationScripts.microgram-sdk-env = lib.stringAfter ["nix" "systemd"] ''
      ${sdk.nix}/bin/nix-env -p /nix/var/nix/profiles/sdk --set ${sdk-env}
    '';
    nixpkgs.config = nixpkgs-config;
  };

  ugpkgs = import <microgram/pkgs>;
  inherit (pkgs) lib;

  # sdk function exports (things that have arguments)
  fns = {
    # functions that do not produce derivations
    inherit (builtins) toFile;

    inherit (lib) makeSearchPath;

    # functions that do produce derivations
    inherit (pkgs)
      symlinkJoin
      runCommand writeScriptBin writeScript
      substituteAll buildEnv writeText writeTextDir writeTextFile;
    inherit (ugpkgs.fns)
      compileHaskell
      staticHaskellCallPackage
      writeBashScript
      writeBashScriptBin
      writeBashScriptBinOverride
      writeBashScriptOverride;
  };

  exports = rec {
    inherit (pkgs)
      # One line per letter
      atop awscli
      bash binutils
      cacert coreutils curl
      diffutils dnsmasq docker dstat
      e2fsprogs elasticsearch
      file findutils
      gawk gcc git glibc glibcLocales gnugrep gnumake gnupg gnused gnutar go gzip
      htop
      iana_etc iftop imagemagick inetutils inotifyTools iotop iperf iproute iptables
      jdk jetty92 jq
      kibana kmod
      libcgroup libjpeg libjpeg_turbo libxml2 logrotate lsof
      memcached
      netcat-openbsd nfs-utils nodejs ntp
      openjdk openssh openssl optipng
      parallel perf-tools perl php postgresql procps psmisc pv pwgen pxz python
      rdfind redis renameutils riemann runit rxvt_unicode rsync
      s3cmd shadow sshfsFuse stdenv strace strongswan sysstat systemd
      tcpdump tmux tree tzdata
      unzip utillinux
      vim
      wget which
      xz
    ;

    inherit (pkgs) bundler;

    solr4 = pkgs.solr;
    inherit (ugpkgs)
      angel
      ares
      clj-json curator curl-loader
      damemtop dynomite
      elasticsearch-cloud-aws elastisch erlang
      exim
      flame-graph
      galera-wsrep get-user-data gdb-quiet graphviz
      heavy-sync
      jackson-core-asl jenkins jmaps
      kibana4 kiries
      lua-json
      mariadb mariadb-galera memcached-tool mergex mkebs myrapi
      newrelic-memcached-plugin newrelic-mysql-plugin newrelic-plugin-agent newrelic-sysmond nginx nix nq
      percona-toolkit pivotal_agent put-metric
      rabbitmq replicator retry rootfs-busybox runc
      ShellCheck sproxy stack syslog-ng
      thumbor twemproxy
      unicron
      upcast
      vault
      xd
      ybc;
    inherit (ugpkgs)
      newrelic-java; # is a file

    inherit (pkgs.haskellPackages) ghc cabal-install;
    cabal = cabal-install;
  };

  phpPackages = {
    inherit (pkgs.phpPackages) memcache memcached redis zmq zendopcache xdebug;
    inherit (ugpkgs) newrelic-php imagick;
  };
}
