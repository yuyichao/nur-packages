{ lib
, pythonOlder
, buildPythonPackage
, fetchPypi
, cvxopt
, ecos
, numpy
, osqp
, scipy
, scs
  # Check inputs
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "cvxpy";
  version = "1.1.12";

  disabled = pythonOlder "3.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "01sqc1ca9ad8cqfwxh5ml5a6hnqwrgzp65b24famwr7wwkxfp6dl";
  };

  propagatedBuildInputs = [
    cvxopt
    ecos
    numpy
    osqp
    scipy
    scs
  ];

  checkInputs = [ pytestCheckHook ];
  dontUseSetuptoolsCheck = true;
  pytestFlagsArray = [ "./cvxpy" ];
  # Disable the slowest benchmarking tests, cuts test time in half
  disabledTests = [
    "test_tv_inpainting"
    "test_diffcp_sdp_example"
    # Tests work locally, but fail consistently on GitHub Actions
    "test_cvxopt_sdp"
    "test_psd_nsd_parameters"
    "test_all_solvers"
  ];

  meta = with lib; {
    description = "A domain-specific language for modeling convex optimization problems in Python";
    homepage = "https://www.cvxpy.org/";
    downloadPage = "https://github.com/cvxgrp/cvxpy/releases";
    changelog = "https://github.com/cvxgrp/cvxpy/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
