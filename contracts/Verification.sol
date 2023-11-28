// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IEAS} from "@ethereum-attestation-service/eas-contracts/contracts/IEAS.sol";
import {Attestation} from "@ethereum-attestation-service/eas-contracts/contracts/Common.sol";

contract EASVerification {
    IEAS public eas;

    constructor(IEAS _eas) {
        eas = _eas;
    }

    function getPassportAttestation(
        bytes32 uid,
        address caller
    ) public view returns (uint256 score) {
        // check if attestation exists
        require(eas.isAttestationValid(uid), "Attestation is not valid");

        Attestation memory attestation = eas.getAttestation(uid);
        // check if caller is the recipient of the attestation
        require(
            attestation.recipient == caller,
            "Caller is not the recipient of the attestation"
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
