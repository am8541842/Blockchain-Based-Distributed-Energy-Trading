;; Producer Verification Contract
;; This contract validates energy generators in the system

;; Define data variables
(define-data-var admin principal tx-sender)
(define-map producers principal {verified: bool, name: (string-utf8 100), capacity: uint})

;; Error codes
(define-constant ERR-NOT-ADMIN u100)
(define-constant ERR-ALREADY-REGISTERED u101)
(define-constant ERR-NOT-FOUND u102)

;; Read-only functions
(define-read-only (get-admin)
  (var-get admin)
)

(define-read-only (is-producer (producer-address principal))
  (default-to false (get verified (map-get? producers producer-address)))
)

(define-read-only (get-producer-info (producer-address principal))
  (map-get? producers producer-address)
)

;; Public functions
(define-public (register-producer (name (string-utf8 100)) (capacity uint))
  (let ((caller tx-sender))
    (asserts! (is-none (map-get? producers caller)) (err ERR-ALREADY-REGISTERED))
    (ok (map-set producers caller {verified: false, name: name, capacity: capacity}))
  )
)

(define-public (verify-producer (producer-address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-ADMIN))
    (asserts! (is-some (map-get? producers producer-address)) (err ERR-NOT-FOUND))
    (ok (map-set producers producer-address
      (merge (unwrap-panic (map-get? producers producer-address)) {verified: true})))
  )
)

(define-public (update-capacity (new-capacity uint))
  (let ((caller tx-sender))
    (asserts! (is-some (map-get? producers caller)) (err ERR-NOT-FOUND))
    (ok (map-set producers caller
      (merge (unwrap-panic (map-get? producers caller)) {capacity: new-capacity})))
  )
)

(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-ADMIN))
    (ok (var-set admin new-admin))
  )
)
