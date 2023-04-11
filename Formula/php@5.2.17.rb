class PhpAT5217 < Formula
  desc "PHP 5.2.17"
  homepage ""
  url "https://museum.php.net/php5/php-5.2.17.tar.gz"
  sha256 "1abe07c1fdd64184708a3ba179abcfcca5662a4e0d2037eb2748b75abc42e767"

  depends_on "gettext"
  depends_on "icu4c" if build.with? "intl"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libxml2"
  depends_on "mcrypt"
  depends_on "postgresql" if build.with? "pgsql"
  depends_on "readline" if build.with? "readline"

  uses_from_macos "curl"
  uses_from_macos "freetds"
  uses_from_macos "libxslt"
  uses_from_macos "openldap"
  uses_from_macos "sqlite"
  uses_from_macos "unixodbc"

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
      --with-config-file-path=#{etc}
      --with-iconv-dir=/usr
      --with-libxml-dir=#{Formula["libxml2"].opt_prefix}
      --with-openssl=/usr
      --with-zlib=/usr
      --enable-fastcgi
      --enable-mbregex
      --enable-mbstring
      --enable-memory-limit
      --enable-soap
      --enable-sockets
      --enable-sqlite-utf8
      --enable-zend-multibyte
      --mandir=#{man}
      --with-bz2=/usr
      --with-curl=/usr
      --with-freetype-dir=/usr/local/opt/freetype
      --with-gd
      --with-gettext=#{Formula["gettext"].opt_prefix}
      --with-jpeg-dir=#{Formula["jpeg"].opt_prefix}
      --with-mcrypt=#{Formula["mcrypt"].opt_prefix}
      --with-mssql=#{Formula["freetds"].opt_prefix}
      --with-png-dir=#{Formula["libpng"].opt_prefix}
      --with-readline=#{Formula["readline"].opt_prefix}
      --with-xmlrpc
      --with-xsl=/usr
    ]

    args << "--enable-intl" if build.with? "intl"
    args << "--with-apxs2=/usr/sbin/apxs" if build.with? "apache"
    args << "--with-fpm" if build.with? "fpm"
    args << "--with-mysqli=#{Formula["mysql"].opt_bin}/mysql_config" if build.with? "mysql"
    args << "--with-mysql-sock=/tmp/mysql.sock" if File.exist?("/tmp/mysql.sock")
    args << "--with-pdo-mysql=#{Formula["mysql"].opt_bin}/mysql_config" if build.with? "mysql"
    args << "--with-pdo-pgsql=#{Formula["postgresql"].opt_bin}/pg_config" if build.with? "pgsql"
    args << "--with-pgsql=#{Formula["postgresql"].opt_bin}/pg_config" if build.with? "pgsql"

    system "./configure", *args
    system "make"
    system "make", "install"

    if build.with? "fpm"
      (prefix/"org.php.php-fpm.plist").write startup_plist
      cp "#{etc}/php-fpm.conf.default", "#{etc}/php-fpm.conf"
      (var/"log").mkpath
      touch var/"log/php-fpm.log"
    end
  end

  def configure_cellar_paths; end

  def post_install
    # Make sure the Web server will find the PHP module
    if build.with? "apache"
      apache_conf = <<~EOS
        LoadModule php5_module    #{libexec}/apache2/libphp5.so
      EOS
      File.open("/etc/apache2/other/php5_module.conf", "w") { |f| f.write apache_conf }
    end
  end

  def caveats
    s = <<-EOS
      For 10.5 and Apache:
        Apache needs to run in 32-bit mode. You can either force Apache to start
        in 32-bit mode or you can thin the Apache executable.

      To enable PHP in Apache add the following to httpd.conf and restart Apache:
        LoadModule php5_module    #{libexec}/apache2/libphp5.so

      The php.ini file can be found in:
        #{etc}/php.ini
    EOS

    if build.with? "fpm"
      s += <<~EOS

        To launch php-fpm on startup:
          * If this is your first install:
              sudo cp #{opt_prefix}/org.php.php-fpm.plist /Library/LaunchDaemons/
              sudo launchctl load -w /Library/LaunchDaemons/org.php.php-fpm.plist

          * If this is an upgrade and you already have the org.php.php-fpm.plist loaded:
              sudo launchctl unload -w /Library/LaunchDaemons/org.php.php-fpm.plist
              sudo cp #{opt_prefix}/org.php.php-fpm.plist /Library/LaunchDaemons/
              sudo launchctl load -w /Library/LaunchDaemons/org.php.php-fpm.plist
      EOS
    end

    s
  end

  def startup_plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
        "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>org.php.php-fpm</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_sbin}/php-fpm</string>
          <string>--fpm-config</string>
          <string>#{etc}/php-fpm.conf</string>
        </array>
        <key>KeepAlive</key>
        <true/>
        <key>RunAtLoad</key>
        <true/>
      </dict>
      </plist>
    EOS
  end

  test do
    output = shell_output("#{bin}/php -n -r 'echo \"Hello World\n\";'")
    assert_equal "Hello World\n", output
  end
end
