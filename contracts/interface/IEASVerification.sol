// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IEAS} from "@ethereum-attestation-service/eas-contracts/contracts/IEAS.sol";

interface IEASVerification is IEAS {
    function getPassportAttestation(
        bytes32 uid, // uid of the attestation
        address recipient //
    ) external view returns (uint256);

    function checkScore(
        bytes32 uid, // uid of the attestation
        address recipient,
        uint256 score
    ) external view returns (bool);
}
