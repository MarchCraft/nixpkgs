{ lib
, rustPlatform
, fetchFromGitHub
, installShellFiles
, stdenv
, darwin
  # tests
, ruff-lsp
}:

rustPlatform.buildRustPackage rec {
  pname = "ruff";
  version = "0.0.269";

  src = fetchFromGitHub {
    owner = "charliermarsh";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-3W5nCtZJ1ej96c4BEbI7OPfxxyIyp7anWD1zhJqG0OE=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "libcst-0.1.0" = "sha256-jG9jYJP4reACkFLrQBWOYH6nbKniNyFVItD0cTZ+nW0=";
      "ruff_text_size-0.0.0" = "sha256-mfD5RXRCaRfnV7RZrN88rTPkSZ3ITNLTRtCuos14hwE=";
      "unicode_names2-0.6.0" = "sha256-eWg9+ISm/vztB0KIdjhq5il2ZnwGJQCleCYfznCI3Wg=";
    };
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreServices
  ];

  cargoBuildFlags = [ "--package=ruff_cli" ];
  cargoTestFlags = cargoBuildFlags;

  preBuild = lib.optionalString (stdenv.isDarwin && stdenv.isx86_64) ''
    # See https://github.com/jemalloc/jemalloc/issues/1997
    # Using a value of 48 should work on both emulated and native x86_64-darwin.
    export JEMALLOC_SYS_WITH_LG_VADDR=48
  '';

  postInstall = ''
    installShellCompletion --cmd ruff \
      --bash <($out/bin/ruff generate-shell-completion bash) \
      --fish <($out/bin/ruff generate-shell-completion fish) \
      --zsh <($out/bin/ruff generate-shell-completion zsh)
  '';

  passthru.tests = {
    inherit ruff-lsp;
  };

  meta = with lib; {
    description = "An extremely fast Python linter";
    homepage = "https://github.com/charliermarsh/ruff";
    changelog = "https://github.com/charliermarsh/ruff/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ figsoda ];
  };
}
