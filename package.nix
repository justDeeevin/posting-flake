{
  pkgs,
  lib,
  use_xresources ? false,
  ...
}:
pkgs.python312Packages.buildPythonPackage rec {
  pname = "posting";
  version = "2.3.0";
  pyproject = true;
  src = pkgs.fetchFromGitHub {
    owner = "darrenburns";
    repo = "posting";
    tag = version;
    hash = "sha256-lL85gJxFw8/e8Js+UCE9VxBMcmWRUkHh8Cq5wTC93KA=";
  };
  build-system = [pkgs.python312Packages.hatchling];
  dependencies = with pkgs.python312Packages;
    [
      click
      xdg-base-dirs
      click-default-group
      httpx
      pyperclip
      pydantic
      pyyaml
      pydantic-settings
      python-dotenv
      pkgs.textual-autocomplete
      (textual.overridePythonAttrs (old: rec {
        version = "0.86.2";
        src = pkgs.fetchFromGitHub {
          owner = "Textualize";
          repo = "textual";
          rev = "refs/tags/v${version}";
          hash = "sha256-cQYBa1vba/fuv/j0D/MNUboQNTc913UG4dp8a1EPql4=";
        };

        postPatch = ''
          sed -i "/^requires-python =.*/a version = '${version}'" pyproject.toml
        '';
      }))
      (watchfiles.overridePythonAttrs (old: rec {
        version = "0.24.0";

        src = pkgs.fetchFromGitHub {
          owner = "samuelcolvin";
          repo = "watchfiles";
          rev = "refs/tags/v${version}";
          hash = "sha256-uc4CfczpNkS4NMevtRxhUOj9zTt59cxoC0BXnuHFzys=";
        };

        cargoDeps = pkgs.rustPlatform.importCargoLock {
          lockFile = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/samuelcolvin/watchfiles/refs/tags/v${version}/Cargo.lock";
            hash = "sha256-rA6K0bjivOGhoGUYUk5OubFaMh3duEMaDgGtCqbY26g=";
          };
          outputHashes = {
            "notify-6.1.1" = "sha256-lT3R5ZQpjx52NVMEKTTQI90EWT16YnbqphqvZmNpw/I=";
          };
        };

        postPatch = ''
          sed -i "/^requires-python =.*/a version = '${version}'" pyproject.toml
          substituteInPlace Cargo.toml \
            --replace-fail 'version = "0.0.0"' 'version = "${version}"'
        '';
      }))
    ]
    ++ lib.optional use_xresources pkgs.xorg.xrdb;
  meta = {
    description = "The modern API client that lives in your terminal";
    homepage = "https://github.com/darrenburns/posting";
    license = lib.licenses.asl20;
  };
}
