{ buildPythonPackage, fetchgit, stdenv, click, elasticsearch, urllib3, nosexcover, mock }:

buildPythonPackage {
  name = "curator";

  src = fetchgit {
    url = "https://github.com/elastic/curator.git";
    rev = "f4fb814fd4ffb227dd20b3010940575f00c509f1";
    sha256 = "1p6qmfk9j9ng8rgkz8q3mc7f9mc96xhn585g14f8zqy65wflz3q1";
  };

  propagatedBuildInputs = [click elasticsearch urllib3 nosexcover mock];
}
