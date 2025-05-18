;; Asset Registration Contract
;; Records infrastructure details

(define-data-var last-asset-id uint u0)

(define-map assets
  { asset-id: uint }
  {
    asset-type: (string-utf8 50),
    location: (string-utf8 100),
    construction-date: uint,
    owner: principal,
    active: bool
  }
)

(define-public (register-asset (asset-type (string-utf8 50)) (location (string-utf8 100)) (construction-date uint))
  (let
    (
      (new-id (+ (var-get last-asset-id) u1))
    )
    (var-set last-asset-id new-id)
    (map-set assets
      { asset-id: new-id }
      {
        asset-type: asset-type,
        location: location,
        construction-date: construction-date,
        owner: tx-sender,
        active: true
      }
    )
    (ok new-id)
  )
)

(define-read-only (get-asset (asset-id uint))
  (map-get? assets { asset-id: asset-id })
)

(define-public (update-asset-status (asset-id uint) (active bool))
  (let
    (
      (asset (unwrap! (get-asset asset-id) (err u404)))
    )
    (asserts! (is-eq tx-sender (get owner asset)) (err u403))
    (map-set assets
      { asset-id: asset-id }
      (merge asset { active: active })
    )
    (ok true)
  )
)

(define-read-only (get-last-asset-id)
  (var-get last-asset-id)
)
