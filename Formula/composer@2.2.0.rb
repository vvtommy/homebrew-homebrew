class ComposerAT220 < Formula
  desc "Dependency Manager for PHP"
  homepage "https://getcomposer.org/"
  url "https://getcomposer.org/download/2.2.0/composer.phar"
  sha256 "f7928b5465ad14c49901174d72c701d74ee278479ae19a44f6a46839e2d87d4d"
  license "MIT"

  livecheck do
    url "https://getcomposer.org/download/"
    regex(%r{href=.*?/v?(\d+(?:\.\d+)+)/composer\.phar}i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "356bd595734dc0afd06ff16473f43e2c9567ae4471cdcd8a9f144b6650ad497c"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "356bd595734dc0afd06ff16473f43e2c9567ae4471cdcd8a9f144b6650ad497c"
    sha256 cellar: :any_skip_relocation, monterey:       "408c987bf6deec2cfe4a7e29676f577bbfd31451f2d5a78662b9c9f191f5a1f9"
    sha256 cellar: :any_skip_relocation, big_sur:        "408c987bf6deec2cfe4a7e29676f577bbfd31451f2d5a78662b9c9f191f5a1f9"
    sha256 cellar: :any_skip_relocation, catalina:       "408c987bf6deec2cfe4a7e29676f577bbfd31451f2d5a78662b9c9f191f5a1f9"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "356bd595734dc0afd06ff16473f43e2c9567ae4471cdcd8a9f144b6650ad497c"
  end

  depends_on "php"

  pour_bottle? do
    false
  end

  def install
    bin.install "composer.phar" => "composer"
  end

  test do
    (testpath/"composer.json").write <<~EOS
      {
        "name": "homebrew/test",
        "authors": [
          {
            "name": "Homebrew"
          }
        ],
        "require": {
          "php": ">=5.3.4"
          },
        "autoload": {
          "psr-0": {
            "HelloWorld": "src/"
          }
        }
      }
    EOS

    (testpath/"src/HelloWorld/Greetings.php").write <<~EOS
      <?php

      namespace HelloWorld;

      class Greetings {
        public static function sayHelloWorld() {
          return 'HelloHomebrew';
        }
      }
    EOS

    (testpath/"tests/test.php").write <<~EOS
      <?php

      // Autoload files using the Composer autoloader.
      require_once __DIR__ . '/../vendor/autoload.php';

      use HelloWorld\\Greetings;

      echo Greetings::sayHelloWorld();
    EOS

    system "#{bin}/composer", "install"
    assert_match(/^HelloHomebrew$/, shell_output("php tests/test.php"))
  end
end
