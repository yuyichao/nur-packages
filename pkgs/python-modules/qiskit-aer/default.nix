{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, fetchpatch
, cmake
, cvxpy
, cython
, muparserx
, ninja
, nlohmann_json
, numpy
, openblas
, pybind11
, scikit-build
, spdlog
  # Check Inputs
, pytestCheckHook
, ddt
, fixtures
, qiskit-terra
}:

buildPythonPackage rec {
  pname = "qiskit-aer";
  version = "0.7.0";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "qiskit-aer";
    rev = version;
    sha256 = "03bj44g3dzsaw05nd2rf1jawyalw9xqbc481qcahv8ms6jw889sy";
  };

  nativeBuildInputs = [
    cmake
    ninja
    scikit-build
  ];

  buildInputs = [
    openblas
    spdlog
    nlohmann_json
    muparserx
  ];

  propagatedBuildInputs = [
    cvxpy
    cython  # generates some cython files at runtime that need to be cython-ized
    numpy
    pybind11
  ];

  patches = [
    ./remove-conan-install.patch
  ];

  dontUseCmakeConfigure = true;

  # *** Testing ***

  pythonImportsCheck = [
    "qiskit.providers.aer"
    "qiskit.providers.aer.backends.qasm_simulator"
    "qiskit.providers.aer.backends.controller_wrappers" # Checks C++ files built correctly. Only exists if built & moved to output
  ];
  checkInputs = [
    pytestCheckHook
    ddt
    fixtures
    qiskit-terra
  ];
  dontUseSetuptoolsCheck = true;  # Otherwise runs tests twice

  preCheck = ''
    # Tests include a compiled "circuit" which is auto-built in $HOME
    export HOME=$(mktemp -d)
    # move tests b/c by default try to find (missing) cython-ized code in /build/source dir
    cp -r $TMP/$sourceRoot/test $HOME

    # Add qiskit-aer compiled files to cython include search
    pushd $HOME
  '';
  postCheck = ''
    popd
  '';

  meta = with lib; {
    description = "High performance simulators for Qiskit";
    homepage = "https://qiskit.org/aer";
    downloadPage = "https://github.com/QISKit/qiskit-aer/releases";
    changelog = "https://qiskit.org/documentation/release_notes.html";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
