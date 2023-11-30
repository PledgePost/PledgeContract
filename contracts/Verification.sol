// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IEAS} from "@ethereum-attestation-service/eas-contracts/contracts/IEAS.sol";
import {Attestation} from "@ethereum-attestation-service/eas-contracts/contracts/Common.sol";

contract EASVerification {
    IEAS public eas;

    // _eas is the address of the EAS contract
    constructor(IEAS _eas) {
        eas = _eas;
    }

    function getPassportAttestation(
        bytes32 uid, // uid of the attestation
        address recipient //
    ) public view returns (uint256 score) {
        // check if attestation exists
        require(eas.isAttestationValid(uid), "Attestation is not valid");

        Attestation memory attestation = eas.getAttestation(uid);
        // check if the address is the recipient of the attestation
        require(
            attestation.recipient == recipient,
            "Invalid recipient of attestation"
        );
        bytes memory encodedData = attestation.data;
        score = decodeScore(encodedData);

        // check if score is valid on core contract
        // just return score
        return score;
    }

    function decodeScore(
        bytes memory encodedData
    ) internal pure returns (uint256 decodedScore) {
        uint256 score;
        uint32 scorer_id;
        uint8 score_decimals;

        (score, scorer_id, score_decimals) = abi.decode(
            encodedData,
            (uint256, uint32, uint8)
        );

        decodedScore = score / 10 ** 18;
        return decodedScore;
    }
}
