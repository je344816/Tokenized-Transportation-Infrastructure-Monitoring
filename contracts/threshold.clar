;; Threshold Contract
;; Establishes safety parameters

(define-map thresholds
  { asset-type: (string-utf8 50), reading-type: (string-utf8 50) }
  {
    min-value: int,
    max-value: int,
    warning-min: int,
    warning-max: int
  }
)

(define-public (set-threshold
    (asset-type (string-utf8 50))
    (reading-type (string-utf8 50))
    (min-value int)
    (max-value int)
    (warning-min int)
    (warning-max int)
  )
  (begin
    (map-set thresholds
      {
        asset-type: asset-type,
        reading-type: reading-type
      }
      {
        min-value: min-value,
        max-value: max-value,
        warning-min: warning-min,
        warning-max: warning-max
      }
    )
    (ok true)
  )
)

(define-read-only (get-threshold (asset-type (string-utf8 50)) (reading-type (string-utf8 50)))
  (map-get? thresholds { asset-type: asset-type, reading-type: reading-type })
)

(define-read-only (check-threshold (asset-type (string-utf8 50)) (reading-type (string-utf8 50)) (value int))
  (let
    (
      (threshold (unwrap! (get-threshold asset-type reading-type) (err u404)))
    )
    (if (< value (get min-value threshold))
      (err u1) ;; Below minimum threshold
      (if (> value (get max-value threshold))
        (err u2) ;; Above maximum threshold
        (if (< value (get warning-min threshold))
          (err u3) ;; Below warning threshold
          (if (> value (get warning-max threshold))
            (err u4) ;; Above warning threshold
            (ok true) ;; Within normal range
          )
        )
      )
    )
  )
)
