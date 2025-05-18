;; Alert Management Contract
;; Handles notification of issues

(define-data-var last-alert-id uint u0)

(define-map alerts
  { alert-id: uint }
  {
    asset-id: uint,
    reading-id: uint,
    severity: uint,
    description: (string-utf8 100),
    timestamp: uint,
    resolved: bool
  }
)

(define-map asset-alerts
  { asset-id: uint }
  { alerts: (list 100 uint) }
)

(define-public (create-alert (asset-id uint) (reading-id uint) (severity uint) (description (string-utf8 100)))
  (let
    (
      (new-id (+ (var-get last-alert-id) u1))
      (current-alerts (default-to { alerts: (list) } (map-get? asset-alerts { asset-id: asset-id })))
      (updated-alerts (unwrap! (as-max-len? (append (get alerts current-alerts) new-id) u100) (err u500)))
    )
    (var-set last-alert-id new-id)
    (map-set alerts
      { alert-id: new-id }
      {
        asset-id: asset-id,
        reading-id: reading-id,
        severity: severity,
        description: description,
        timestamp: block-height,
        resolved: false
      }
    )
    (map-set asset-alerts
      { asset-id: asset-id }
      { alerts: updated-alerts }
    )
    (ok new-id)
  )
)

(define-public (resolve-alert (alert-id uint))
  (let
    (
      (alert (unwrap! (map-get? alerts { alert-id: alert-id }) (err u404)))
    )
    (map-set alerts
      { alert-id: alert-id }
      (merge alert { resolved: true })
    )
    (ok true)
  )
)

(define-read-only (get-alert (alert-id uint))
  (map-get? alerts { alert-id: alert-id })
)

(define-read-only (get-asset-alerts (asset-id uint))
  (map-get? asset-alerts { asset-id: asset-id })
)

(define-read-only (get-last-alert-id)
  (var-get last-alert-id)
)
