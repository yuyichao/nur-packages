{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, antlr4-python3-runtime
, lark-parser
, networkx
, numpy
, qcs-api-client
, rpcq
, requests
, retry
, scipy
  # Check Inputs
, pytestCheckHook
, ipython
, pytestcov
, pytest-mock
, pytest-httpx
, requests-mock
}:

buildPythonPackage rec {
  pname = "pyquil";
  version = "3.0.0";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "rigetti";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-XeSwxmqonj/Z/6zsQNasropnl8BH1FvqVn5v86m+4AA=";
  };
  postPatch = ''
    # remove numpy hard-pinning, not compatible with nixpkgs 20.09
    substituteInPlace setup.py --replace ",>=1.20.0" "" \
      --replace "lark==0.*,>=0.11.1" "lark-parser"
  '';

  propagatedBuildInputs = [
    antlr4-python3-runtime
    lark-parser
    networkx
    numpy
    qcs-api-client
    requests
    retry
    rpcq
    scipy
  ];

  doCheck = false; # tests are complex, seem to depend on certain processes/servers run in docker container.
  dontUseSetuptoolsCheck = true;
  checkInputs = [
    pytestCheckHook
    ipython
    pytestcov
    pytest-mock
    pytest-httpx
    requests-mock
  ];
  # Seem to require network connection??
  disabledTests = [
    "test_invalid_protocol"
    "test_qc_noisy"
    "test_qc_compile"
    "qvm" # seem to expect network connection
  ];

  meta = with lib; {
    description = "A library for quantum programming using Quil.";
    homepage = "https://docs.rigetti.com/en/";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
    broken = false; # generating parser fails on older versions of Lark parser. Exact version compatibility unknown
  };
}
