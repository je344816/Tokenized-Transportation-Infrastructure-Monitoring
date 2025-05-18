;; Sensor Data Contract
;; Tracks structural conditions

(define-data-var last-reading-id uint u0)

(define-map sensor-readings
  { reading-id: uint }
  {
    asset-id: uint,
    sensor-id: (string-utf8 50),
    reading-type: (string-utf8 50),
    value: int,
    timestamp: uint
  }
)

(define-map asset-readings
  { asset-id: uint }
  { readings: (list 100 uint) }
)

(define-public (record-sensor-reading (asset-id uint) (sensor-id (string-utf8 50)) (reading-type (string-utf8 50)) (value int))
  (let
    (
      (new-id (+ (var-get last-reading-id) u1))
      (current-readings (default-to { readings: (list) } (map-get? asset-readings { asset-id: asset-id })))
      (updated-readings (unwrap! (as-max-len? (append (get readings current-readings) new-id) u100) (err u500)))
    )
    (var-set last-reading-id new-id)
    (map-set sensor-readings
      { reading-id: new-id }
      {
        asset-id: asset-id,
        sensor-id: sensor-id,
        reading-type: reading-type,
        value: value,
        timestamp: block-height
      }
    )
    (map-set asset-readings
      { asset-id: asset-id }
      { readings: updated-readings }
    )
    (ok new-id)
  )
)

(define-read-only (get-sensor-reading (reading-id uint))
  (map-get? sensor-readings { reading-id: reading-id })
)

(define-read-only (get-asset-readings (asset-id uint))
  (map-get? asset-readings { asset-id: asset-id })
)

(define-read-only (get-last-reading-id)
  (var-get last-reading-id)
)
