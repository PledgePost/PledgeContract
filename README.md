## PledgePost Core SmartContract

### components
- PledgePost.sol: main component of PledgePost.
  - post article
  - donate
  - allocate
  - round management
  - etc...
- PoolContract.sol: pool contract deployed for each grant
- PledgePostERC721.sol: ERC721 contract to proof of donation (will be changed to Hypercert)
- Verification.sol: verify Gitcoin Passport score onchain(Ethereum Attestation Service). integrated into PledgePost.sol contract
