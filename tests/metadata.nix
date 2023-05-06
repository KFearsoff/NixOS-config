{lib}: let
  inherit (lib) runTests;
  metadata-path-mock = ./metadata.mock.toml;
  mocked = import ../lib/metadata.nix {
    inherit lib;
    metadata-path = metadata-path-mock;
  };
  inherit (mocked.lib) metadata;
in
  runTests {
    testMetadata = {
      expr = metadata.metadata;
      expected = lib.importTOML ./metadata.mock.toml;
    };

    testDevicesConfig = {
      expr = metadata.syncthingDevicesConfig;
      expected = {
        test-host = {
          addresses = ["tcp://test-host" "quic://test-host"];
          id = "test-host-syncthing";
        };
        test-outside = {
          addresses = ["tcp://test-outside" "quic://test-outside"];
          id = "test-outside-syncthing";
        };
        test-phone = {
          addresses = ["tcp://test-phone" "quic://test-phone"];
          id = "test-phone-syncthing";
        };
      };
    };

    testHostsList = {
      expr = metadata.syncthingHostsList;
      expected = ["test-host"];
    };

    testOwnedList = {
      expr = metadata.syncthingOwnedList;
      expected = ["test-host" "test-phone"];
    };

    testAllList = {
      expr = metadata.syncthingAllList;
      expected = ["test-host" "test-outside" "test-phone"];
    };

    testPubkeyList = {
      expr = metadata.sshPubkeyList;
      expected = ["test-ci-pubkey" "test-host-pubkey"];
    };

    testHostList = {
      expr = metadata.hostList;
      expected = ["test-host"];
    };

    testPhoneList = {
      expr = metadata.phoneList;
      expected = ["test-phone"];
    };
  }
