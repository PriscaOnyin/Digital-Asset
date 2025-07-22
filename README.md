

# Digital Asset Marketplace

A secure, blockchain-based platform for trading digital assets with escrow protection. This smart contract enables users to mint, list, and securely trade digital content such as art, music, videos, and documents while preserving creator royalties and buyer protections.

---

## Features

* **Minting Digital Assets**: Users can mint unique assets with metadata and royalty information.
* **Marketplace Listings**: Owners can list assets for sale with custom prices and payment tokens.
* **Escrow Protection**: Trades are processed through escrow with dispute and expiry handling.
* **Ownership Verification**: Built-in function to verify current ownership of any asset.
* **Royalty Support**: Creator royalties are preserved during secondary sales.
* **Metadata Validation**: Assets are validated for metadata size and category integrity.

---

## Data Structures

### Constants

* `CONTRACT_OWNER`: Initial contract deployer.
* Error codes like `ERR_UNAUTHORIZED`, `ERR_ASSET_NOT_FOUND`, etc.
* `platform-fee-rate`: Default is 2.5% (250 basis points).
* `escrow-duration`: Default escrow time (24 hours in blocks).

### Data Variables

* `next-asset-id`: Tracks the next asset ID to be minted.
* `platform-fee-rate`: Basis points representing marketplace fee.
* `escrow-duration`: Duration of escrow in block height.

### Maps

#### `digital-assets`

Stores all minted assets with metadata including:

* `creator`, `current-owner`
* `asset-name`, `description`, `metadata-uri`
* `creation-timestamp`, `asset-category`, `royalty-percentage`, `is-verified`

#### `marketplace-listings`

Stores asset sale listings:

* `seller`, `price`, `payment-token`, `listing-timestamp`, `is-active`

#### `escrow-transactions`

Manages secure asset exchanges:

* `asset-id`, `buyer`, `seller`, `amount`
* `escrow-start`, `escrow-end`, `is-completed`, `dispute-raised`

---

## Public Functions

### `mint-digital-asset`

Mint a new digital asset with metadata and royalty info.

**Parameters:**

* `asset-name`, `description`, `metadata-uri`
* `asset-category`: (1=Art, 2=Music, 3=Video, 4=Document)
* `royalty-percentage`: Max 10%

### `list-asset-for-sale`

List a minted asset on the marketplace.

**Parameters:**

* `asset-id`, `price`, `payment-token`

### `get-asset-details`

Fetch metadata and ownership info for a given asset ID.

### `get-listing-details`

Fetch listing info for a given asset ID.

### `verify-ownership`

Check if a principal owns a given asset ID.

---

## Error Handling

| Error Code                 | Description                                   |
| -------------------------- | --------------------------------------------- |
| `ERR_UNAUTHORIZED`         | Caller is not permitted to perform the action |
| `ERR_ASSET_NOT_FOUND`      | Referenced asset ID does not exist            |
| `ERR_INVALID_PRICE`        | Listed price must be greater than zero        |
| `ERR_INSUFFICIENT_BALANCE` | Buyer has insufficient funds                  |
| `ERR_ASSET_NOT_FOR_SALE`   | Asset is not currently listed                 |
| `ERR_INVALID_BUYER`        | Buyer is not valid for the transaction        |
| `ERR_ESCROW_EXPIRED`       | Escrow transaction timed out                  |
| `ERR_INVALID_METADATA`     | Asset metadata is invalid                     |

---

## Use Cases

* Mint and trade digital art, music, videos, and documents.
* Enable secure purchases through escrow with dispute resolution.
* Ensure original creators earn royalties from future sales.
* Allow buyers to verify asset authenticity and current ownership.

---

## Future Enhancements

* Royalty enforcement on secondary transfers
* Dispute resolution mechanisms
* Token-based payment support integration
* Asset verification service for verified creators

---

## License

MIT License – Open for use, modification, and distribution.

