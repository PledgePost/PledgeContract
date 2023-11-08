// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {IEAS, Attestation, AttestationRequest, AttestationRequestData} from "@ethereum-attestation-service/eas-contracts/contracts/IEAS.sol";
import {ISchemaRegistry, ISchemaResolver, SchemaRecord} from "@ethereum-attestation-service/eas-contracts/contracts/ISchemaRegistry.sol";

contract EASVerification {
    IEAS public eas;
    ISchemaRegistry public schemaRegistry;

    constructor(IEAS _eas, ISchemaRegistry _schemaRegistry) {
        eas = _eas;
        schemaRegistry = _schemaRegistry;
    }

    bytes32 constant SCHEMA_UID =
        0xca6982c2ce55a0b1689a1beaa39593b35b66874f4b5fae6f5c429030e29846d4;

    function verify(bytes32 _uid) public view returns (SchemaRecord memory) {
        SchemaRecord memory record = schemaRegistry.getSchema(_uid);

        return record;
    }
}
