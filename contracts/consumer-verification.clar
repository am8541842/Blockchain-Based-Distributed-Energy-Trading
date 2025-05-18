;; Consumer Verification Contract
;; This contract validates energy users in the system

;; Define data variables
(define-data-var admin principal tx-sender)
(define-map consumers principal {verified: bool, name: (string-utf8 100), max-consumption: uint})

;; Error codes
(define-constant ERR-NOT-ADMIN u100)
(define-constant ERR-ALREADY-REGISTERED u101)
(define-constant ERR-NOT-FOUND u102)

;; Read-only functions
(define-read-only (get-admin)
  (var-get admin)
)

(define-read-only (is-consumer (consumer-address principal))
  (default-to false (get verified (map-get? consumers consumer-address)))
)

(define-read-only (get-consumer-info (consumer-address principal))
  (map-get? consumers consumer-address)
)

;; Public functions
(define-public (register-consumer (name (string-utf8 100)) (max-consumption uint))
  (let ((caller tx-sender))
    (asserts! (is-none (map-get? consumers caller)) (err ERR-ALREADY-REGISTERED))
    (ok (map-set consumers caller {verified: false, name: name, max-consumption: max-consumption}))
  )
)

(define-public (verify-consumer (consumer-address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-ADMIN))
    (asserts! (is-some (map-get? consumers consumer-address)) (err ERR-NOT-FOUND))
    (ok (map-set consumers consumer-address
      (merge (unwrap-panic (map-get? consumers consumer-address)) {verified: true})))
  )
)

(define-public (update-max-consumption (new-max-consumption uint))
  (let ((caller tx-sender))
    (asserts! (is-some (map-get? consumers caller)) (err ERR-NOT-FOUND))
    (ok (map-set consumers caller
      (merge (unwrap-panic (map-get? consumers caller)) {max-consumption: new-max-consumption})))
  )
)

(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-ADMIN))
    (ok (var-set admin new-admin))
  )
)
