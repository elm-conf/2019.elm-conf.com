with import (builtins.fetchTarball rec {
  # grab a hash from here: https://nixos.org/channels/
  name = "nixpkgs-darwin-18.09pre153780.9bd45dddf81";
  url = "https://github.com/nixos/nixpkgs/archive/9bd45dddf8171e2fd4288d684f4f70a2025ded19.tar.gz";
  # Hash obtained using `nix-prefetch-url --unpack <url>`
  sha256 = "1idrxrymwqfsfysav3yl8lya1jhgg8xzgq9hy7dpdd63770vn8c1";
}) {};

stdenv.mkDerivation {
  name = "2019.elm-conf.com";
  buildInputs = [
    elmPackages.elm
    elmPackages.elm-format
    git
    gnumake
    nodePackages.npm
    nodejs
    python3
  ];
}
