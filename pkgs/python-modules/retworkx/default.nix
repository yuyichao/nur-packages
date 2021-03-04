{ lib
, buildPythonPackage
, rustPlatform
, python
, fetchFromGitHub
, pipInstallHook
, maturin
, pip
  # Check inputs
, pytestCheckHook
, numpy
}:

let
  pname = "retworkx";
  version = "0.7.2";
  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "retworkx";
    rev = version;
    sha256 = "028p96md4yiwq6996fcjx42fy4w2ycgx4dk1lashfg7ak6pzy84j";
  };
  installCheckInputs = [ pytestCheckHook numpy ];
  preCheck = ''
    export TESTDIR=$(mktemp -d)
    cp -r tests/ $TESTDIR
    pushd $TESTDIR
  '';
  postCheck = "popd";
  meta = with lib; {
    description = "A python graph library implemented in Rust.";
    homepage = "https://retworkx.readthedocs.io/en/latest/index.html";
    downloadPage = "https://github.com/Qiskit/retworkx/releases";
    changelog = "https://github.com/Qiskit/retworkx/releases/tag/${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };

  pre2105Package = rustPlatform.buildRustPackage rec {
    inherit pname version src installCheckInputs preCheck postCheck meta;

    # TODO: remove when 20.09 released, needed to build on CI.
    cargoSha256 = if
      lib.versionOlder lib.trivial.release "20.09"
      then "0pzcb74vdx8n7vw16gv90h0spr66p8p6700p4bw8f0dmxw1qn40s"
      else "1v25r2gvk11i4xc2yhj0bwv3asi8vbvhib6kp8za4p41n3w1yvma";
    legacyCargoFetcher = true;  # TODO: Remove on next nixos release. Cargo SHA mismatch b/w unstable & release.

    propagatedBuildInputs = [ python ];

    nativeBuildInputs = [ pipInstallHook maturin pip ];

    # Needed b/c need to check AFTER python wheel is installed (using Rust Build, not buildPythonPackage)
    doCheck = false;
    doInstallCheck = true;

    buildPhase = ''
      runHook preBuild
      maturin build --release --manylinux off --strip
      runHook postBuild
    '';

    installPhase = ''
      install -Dm644 -t dist target/wheels/*.whl
      pipInstallPhase
    '';
  };

  nixpkgs2105Package = buildPythonPackage {
    inherit pname version src installCheckInputs preCheck postCheck meta;
    format = "pyproject";

    cargoDeps = rustPlatform.fetchCargoTarball {
      inherit src;
      name = "${pname}-${version}";
      sha256 = "1v25r2gvk11i4xc2yhj0bwv3asi8vbvhib6kp8za4p41n3w1yvma";
    };

    nativeBuildInputs = with rustPlatform; [ cargoSetupHook maturinBuildHook ];
    doCheck = false;
    doInstallCheck = true;
  };
in
  (if lib.versionAtLeast lib.trivial.release "21.05" then nixpkgs2105Package else pre2105Package)
