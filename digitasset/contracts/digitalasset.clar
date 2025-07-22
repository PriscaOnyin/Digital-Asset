;; Digital Asset Marketplace
;; Secure platform for trading digital assets with escrow protection

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ASSET_NOT_FOUND (err u101))
(define-constant ERR_INVALID_PRICE (err u102))
(define-constant ERR_INSUFFICIENT_BALANCE (err u103))
(define-constant ERR_ASSET_NOT_FOR_SALE (err u104))
(define-constant ERR_INVALID_BUYER (err u105))
(define-constant ERR_ESCROW_EXPIRED (err u106))
(define-constant ERR_INVALID_METADATA (err u107))

;; Data Variables
(define-data-var next-asset-id uint u1)
(define-data-var platform-fee-rate uint u250) ;; 2.5% in basis points
(define-data-var escrow-duration uint u1440) ;; 24 hours in blocks

;; Data Maps
(define-map digital-assets
  { asset-id: uint }
  {
    creator: principal,
    current-owner: principal,
    asset-name: (string-ascii 100),
    description: (string-ascii 300),
    metadata-uri: (string-ascii 200),
    creation-timestamp: uint,
    asset-category: uint, ;; 1=art, 2=music, 3=video, 4=document
    royalty-percentage: uint,
    is-verified: bool
  }
)

(define-map marketplace-listings
  { asset-id: uint }
  {
    seller: principal,
    price: uint,
    listing-timestamp: uint,
    is-active: bool,
    payment-token: (string-ascii 20)
  }
)

(define-map escrow-transactions
  { transaction-id: uint }
  {
    asset-id: uint,
    buyer: principal,
    seller: principal,
    amount: uint,
    escrow-start: uint,
    escrow-end: uint,
    is-completed: bool,
    dispute-raised: bool
  }
)

;; Validation Functions
(define-private (is-valid-metadata-uri (uri (string-ascii 200)))
  (and (> (len uri) u0) (<= (len uri) u200)))

(define-private (is-valid-asset-id-input (asset-id uint))
  (and (> asset-id u0) (< asset-id (var-get next-asset-id))))

(define-private (is-valid-payment-token (token (string-ascii 20)))
  (and (> (len token) u0) (<= (len token) u20)))

;; Asset Creation
(define-public (mint-digital-asset
  (asset-name (string-ascii 100))
  (description (string-ascii 300))
  (metadata-uri (string-ascii 200))
  (asset-category uint)
  (royalty-percentage uint))
  (let ((asset-id (var-get next-asset-id)))
    (asserts! (and (> (len asset-name) u0) (<= (len asset-name) u100)) ERR_INVALID_METADATA)
    (asserts! (and (> (len description) u0) (<= (len description) u300)) ERR_INVALID_METADATA)
    (asserts! (is-valid-metadata-uri metadata-uri) ERR_INVALID_METADATA)
    (asserts! (and (>= asset-category u1) (<= asset-category u4)) ERR_INVALID_METADATA)
    (asserts! (<= royalty-percentage u1000) ERR_INVALID_METADATA) ;; Max 10%
    
    (map-set digital-assets
      { asset-id: asset-id }
      {
        creator: tx-sender,
        current-owner: tx-sender,
        asset-name: asset-name,
        description: description,
        metadata-uri: metadata-uri,
        creation-timestamp: stacks-block-height,
        asset-category: asset-category,
        royalty-percentage: royalty-percentage,
        is-verified: false
      }
    )
    
    (var-set next-asset-id (+ asset-id u1))
    (ok asset-id)
  )
)

;; Marketplace Functions
(define-public (list-asset-for-sale
  (asset-id uint)
  (price uint)
  (payment-token (string-ascii 20)))
  (let ((validated-asset-id (begin 
                              (asserts! (is-valid-asset-id-input asset-id) ERR_ASSET_NOT_FOUND)
                              asset-id))
        (validated-payment-token (begin 
                                   (asserts! (is-valid-payment-token payment-token) ERR_INVALID_METADATA)
                                   payment-token))
        (asset (unwrap! (map-get? digital-assets { asset-id: validated-asset-id }) ERR_ASSET_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get current-owner asset)) ERR_UNAUTHORIZED)
    (asserts! (> price u0) ERR_INVALID_PRICE)
    
    (map-set marketplace-listings
      { asset-id: validated-asset-id }
      {
        seller: tx-sender,
        price: price,
        listing-timestamp: stacks-block-height,
        is-active: true,
        payment-token: validated-payment-token
      }
    )
    (ok true)
  )
)

;; Query Functions
(define-read-only (get-asset-details (asset-id uint))
  (map-get? digital-assets { asset-id: asset-id })
)

(define-read-only (get-listing-details (asset-id uint))
  (map-get? marketplace-listings { asset-id: asset-id })
)

(define-read-only (verify-ownership (asset-id uint) (owner principal))
  (match (map-get? digital-assets { asset-id: asset-id })
    asset-data (is-eq (get current-owner asset-data) owner)
    false
  )
)
