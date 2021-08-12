{ lib
, pythonOlder
, buildPythonPackage
, fetchPypi
, attrs
, iso8601
, httpx
, pydantic
, pyjwt
, python-dateutil
, retrying
, rfc3339
, toml
  # Check Inputs
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "qcs-api-client";
  version = "0.8.0";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "68118137337b7ba1688d070bd276c40081938e145759b500699fcc2b941a0fb0";
  };

  # unpin max versions on packages
  postPatch = ''
    substituteInPlace setup.py \
      --replace ",<0.16.0" "" \
      --replace ",<2.0.0" "" \
      --replace ",<21.0.0" "" \
      --replace ",<0.11.0" ""
  '';

  propagatedBuildInputs = [
    attrs
    httpx
    iso8601
    pydantic
    pyjwt
    python-dateutil
    rfc3339
    retrying
    toml
  ];

  doCheck = false;  # no tests included
  dontUseSetuptoolsCheck = true;
  # checkInputs = [ pytestCheckHook ];
  pythonImportsCheck = [ "qcs_api_client" ];

  meta = with lib; {
    description = "A client library for accessing the Rigetti QCS API";
    homepage = "https://docs.rigetti.com/en/";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
