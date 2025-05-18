;; Maintenance Tracking Contract
;; Records repair activities

(define-data-var last-maintenance-id uint u0)

(define-map maintenance-records
  { maintenance-id: uint }
  {
    asset-id: uint,
    description: (string-utf8 200),
    performed-by: principal,
    cost: uint,
    start-date: uint,
    end-date: (optional uint),
    status: (string-utf8 20)
  }
)

(define-map asset-maintenance
  { asset-id: uint }
  { records: (list 100 uint) }
)

(define-public (create-maintenance-record
    (asset-id uint)
    (description (string-utf8 200))
    (cost uint)
  )
  (let
    (
      (new-id (+ (var-get last-maintenance-id) u1))
      (current-records (default-to { records: (list) } (map-get? asset-maintenance { asset-id: asset-id })))
      (updated-records (unwrap! (as-max-len? (append (get records current-records) new-id) u100) (err u500)))
    )
    (var-set last-maintenance-id new-id)
    (map-set maintenance-records
      { maintenance-id: new-id }
      {
        asset-id: asset-id,
        description: description,
        performed-by: tx-sender,
        cost: cost,
        start-date: block-height,
        end-date: none,
        status: "in-progress"
      }
    )
    (map-set asset-maintenance
      { asset-id: asset-id }
      { records: updated-records }
    )
    (ok new-id)
  )
)

(define-public (complete-maintenance (maintenance-id uint))
  (let
    (
      (record (unwrap! (map-get? maintenance-records { maintenance-id: maintenance-id }) (err u404)))
    )
    (asserts! (is-eq tx-sender (get performed-by record)) (err u403))
    (map-set maintenance-records
      { maintenance-id: maintenance-id }
      (merge record {
        end-date: (some block-height),
        status: "completed"
      })
    )
    (ok true)
  )
)

(define-read-only (get-maintenance-record (maintenance-id uint))
  (map-get? maintenance-records { maintenance-id: maintenance-id })
)

(define-read-only (get-asset-maintenance-records (asset-id uint))
  (map-get? asset-maintenance { asset-id: asset-id })
)

(define-read-only (get-last-maintenance-id)
  (var-get last-maintenance-id)
)
