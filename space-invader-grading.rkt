;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname space-invader-grading) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)

;; Space Invaders  

;; =================
;; Constants:

(define HEIGHT 500)
(define WIDTH  300)
(define MTS    (empty-scene WIDTH HEIGHT))

(define TANK-X-SPEED 1)
(define TANK-HEIGHT 30)
(define TANK-BOTTOM 10)
(define TANK-CENTER 15)
(define TANK-Y (- HEIGHT TANK-BOTTOM))


(define INVADER-ANGLE-45 315)
(define INVADER-ANGLE-MINUS-45 225)
(define INVADER-X-SPEED 1)
(define INVADER-Y-SPEED 1)
(define INVADER-X-BOUNCE 15)
(define INVADER-BOUNCE-RIGHT (- WIDTH INVADER-X-BOUNCE))
(define INVADER-BOUNCE-LEFT  INVADER-X-BOUNCE)
(define INVADER-REACHES-BOTTOM (- HEIGHT 10))

(define FIRE-SPEED 6)

(define TANK (above (rectangle  5 10  "solid" "black")
                    (rectangle 20  5  "solid" "black")
                    (ellipse   30 10  "solid" "black")))


(define INVADER (crop
                 0 0 30 20
                 (underlay/align "middle" "middle"
                                 (ellipse   17 (* INVADER-X-BOUNCE 2)  "outline" "black")
                                 (ellipse   10 (* INVADER-X-BOUNCE 2)  "outline" "black")
                                 (ellipse   (* INVADER-X-BOUNCE 2) 10  "solid"   "black"))))


(define FIRE-HEIGHT 15)
(define FIRE-FALL-OFF (-(/ FIRE-HEIGHT 2)))
(define FIRE (ellipse 10 FIRE-HEIGHT "solid" "red"))
(define FIRE-Y (- HEIGHT TANK-HEIGHT))



;; =================
;; Data definitions:

;; Direction is one of:
;; -  1
;; -  0
;; - -1
;; interp. the direction of an object,
;;      1 : to the right
;;      0 : don't move
;;     -1 : to the left

#;
(define (fn-for-direction d)
  (cond [(= d  1) (...)]
        [(= d  0) (...)]
        [(= d -1) (...)]))

(define-struct tank (x y dir))
;; Tank is (make-tank Number Number Direction)
;; interp. tank at position x,y and direction d in the MTS

(define T0 (make-tank 0 TANK-Y 1))                    ; left edge
(define T1 (make-tank (/ WIDTH 2) TANK-Y -1)) ; middle
(define T2 (make-tank WIDTH TANK-Y 1))           ; right edge
(define T3 (make-tank (/ WIDTH 2) TANK-Y 0))           ; right edge
#;
(define (fn-for-tank t)
  (... (tank-x   t)
       (tank-y   t)
       (tank-dir t)))

(define-struct fire (x y))
;; Fire is one of
;; - empty
;; - (make-fire Number Number)
;; interp. a fire that either
;;         empty     : no fire in the game
;;         make-fire : one fire in the game

(define FIRE-0 empty)
(define FIRE-1 (make-fire 0 0))
(define FIRE-2 (make-fire (/ WIDTH 2) (/ HEIGHT 2)))
(define FIRE-3 (make-fire WIDTH HEIGHT))
#;
(define (fn-for-fire f)
  (cond [(empty? f) (...)]
        [else
         (... (fire-x f)
              (fire-y f))]))

(define-struct invader (x y angle))
;; Invader is (make-invader Number Number Number)
;; interp. an invader at position x, y and angle angle

(define INVADER-1 (make-invader 0 0 INVADER-ANGLE-45))
(define INVADER-2 (make-invader (/ HEIGHT 2) (/ WIDTH 2) INVADER-ANGLE-MINUS-45))
(define INVADER-3 (make-invader HEIGHT WIDTH INVADER-ANGLE-45))
(define INVADER-4 (make-invader (/ WIDTH 2) 0 INVADER-ANGLE-45))
(define INVADER-5 (make-invader (/ WIDTH 2) 0 INVADER-ANGLE-MINUS-45))
#;
(define (fn-for-invader i)
  (... (invader-x i)(invader-y i)(invader-angle i)))

;; ListOfInvader is one of:
;; - empty
;; - (cons Invader ListOfInvader)
;; interp. a list of invaders

(define LOI-1 empty)
(define LOI-2 (cons INVADER-1 empty))
(define LOI-3 (cons INVADER-2 (cons INVADER-1 empty)))
(define LOI-4 (cons INVADER-2 (cons INVADER-1 (cons INVADER-3 empty))))
(define LOI-5 (cons INVADER-2 (cons INVADER-1 (cons INVADER-4 (cons INVADER-5 empty)))))
#;
(define (fn-for-loi loi)
  (cond [(empty? loi) (...)]
        [ else
          (... (fn-for-invader(first loi))      ; Invader
               (fn-for-loi(rest loi)))]))       ; ListOfInvader

(define-struct invader-range (min-x max-x min-y max-y))
;; Invader-Range is (make-invader-range Number Number Number Number)
;; interp. an invader range [min-x, max-x], [min-y, max-y]

(define INVADER-RANGE-1 (make-invader-range (- WIDTH 100) (- WIDTH 110) (- HEIGHT 100) (- HEIGHT 130)))
(define INVADER-RANGE-2 (make-invader-range (- WIDTH  90) (- WIDTH 100) (- HEIGHT  70) (- HEIGHT 100)))
(define INVADER-RANGE-3 (make-invader-range (- WIDTH 150) (- WIDTH 180) (- HEIGHT 200) (- HEIGHT 210)))
#;
(define (fn-for-invader-range ir)
  (... (invader-range-min-x ir)
       (invader-range-max-x ir)
       (invader-range-min-y ir)
       (invader-range-max-y ir)))

(define-struct game (t f loi))
;; Game is (make-game game)
;; interp. a game with
;;                t   :  tank (x,y) position on the MTS
;;                fire: a fire ball at (x,y) on MTS
;;                loi : a list of invaders at (x,y) postion and angle

(define GAME-1 (make-game T0 FIRE-1 LOI-1))
(define GAME-2 (make-game T1 FIRE-2 LOI-2))
(define GAME-3 (make-game T2 FIRE-3 LOI-3))
#;
(define (fn-for-game g)
  (... (game-t g)(game-f g)(game-loi g)))

;; =================
;; Functions:

;; game -> game
;; start the world with (main (make-game T3 FIRE-0 LOI-5))
;; 
(define (main g)
  (big-bang g                      ; game
    (on-tick   next-frame)         ; game -> game
    (to-draw   render-behaviour)   ; game -> Image
    (stop-when end-game)           ; game -> Boolean
    (on-key    handle-key)))       ; game KeyEvent -> game

;; game -> game
;; produce the next game status -> fire (- FIRE-SPEED), invader positions
(check-expect (next-frame (make-game (make-tank (/ WIDTH 2)   TANK-Y  0) (make-fire 100 150) (cons (make-invader 100 150 INVADER-ANGLE-45) empty)))(make-game (make-tank (/ WIDTH 2)           TANK-Y  0) (make-fire 100 (- 150 FIRE-SPEED)) empty))
(check-expect (next-frame (make-game (make-tank (/ WIDTH 2)   TANK-Y  1) (make-fire 100 150) (cons (make-invader 100 150 INVADER-ANGLE-45) empty)))(make-game (make-tank (+ (/ WIDTH 2) TANK-X-SPEED) TANK-Y 1) (make-fire 100 (- 150 FIRE-SPEED)) empty))
(check-expect (next-frame (make-game (make-tank (- WIDTH 100) TANK-Y -1) (make-fire  50 200) (cons (make-invader 300   3 INVADER-ANGLE-45) empty)))(make-game (make-tank (- (- WIDTH 100) TANK-X-SPEED) TANK-Y -1) (make-fire 50  (- 200 FIRE-SPEED)) (cons (make-invader  (- 300 INVADER-X-SPEED) (+ 3 INVADER-Y-SPEED) INVADER-ANGLE-MINUS-45 ) empty)))
;(define (next-frame g) GAME-1); stub

(define (next-frame g)
  (make-game (update-tank(game-t g)) (update-fire(game-f g))(update-invaders g)))

;; Tank -> Tank
;; Produce next tank by updating direction (affects x pos) and y pos
(check-expect (update-tank (make-tank (/ WIDTH 2)           TANK-Y  0)) (make-tank (/ WIDTH 2)           TANK-Y  0))
(check-expect (update-tank (make-tank (/ WIDTH 2)           TANK-Y  1)) (make-tank (+ (/ WIDTH 2) TANK-X-SPEED) TANK-Y  1))
(check-expect (update-tank (make-tank (/ WIDTH 2)           TANK-Y -1)) (make-tank (- (/ WIDTH 2) TANK-X-SPEED) TANK-Y -1))
(check-expect (update-tank (make-tank TANK-CENTER           TANK-Y  1)) (make-tank (+ TANK-CENTER TANK-X-SPEED) TANK-Y  1))
(check-expect (update-tank (make-tank TANK-CENTER           TANK-Y -1)) (make-tank TANK-CENTER                  TANK-Y -1)) ; don't update
(check-expect (update-tank (make-tank (- WIDTH TANK-CENTER) TANK-Y  1)) (make-tank (- WIDTH TANK-CENTER) TANK-Y  1))        ; don't update
(check-expect (update-tank (make-tank (- WIDTH TANK-CENTER) TANK-Y -1)) (make-tank (- (- WIDTH TANK-CENTER)TANK-X-SPEED) TANK-Y -1))
;(define (update-tank t) t); stub

(define (update-tank t)
  (cond [(= (tank-dir t) 0) t]
        [(and (> (tank-x t) TANK-CENTER)(< (tank-x t) (- WIDTH TANK-CENTER)))   (update-in-bound t)]
        [(or  (<= (tank-x t) TANK-CENTER)(>= (tank-x t) (- WIDTH TANK-CENTER))) (update-out-of-bound t)]
        ))

;(tank-x   t)
;(tank-y   t)
;(tank-dir t)
       
;; Tank -> Tank
;; update tank by adding/subtracting TANK-X-SPEED to tank x postions depending on the direction sign (Tank-x in of bound)
(check-expect (update-in-bound (make-tank (- WIDTH 100) TANK-Y  1)) (make-tank (+ (- WIDTH 100) TANK-X-SPEED) TANK-Y   1))
(check-expect (update-in-bound (make-tank (- WIDTH 100) TANK-Y -1)) (make-tank (- (- WIDTH 100) TANK-X-SPEED) TANK-Y  -1))
;(define (update-in-bound t) t);stub

(define (update-in-bound t)
  (if (= (tank-dir t) -1)
      (make-tank (- (tank-x t) TANK-X-SPEED) (tank-y   t) (tank-dir t))
      (make-tank (+ (tank-x t) TANK-X-SPEED) (tank-y   t) (tank-dir t))))

;; Tank -> Tank
;; update tank by adding/subtracting TANK-X-SPEED to tank x postions depending on the direction sign (Tank-x out of bound)
(check-expect (update-out-of-bound (make-tank TANK-CENTER           TANK-Y -1)) (make-tank TANK-CENTER TANK-Y -1))
(check-expect (update-out-of-bound (make-tank TANK-CENTER           TANK-Y  1)) (make-tank (+ TANK-CENTER TANK-X-SPEED) TANK-Y +1))
(check-expect (update-out-of-bound (make-tank (- WIDTH TANK-CENTER) TANK-Y -1)) (make-tank (- (- WIDTH TANK-CENTER) TANK-X-SPEED) TANK-Y -1))
(check-expect (update-out-of-bound (make-tank (- WIDTH TANK-CENTER) TANK-Y  1)) (make-tank (- WIDTH TANK-CENTER) TANK-Y  1))
;(define (update-out-of-bound t) t);stub

(define (update-out-of-bound t)
  (cond [(and (<= (tank-x   t) TANK-CENTER)          (= (tank-dir t) -1)) t]
        [(and (>= (tank-x   t)(- WIDTH TANK-CENTER)) (= (tank-dir t)  1)) t]
        [(= (tank-dir t) 1) (make-tank (+ (tank-x t) TANK-X-SPEED) (tank-y   t) (tank-dir t))]
        [else
         (make-tank (- (tank-x t) TANK-X-SPEED) (tank-y   t) (tank-dir t))]))

;; Fire -> Fire
;; Produce the next fire (updates postion, remove excess fire)
(check-expect (update-fire (make-fire 0 0)) (make-fire 0 (- 0 FIRE-SPEED)))
(check-expect (update-fire (make-fire 0 FIRE-FALL-OFF))  empty)
(check-expect (update-fire (make-fire 0 (- 1 FIRE-FALL-OFF))) (make-fire 0 (- 1 FIRE-FALL-OFF FIRE-SPEED)))
(check-expect (update-fire (make-fire (/ WIDTH 2) (/ HEIGHT 2))) (make-fire (/ WIDTH 2) (- (/ HEIGHT 2) FIRE-SPEED)))
;(define (update-fire lof) lof); stub

(define (update-fire f)
  (tick-fire f))  ; ListOfFire

;; Fire -> Fire
;; update fire Y position by subtracting FIRE-SPEED
(check-expect (tick-fire (make-fire   0   0)) (make-fire   0 (-   0 FIRE-SPEED)))
(check-expect (tick-fire (make-fire 120 300)) (make-fire 120 (- 300 FIRE-SPEED)))
;(define (tick-fire f) f); stub

(define (tick-fire f)
  ( if (or (empty? f) (offscreen-fire? f))
       empty
       (make-fire (fire-x f) (- (fire-y f) FIRE-SPEED))))

;; Fire -> Boolean
;; True if fire is out of bound (fire-y >= FIRE-FALL-OFF)
(check-expect (offscreen-fire? empty) false)
(check-expect (offscreen-fire? (make-fire (- WIDTH 100)(- FIRE-FALL-OFF 10))) true)
(check-expect (offscreen-fire? (make-fire (- WIDTH 100) FIRE-FALL-OFF)) true)
(check-expect (offscreen-fire? (make-fire (- WIDTH 100)(+ FIRE-FALL-OFF 10))) false)
;(define (offscreen-fire? f) true); stub

(define (offscreen-fire? f)
  (cond [(empty? f) false]
        [else
         (if (<= (fire-y f) FIRE-FALL-OFF)
             true
             false)]))

;; Game -> ListOfInvader
;; update the invader position (x, y, angle)
(check-expect (update-invaders (make-game T0 empty empty)) empty)
(check-expect (update-invaders (make-game T0 empty (cons (make-invader 0 0 INVADER-ANGLE-45) empty))) (cons (make-invader (+ 0 INVADER-X-SPEED) (+ 0 INVADER-Y-SPEED) INVADER-ANGLE-45) empty)) ; 45 45
(check-expect (update-invaders (make-game T0 (make-fire 100 200) (cons (make-invader 0 0 INVADER-ANGLE-45) empty))) (cons (make-invader (+ 0 INVADER-X-SPEED) (+ 0 INVADER-Y-SPEED) INVADER-ANGLE-45) empty)) ; 45 45
(check-expect (update-invaders (make-game T0 (make-fire 10 3) (cons (make-invader 0 0 INVADER-ANGLE-45) empty))) empty) ; 45 45
(check-expect (update-invaders (make-game T0 (make-fire  4 6) (cons (make-invader (- WIDTH 100) (- HEIGHT 100) INVADER-ANGLE-MINUS-45) empty))) (cons (make-invader (- (- WIDTH 100) INVADER-X-SPEED) (+ (- HEIGHT 100) INVADER-Y-SPEED) INVADER-ANGLE-MINUS-45) empty)) ; -45 -45
(check-expect (update-invaders (make-game T0 (make-fire  (- WIDTH 105) (- HEIGHT 105)) (cons (make-invader (- WIDTH 100) (- HEIGHT 100) INVADER-ANGLE-MINUS-45) empty))) empty) ; -45 -45

(check-expect (update-invaders (make-game T0 (make-fire  100 300) (cons (make-invader (- WIDTH 30) (- HEIGHT 40) INVADER-ANGLE-45) (cons (make-invader 0 0 INVADER-ANGLE-45) empty)))) (cons (make-invader (+ (- WIDTH 30) INVADER-X-SPEED) (+ (- HEIGHT 40) INVADER-Y-SPEED) INVADER-ANGLE-45) (cons (make-invader (+ 0 INVADER-X-SPEED) (+ 0 INVADER-Y-SPEED) INVADER-ANGLE-45) empty))); 45 45 -> 45 45
(check-expect (update-invaders (make-game T0 (make-fire (- WIDTH 24) (- HEIGHT 43)) (cons (make-invader (- WIDTH 30) (- HEIGHT 40) INVADER-ANGLE-45) (cons (make-invader 0 0 INVADER-ANGLE-45) empty)))) (cons (make-invader (+ 0 INVADER-X-SPEED) (+ 0 INVADER-Y-SPEED) INVADER-ANGLE-45) empty)); 45 45 -> 45 45
(check-expect (update-invaders (make-game T0 (make-fire  4 6) (cons (make-invader (- WIDTH 30) (- HEIGHT 40) INVADER-ANGLE-MINUS-45) (cons (make-invader (- WIDTH 10) (- HEIGHT 10) INVADER-ANGLE-MINUS-45) empty)))) (cons (make-invader (- (- WIDTH 30) INVADER-X-SPEED) (+ (- HEIGHT 40) INVADER-Y-SPEED) INVADER-ANGLE-MINUS-45) (cons (make-invader (- (- WIDTH 10)  INVADER-X-SPEED) (+ (- HEIGHT 10) INVADER-Y-SPEED) INVADER-ANGLE-MINUS-45) empty))); -45 -45 -> -45 -45
(check-expect (update-invaders (make-game T0 (make-fire  (- WIDTH 14) (- HEIGHT 8)) (cons (make-invader (- WIDTH 30) (- HEIGHT 40) INVADER-ANGLE-MINUS-45) (cons (make-invader (- WIDTH 10) (- HEIGHT 10) INVADER-ANGLE-MINUS-45) empty)))) (cons (make-invader (- (- WIDTH 30) INVADER-X-SPEED) (+ (- HEIGHT 40) INVADER-Y-SPEED) INVADER-ANGLE-MINUS-45) empty)); -45 -45 -> -45 -45
(check-expect (update-invaders (make-game T0 (make-fire  100 100) (cons (make-invader INVADER-BOUNCE-RIGHT (- HEIGHT 40) INVADER-ANGLE-45) (cons (make-invader 0 0 INVADER-ANGLE-45) empty)))) (cons (make-invader (- INVADER-BOUNCE-RIGHT INVADER-X-SPEED) (+ (- HEIGHT 40) INVADER-Y-SPEED) INVADER-ANGLE-MINUS-45) (cons (make-invader (+ 0 INVADER-X-SPEED) (+ 0 INVADER-Y-SPEED) INVADER-ANGLE-45) empty))); 45 -45 -> -45 45
(check-expect (update-invaders (make-game T0 (make-fire  (- INVADER-BOUNCE-RIGHT 7) (- HEIGHT 38)) (cons (make-invader INVADER-BOUNCE-RIGHT (- HEIGHT 40) INVADER-ANGLE-45) (cons (make-invader 0 0 INVADER-ANGLE-45) empty)))) (cons (make-invader (+ 0 INVADER-X-SPEED) (+ 0 INVADER-Y-SPEED) INVADER-ANGLE-45) empty)); 45 -45 -> -45 45
(check-expect (update-invaders (make-game T0 (make-fire  100 300) (cons (make-invader INVADER-BOUNCE-LEFT  (- HEIGHT 40)  INVADER-ANGLE-MINUS-45) (cons (make-invader 0 0 INVADER-ANGLE-45) empty)))) (cons (make-invader (+ INVADER-BOUNCE-LEFT INVADER-X-SPEED) (+ (- HEIGHT 40) INVADER-Y-SPEED) INVADER-ANGLE-45) (cons (make-invader (+ 0 INVADER-X-SPEED) (+ 0 INVADER-Y-SPEED) INVADER-ANGLE-45) empty))); -45 45 -> 45 -45
(check-expect (update-invaders (make-game T0 (make-fire  10 -4) (cons (make-invader INVADER-BOUNCE-LEFT  (- HEIGHT 40)  INVADER-ANGLE-MINUS-45) (cons (make-invader 0 0 INVADER-ANGLE-45) empty)))) (cons (make-invader (+ INVADER-BOUNCE-LEFT INVADER-X-SPEED) (+ (- HEIGHT 40) INVADER-Y-SPEED) INVADER-ANGLE-45) empty)); -45 45 -> 45 -45

(check-expect (update-invaders (make-game T0 (make-fire  100 4) (cons (make-invader (- WIDTH 30) (- HEIGHT 40) INVADER-ANGLE-MINUS-45) (cons (make-invader INVADER-BOUNCE-LEFT (- HEIGHT 10) INVADER-ANGLE-MINUS-45) empty)))) (cons (make-invader (- (- WIDTH 30) INVADER-X-SPEED) (+ (- HEIGHT 40)  INVADER-Y-SPEED) INVADER-ANGLE-MINUS-45) (cons (make-invader (+ INVADER-BOUNCE-LEFT INVADER-X-SPEED) (+ (- HEIGHT 10) INVADER-Y-SPEED) INVADER-ANGLE-45) empty))); -45 -45 -> -45 45
(check-expect (update-invaders (make-game T0 (make-fire  (- INVADER-BOUNCE-LEFT 6) (- HEIGHT 8)) (cons (make-invader (- WIDTH 30) (- HEIGHT 40) INVADER-ANGLE-MINUS-45) (cons (make-invader INVADER-BOUNCE-LEFT (- HEIGHT 10) INVADER-ANGLE-MINUS-45) empty)))) (cons (make-invader (- (- WIDTH 30) INVADER-X-SPEED) (+ (- HEIGHT 40)  INVADER-Y-SPEED) INVADER-ANGLE-MINUS-45) empty)); -45 -45 -> -45 45
(check-expect (update-invaders (make-game T0 (make-fire  5 100) (cons (make-invader (- WIDTH 30) (- HEIGHT 40) INVADER-ANGLE-45      ) (cons (make-invader INVADER-BOUNCE-RIGHT (- HEIGHT 10) INVADER-ANGLE-45) empty)))) (cons (make-invader (+ (- WIDTH 30) INVADER-X-SPEED) (+ (- HEIGHT 40) INVADER-Y-SPEED) INVADER-ANGLE-45)       (cons (make-invader (- INVADER-BOUNCE-RIGHT INVADER-X-SPEED) (+ (- HEIGHT 10) INVADER-Y-SPEED) INVADER-ANGLE-MINUS-45) empty)));  45 45 -> 45 -45
(check-expect (update-invaders (make-game T0 (make-fire (- WIDTH 17)(- HEIGHT 41)) (cons (make-invader (- WIDTH 30) (- HEIGHT 40) INVADER-ANGLE-45) (cons (make-invader INVADER-BOUNCE-RIGHT(- HEIGHT 10) INVADER-ANGLE-45) empty)))) (cons (make-invader (- INVADER-BOUNCE-RIGHT INVADER-X-SPEED) (+ (- HEIGHT 10) INVADER-Y-SPEED) INVADER-ANGLE-MINUS-45) empty));  45 45 -> 45 -45
(check-expect (update-invaders (make-game T0 (make-fire  100 100) (cons (make-invader INVADER-BOUNCE-RIGHT (- HEIGHT 40) INVADER-ANGLE-45) (cons (make-invader (- WIDTH 30)(- HEIGHT 40) INVADER-ANGLE-45) empty)))) (cons (make-invader (- INVADER-BOUNCE-RIGHT INVADER-X-SPEED) (+ (- HEIGHT 40) INVADER-Y-SPEED) INVADER-ANGLE-MINUS-45) (cons (make-invader (+ (- WIDTH 30) INVADER-X-SPEED) (+ (- HEIGHT 40) INVADER-Y-SPEED) INVADER-ANGLE-45) empty))); 45 45 -> -45 45
(check-expect (update-invaders (make-game T0 (make-fire (- WIDTH 41)(- HEIGHT 36)) (cons (make-invader INVADER-BOUNCE-RIGHT (- HEIGHT 40) INVADER-ANGLE-45) (cons (make-invader (- WIDTH 30)(- HEIGHT 40) INVADER-ANGLE-45) empty)))) (cons (make-invader (- INVADER-BOUNCE-RIGHT INVADER-X-SPEED) (+ (- HEIGHT 40) INVADER-Y-SPEED) INVADER-ANGLE-MINUS-45) empty)); 45 45 -> -45 45
(check-expect (update-invaders (make-game T0 (make-fire  100 100) (cons (make-invader INVADER-BOUNCE-LEFT (- HEIGHT 40) INVADER-ANGLE-MINUS-45) (cons (make-invader (- WIDTH 30) (- HEIGHT 40) INVADER-ANGLE-MINUS-45) empty)))) (cons (make-invader (+ INVADER-BOUNCE-LEFT INVADER-X-SPEED) (+ (- HEIGHT 40) INVADER-Y-SPEED) INVADER-ANGLE-45) (cons (make-invader (- (- WIDTH 30)INVADER-X-SPEED) (+ (- HEIGHT 40) INVADER-Y-SPEED) INVADER-ANGLE-MINUS-45) empty))); -45 -45 -> 45 -45
(check-expect (update-invaders (make-game T0 (make-fire (- INVADER-BOUNCE-LEFT 10) (- HEIGHT 37)) (cons (make-invader INVADER-BOUNCE-LEFT (- HEIGHT 40) INVADER-ANGLE-MINUS-45) (cons (make-invader (- WIDTH 30) (- HEIGHT 40) INVADER-ANGLE-MINUS-45) empty)))) (cons (make-invader (- (- WIDTH 30)INVADER-X-SPEED) (+ (- HEIGHT 40) INVADER-Y-SPEED) INVADER-ANGLE-MINUS-45) empty)); -45 -45 -> 45 -45


;(define (update-invaders g) empty); stub

(define (update-invaders g)
  (update-loi-list (game-f g)(game-loi g)))

;; Fire ListOfInvader -> ListOfInvader
;; Return the updated list of invaders (x,y, angle), if (x,y) pos of fire is within the range of an invader, remove it
(check-expect (update-loi-list empty (cons (make-invader 0 0 INVADER-ANGLE-45) empty)) (cons (make-invader (+ 0 INVADER-X-SPEED) (+ 0 INVADER-Y-SPEED) INVADER-ANGLE-45) empty)) ; fire = empty
(check-expect (update-loi-list (make-fire  100 4) empty) empty) ; loi = empty
(check-expect (update-loi-list (make-fire 10 3) (cons (make-invader 0 0 INVADER-ANGLE-45) empty)) empty) ; fire = invader
(check-expect (update-loi-list (make-fire 100 200) (cons (make-invader 0 0 INVADER-ANGLE-45) empty)) (cons (make-invader (+ 0 INVADER-X-SPEED) (+ 0 INVADER-Y-SPEED) INVADER-ANGLE-45) empty)) ; fire != invader
(check-expect (update-loi-list (make-fire  100 300) (cons (make-invader (- WIDTH 30) (- HEIGHT 40) INVADER-ANGLE-45) (cons (make-invader 0 0 INVADER-ANGLE-45) empty))) (cons (make-invader (+ (- WIDTH 30) INVADER-X-SPEED) (+ (- HEIGHT 40) INVADER-Y-SPEED) INVADER-ANGLE-45) (cons (make-invader (+ 0 INVADER-X-SPEED) (+ 0 INVADER-Y-SPEED) INVADER-ANGLE-45) empty))) ; fire != invader
(check-expect (update-loi-list (make-fire (- WIDTH 24) (- HEIGHT 43)) (cons (make-invader (- WIDTH 30) (- HEIGHT 40) INVADER-ANGLE-45) (cons (make-invader 0 0 INVADER-ANGLE-45) empty))) (cons (make-invader (+ 0 INVADER-X-SPEED) (+ 0 INVADER-Y-SPEED) INVADER-ANGLE-45) empty)) ; fire != invader

;(define (update-loi-list f loi) loi); stub

(define (update-loi-list f loi)
  (cond [(empty? loi) empty]        
        [else
         (if (remove-invader? (first loi) f)
             (update-loi-list f (rest loi))
             (cons (update-invader(first loi))
                   (update-loi-list f (rest loi))))]))

;; Invader Fire -> Boolean
;; True if (x,y) pos of fire is within invader range
(check-expect (remove-invader? (make-invader 0 0 INVADER-ANGLE-45) empty) false) ; bc
(check-expect (remove-invader? (make-invader 0 0 INVADER-ANGLE-45) (make-fire 10 3)) true)     ; = 
(check-expect (remove-invader? (make-invader 0 0 INVADER-ANGLE-45) (make-fire 100 200)) false) ; !=
;(define (remove-invader? i f) true); stub

(define (remove-invader? i f)
  (cond [(empty? f) false]
        [else
         (if (fire-with-in-range i f)
             true
             false)]))

;; Invader Fire -> Boolean
;; Produce True if fire x,y pos is within invader range
;; !!! (and (fire-x-in-invader i f) (fire-y-in-invader i f))
(check-expect (fire-with-in-range (make-invader 0 0 INVADER-ANGLE-45) empty) false) ; bc
(check-expect (fire-with-in-range (make-invader 0 0 INVADER-ANGLE-45) (make-fire 10 3)) true)     ; = 
(check-expect (fire-with-in-range (make-invader 0 0 INVADER-ANGLE-45) (make-fire 100 200)) false) ; !=
;(define (fire-with-in-range i f ) true)

(define (fire-with-in-range i f)
  (and (fire-x-in-invader (find-invader-range i) f) (fire-y-in-invader (find-invader-range i) f)))

;; Invader -> Invader-range
;; produce the invader range in 2D space
(check-expect (find-invader-range (make-invader (/ WIDTH 2) (/ HEIGHT 2) INVADER-ANGLE-MINUS-45)) (make-invader-range (- (/ WIDTH 2) 15) (+ (/ WIDTH 2) 15) (- (/ HEIGHT 2) 10) (+ (/ HEIGHT 2) 10)))
(check-expect (find-invader-range (make-invader (- WIDTH 20)(- HEIGHT 40) INVADER-ANGLE-MINUS-45)) (make-invader-range (- (- WIDTH 20) 15) (+ (- WIDTH 20) 15) (- (- HEIGHT 40) 10) (+ (- HEIGHT 40) 10)))
;(define (find-invader-range i) INVADER-RANGE-1); stub

(define (find-invader-range i)
  (make-invader-range (-(invader-x i) 15)(+(invader-x i) 15) (-(invader-y i)10) (+(invader-y i)10)))


;; Invader-Range Fire -> Boolean
;; Produce true if fire x pos is within invader x range
(check-expect (fire-x-in-invader (find-invader-range(make-invader 0 0 INVADER-ANGLE-45)) empty) false) ; bc
(check-expect (fire-x-in-invader (find-invader-range(make-invader 0 0 INVADER-ANGLE-45)) (make-fire 10 3)) true)     ; = 
(check-expect (fire-x-in-invader (find-invader-range(make-invader 0 0 INVADER-ANGLE-45)) (make-fire 100 200)) false) ; !=
;(define (fire-x-in-invader ir f) true); stub

(define (fire-x-in-invader range f)
  (cond [(empty? f) false]
        [else
         (if (and (>= (fire-x f) (invader-range-min-x range))
                  (<= (fire-x f) (invader-range-max-x range)))
             true
             false             
             )]))


;; Invader-Range Fire -> Boolean
;; Produce true if fire y pos is within invader y range
(check-expect (fire-y-in-invader (find-invader-range(make-invader 0 0 INVADER-ANGLE-45)) empty) false) ; bc
(check-expect (fire-y-in-invader (find-invader-range(make-invader 0 0 INVADER-ANGLE-45)) (make-fire 10 3)) true)     ; = 
(check-expect (fire-y-in-invader (find-invader-range(make-invader 0 0 INVADER-ANGLE-45)) (make-fire 100 200)) false) ; !=
;(define (fire-y-in-invader range f) true); stub

(define (fire-y-in-invader range f)
  (cond [(empty? f) false]
        [else
         (if (and (>= (fire-y f) (invader-range-min-y range))
                  (<= (fire-y f) (invader-range-max-y range)))
             true
             false             
             )]))



;; Invader -> Invader
;; update invader x,y,angle values -> INVADER-X-SPEED, INVADER-Y-SPEED, INVADER-ANGLE-45 or INVADER-ANGLE-MINUS-45
(check-expect (update-invader (make-invader (- INVADER-BOUNCE-RIGHT 4) 0 INVADER-ANGLE-45))                  (make-invader (+ (- INVADER-BOUNCE-RIGHT 4) INVADER-X-SPEED) (+ 0 INVADER-Y-SPEED) INVADER-ANGLE-45)) ; 45 -> 45
(check-expect (update-invader (make-invader INVADER-BOUNCE-RIGHT (/ HEIGHT 2) INVADER-ANGLE-45))             (make-invader (- INVADER-BOUNCE-RIGHT INVADER-X-SPEED) (+ (/ HEIGHT 2) INVADER-Y-SPEED) INVADER-ANGLE-MINUS-45)) ; 45 -> -45
(check-expect (update-invader (make-invader INVADER-BOUNCE-LEFT (/ HEIGHT 2) INVADER-ANGLE-MINUS-45))        (make-invader (+ INVADER-BOUNCE-LEFT INVADER-X-SPEED) (+ (/ HEIGHT 2) INVADER-Y-SPEED) INVADER-ANGLE-45)); -45 -> 45
(check-expect (update-invader (make-invader (+ INVADER-BOUNCE-LEFT 10) (/ HEIGHT 2) INVADER-ANGLE-MINUS-45)) (make-invader (- (+ INVADER-BOUNCE-LEFT 10) INVADER-X-SPEED) (+ (/ HEIGHT 2) INVADER-Y-SPEED) INVADER-ANGLE-MINUS-45)); -45 -> -45 
;(define (update-invader i) i); stub

(define (update-invader i)
  (update-x-y(update_angle i)))

;; invader -> invader
;; update invader angle, if invader bounces off the edges flip angle sign else keep angle
(check-expect (update_angle (make-invader (- INVADER-BOUNCE-RIGHT 4) 0 INVADER-ANGLE-45)) (make-invader (- INVADER-BOUNCE-RIGHT 4) 0 INVADER-ANGLE-45)) ; inbound
(check-expect (update_angle (make-invader INVADER-BOUNCE-RIGHT (/ HEIGHT 2) INVADER-ANGLE-45)) (make-invader INVADER-BOUNCE-RIGHT (/ HEIGHT 2)  INVADER-ANGLE-MINUS-45)) ; off bound R
(check-expect (update_angle (make-invader INVADER-BOUNCE-LEFT (/ HEIGHT 2) INVADER-ANGLE-MINUS-45)) (make-invader INVADER-BOUNCE-LEFT (/ HEIGHT 2) INVADER-ANGLE-45)) ; off bound L
;(define (update_angle i) i);stub

(define (update_angle i)
  ( cond [ (<= (invader-x i) INVADER-BOUNCE-LEFT)  (make-invader (invader-x i)(invader-y i) INVADER-ANGLE-45)]
         [ (>= (invader-x i) INVADER-BOUNCE-RIGHT) (make-invader (invader-x i)(invader-y i) INVADER-ANGLE-MINUS-45)]
         [ else i]))

;; invader -> invader
;; update x,y position of invader, by adding INVADER-Y-SPEED to y and for x it depends on the angle (add/sub INVADER-X-SPEED)
(check-expect (update-x-y (make-invader (- INVADER-BOUNCE-RIGHT 4) 0 INVADER-ANGLE-45))                  (make-invader (+ (- INVADER-BOUNCE-RIGHT 4) INVADER-X-SPEED) (+ 0 INVADER-Y-SPEED) INVADER-ANGLE-45)) ; 45 -> 45
(check-expect (update-x-y (make-invader (+ INVADER-BOUNCE-LEFT 10) (/ HEIGHT 2) INVADER-ANGLE-MINUS-45)) (make-invader (- (+ INVADER-BOUNCE-LEFT 10) INVADER-X-SPEED) (+ (/ HEIGHT 2) INVADER-Y-SPEED) INVADER-ANGLE-MINUS-45)); -45 -> -45 
;(define (update-x-y i) i); stub

(define (update-x-y i)
  (if  (= INVADER-ANGLE-45 (invader-angle i))
       ( make-invader (+ (invader-x i) INVADER-X-SPEED)(+(invader-y i) INVADER-Y-SPEED)(invader-angle i) )
       ( make-invader (- (invader-x i) INVADER-X-SPEED)(+(invader-y i) INVADER-Y-SPEED)(invader-angle i))))


;; game -> Image
;; render tank, fire , invader into x,y position on the MTS
(check-expect (render-behaviour (make-game (make-tank (/ WIDTH 2) TANK-Y 1) (make-fire (/ WIDTH 2) (- HEIGHT 60)) (cons (make-invader (- WIDTH 100) (- HEIGHT 200) INVADER-ANGLE-45 ) (cons (make-invader (- WIDTH 200) (- HEIGHT 100)  INVADER-ANGLE-45 ) (cons (make-invader (- WIDTH 150) (- HEIGHT 250)  INVADER-ANGLE-MINUS-45 ) empty))))) (place-image
                                                                                                                                                                                                                                                                                                                                                  TANK
                                                                                                                                                                                                                                                                                                                                                  (/ WIDTH 2) (- HEIGHT TANK-BOTTOM)
                                                                                                                                                                                                                                                                                                                                                  (place-image
                                                                                                                                                                                                                                                                                                                                                   FIRE
                                                                                                                                                                                                                                                                                                                                                   (/ WIDTH 2) (- HEIGHT 60)
                                                                                                                                                                                                                                                                                                                                                   (place-image
                                                                                                                                                                                                                                                                                                                                                    INVADER
                                                                                                                                                                                                                                                                                                                                                    (- WIDTH 100) (- HEIGHT 200)
                                                                                                                                                                                                                                                                                                                                                    (place-image
                                                                                                                                                                                                                                                                                                                                                     INVADER
                                                                                                                                                                                                                                                                                                                                                     (- WIDTH 200) (- HEIGHT 100)
                                                                                                                                                                                                                                                                                                                                                     (place-image
                                                                                                                                                                                                                                                                                                                                                      INVADER
                                                                                                                                                                                                                                                                                                                                                      (- WIDTH 150) (- HEIGHT 250)
                                                                                                                                                                                                                                                                                                                                                      MTS
                                                                                                                                                                                                                                                                                                                                                      )
                                                                                                                                                                                                                                                                                                                                                     )
                                                                                                                                                                                                                                                                                                                                                    ))
                                                                                                                                                                                                                                                                                                                                                  ))
(check-expect (render-behaviour (make-game (make-tank (- WIDTH 100) (- HEIGHT TANK-BOTTOM) 1) (make-fire (- WIDTH 100) (- HEIGHT 300)) (cons (make-invader (- WIDTH 100) (- HEIGHT 100) INVADER-ANGLE-45 ) (cons (make-invader (- WIDTH 150) (- HEIGHT 110)  INVADER-ANGLE-45 ) (cons (make-invader (- WIDTH 120) (- HEIGHT 190)  INVADER-ANGLE-MINUS-45 ) empty))))) (place-image
                                                                                                                                                                                                                                                                                                                                                                       TANK
                                                                                                                                                                                                                                                                                                                                                                       (- WIDTH 100) (- HEIGHT TANK-BOTTOM)
                                                                                                                                                                                                                                                                                                                                                                       (place-image
                                                                                                                                                                                                                                                                                                                                                                        FIRE
                                                                                                                                                                                                                                                                                                                                                                        (- WIDTH 100) (- HEIGHT 300)
                                                                                                                                                                                                                                                                                                                                                                        (place-image
                                                                                                                                                                                                                                                                                                                                                                         INVADER
                                                                                                                                                                                                                                                                                                                                                                         (- WIDTH 100) (- HEIGHT 100)
                                                                                                                                                                                                                                                                                                                                                                         (place-image
                                                                                                                                                                                                                                                                                                                                                                          INVADER
                                                                                                                                                                                                                                                                                                                                                                          (- WIDTH 150) (- HEIGHT 110) 
                                                                                                                                                                                                                                                                                                                                                                          (place-image
                                                                                                                                                                                                                                                                                                                                                                           INVADER
                                                                                                                                                                                                                                                                                                                                                                           (- WIDTH 120) (- HEIGHT 190)
                                                                                                                                                                                                                                                                                                                                                                           MTS
                                                                                                                                                                                                                                                                                                                                                                           )
                                                                                                                                                                                                                                                                                                                                                                          )
                                                                                                                                                                                                                                                                                                                                                                         ))))
  
;(define (render-behaviour g) MTS); stub

(define (render-behaviour g)
  (render-tank (game-t g) (render-fire (game-f g) (render-invaders (game-loi g)))))

;; ListOfInvader -> Image
;; render all the invaders in the loi into it's (x,y) position on the MTS
(check-expect (render-invaders empty) MTS)
(check-expect (render-invaders (cons (make-invader (/ WIDTH 2) (/ HEIGHT 2) INVADER-ANGLE-MINUS-45) empty)) (place-image INVADER
                                                                                                                         (/ WIDTH 2) (/ HEIGHT 2)
                                                                                                                         MTS
                                                                                                                         ))
(check-expect (render-invaders (cons (make-invader (- WIDTH 100) (- HEIGHT 50) INVADER-ANGLE-45) (cons (make-invader (/ WIDTH 2) (/ HEIGHT 2) INVADER-ANGLE-MINUS-45) (cons (make-invader (- WIDTH 10) (- HEIGHT 102) INVADER-ANGLE-MINUS-45) empty) ))
                               ) (place-image INVADER
                                              (- WIDTH 100) (- HEIGHT 50)
                                              (place-image INVADER
                                                           (/ WIDTH 2) (/ HEIGHT 2)
                                                           (place-image INVADER
                                                                        (- WIDTH 10) (- HEIGHT 102)
                                                                        MTS))))
;(define (render-invaders loi) empty-image); stub

(define (render-invaders loi)
  (cond [(empty? loi) MTS]
        [ else
          (place-image INVADER
                       (invader-x (first loi)) (invader-y (first loi))      ; Invader
                       (render-invaders(rest loi)))]))       ; ListOfInvader


;; Fire Image -> Image
;; render fire into it's (x,y) position on the (scene returned from render-invaders (has INVADERS rendered on the MTS))
(check-expect (render-fire (make-fire (- WIDTH 100) (- HEIGHT 50)) MTS) (place-image FIRE
                                                                                     (- WIDTH 100) (- HEIGHT 50)
                                                                                     MTS))
(check-expect (render-fire (make-fire (- WIDTH  30) (- HEIGHT 80)) (place-image INVADER
                                                                                (/ WIDTH 2) (/ HEIGHT 2)
                                                                                MTS
                                                                                )) (place-image FIRE
                                                                                                (- WIDTH  30) (- HEIGHT 80)
                                                                                                (place-image INVADER
                                                                                                             (/ WIDTH 2) (/ HEIGHT 2)
                                                                                                             MTS )))
;(define (render-fire f img) empty-image); stub

(define (render-fire f scene)
  (if (empty? f)
      scene
      (place-image FIRE
                   (fire-x f)(fire-y f)
                   scene)))


;; Tank Image -> Image
;; render tank into it's (x,y) position on the (scene returned from render-fire (has FIRE and INVADERS rendered on the MTS))
(check-expect (render-tank (make-tank (/ WIDTH 2) TANK-Y 1) MTS) (place-image TANK
                                                                              (/ WIDTH 2) TANK-Y
                                                                              MTS))
(check-expect (render-tank (make-tank (- WIDTH  30) TANK-Y 1) (place-image FIRE
                                                                           (- WIDTH  30) (- HEIGHT 80)
                                                                           (place-image INVADER
                                                                                        (/ WIDTH 2) (/ HEIGHT 2)
                                                                                        MTS ))) (place-image TANK
                                                                                                             (- WIDTH  30) TANK-Y
                                                                                                             (place-image FIRE
                                                                                                                          (- WIDTH  30) (- HEIGHT 80)
                                                                                                                          (place-image INVADER
                                                                                                                                       (/ WIDTH 2) (/ HEIGHT 2)
                                                                                                                                       MTS )))); stub
;(define (render-tank t scene) MTS); stub

(define (render-tank t scene)
  (place-image TANK
               (tank-x t)(tank-y t)
               scene))

;; game -> boolean
;; Game over if invader reaches the bottom of the screen, or palyer eliminated all invaders
(check-expect (end-game (make-game (make-tank 0 TANK-Y -1) (make-fire 0 0) empty)) true)
(check-expect (end-game (make-game T0 (make-fire 0 0) (cons (make-invader 0 INVADER-REACHES-BOTTOM INVADER-ANGLE-45) (cons (make-invader 0 (- HEIGHT 100) INVADER-ANGLE-MINUS-45) empty)))) true)
(check-expect (end-game (make-game T0 (make-fire 0 0) (cons (make-invader 0 0 INVADER-ANGLE-45) (cons (make-invader 0 (- HEIGHT 100) INVADER-ANGLE-MINUS-45) (cons (make-invader (- WIDTH 100) (- HEIGHT 200) INVADER-ANGLE-MINUS-45) empty))))) false)
;(define (end-game g) true); stub

(define (end-game g)
  (or (invader-reached-bottom (game-loi g)) (eliminate-all-invaders (game-loi g))))

;; ListOfInvader -> Boolean 
;; True if at least on invader reached the bottom of the screen (invader-Y == INVADER-REACHES-BOTTOM)
(check-expect (invader-reached-bottom empty) false)
(check-expect (invader-reached-bottom (cons (make-invader 0 0 INVADER-ANGLE-45) (cons (make-invader 0 (- HEIGHT 100) INVADER-ANGLE-MINUS-45) empty))) false)
(check-expect (invader-reached-bottom (cons (make-invader (- WIDTH 21) (- HEIGHT 200) INVADER-ANGLE-45) (cons (make-invader 0 (- HEIGHT 100) INVADER-ANGLE-MINUS-45) (cons (make-invader (- WIDTH 3) (- HEIGHT 30) INVADER-ANGLE-45) (cons (make-invader (- WIDTH 20) (- HEIGHT 60) INVADER-ANGLE-MINUS-45) empty))))) false)
(check-expect (invader-reached-bottom (cons (make-invader 0 (- HEIGHT 100) INVADER-ANGLE-45) (cons (make-invader 0  INVADER-REACHES-BOTTOM INVADER-ANGLE-MINUS-45) empty))) true)
(check-expect (invader-reached-bottom (cons (make-invader 0 INVADER-REACHES-BOTTOM INVADER-ANGLE-45) (cons (make-invader 0 (- HEIGHT 100) INVADER-ANGLE-MINUS-45) (cons (make-invader (- WIDTH 3) INVADER-REACHES-BOTTOM INVADER-ANGLE-45) (cons (make-invader (- WIDTH 20) (- HEIGHT 60) INVADER-ANGLE-MINUS-45) empty))))) true)
;(define (invader-reached-bottom loi) true); stub

(define (invader-reached-bottom loi)
  (cond [(empty? loi) false]
        [ else
          (if  (bottom-invader? (first loi))
               true
               (invader-reached-bottom(rest loi)))]))       ; ListOfInvader

;; Invader -> Boolean
;; true if invader-y == INVADER-REACHES-BOTTOM
(check-expect (bottom-invader? (make-invader 0 INVADER-REACHES-BOTTOM INVADER-ANGLE-45)) true)
(check-expect (bottom-invader? (make-invader (- WIDTH 30) (- HEIGHT 100) INVADER-ANGLE-45)) false)
;(define (bottom-invader? i) true); stub

(define (bottom-invader? i)
  (= (invader-y i) INVADER-REACHES-BOTTOM))


;; ListOfInvader -> Boolean
;; True if loi is empty (Player eliminated all invaders)
(check-expect (eliminate-all-invaders empty) true)
(check-expect (eliminate-all-invaders (cons (make-invader 0 (- HEIGHT 100) INVADER-ANGLE-45) (cons (make-invader 0  INVADER-REACHES-BOTTOM INVADER-ANGLE-MINUS-45) empty))) false)
;(define (eliminate-all-invaders loi) true); stub

(define (eliminate-all-invaders loi)
  (cond [(empty? loi) true]
        [ else       false]))       ; ListOfInvader

;; game KeyEvent -> game
;; arrow key - tank moves right and left, space bar fire missiles
(check-expect (handle-key (make-game (make-tank 0 0  1) FIRE-1 LOI-1)                          "left" ) (make-game (make-tank 0 0 -1) FIRE-1 LOI-1))
(check-expect (handle-key (make-game (make-tank 0 0 -1) FIRE-1 LOI-1)                          "left" ) (make-game (make-tank 0 0 -1) FIRE-1 LOI-1))
(check-expect (handle-key (make-game (make-tank (- WIDTH 100) (- HEIGHT 100)  1) FIRE-1 LOI-1) "right") (make-game (make-tank (- WIDTH 100) (- HEIGHT 100)  1) FIRE-1 LOI-1))
(check-expect (handle-key (make-game (make-tank (- WIDTH 100) (- HEIGHT 100) -1) FIRE-1 LOI-1) "right") (make-game (make-tank (- WIDTH 100) (- HEIGHT 100)  1) FIRE-1 LOI-1))
(check-expect (handle-key (make-game T0 (make-fire 0 0) LOI-1)                                     " ") (make-game T0 (make-fire 0 0) LOI-1) )
(check-expect (handle-key (make-game T0  empty          LOI-1)                                     " ") (make-game T0 (make-fire (tank-x T0) FIRE-Y) LOI-1))
;(define (handle-key g ke) GAME-1); stub

(define (handle-key g ke)
  (cond [(key=? ke " ")     (fire-missiles g)]
        [(key=? ke "left")  (make-game (tank-direction (game-t g) "left" ) (game-f g)(game-loi g))]
        [(key=? ke "right") (make-game (tank-direction (game-t g) "right") (game-f g)(game-loi g))]
        [else               g]))


;; Tank -> Tank
;; Creates a tank with the right direction
(check-expect (tank-direction (make-tank 0 0  1)                          "left" ) (make-tank 0 0 -1))
(check-expect (tank-direction (make-tank 0 0 -1)                          "left" ) (make-tank 0 0 -1))
(check-expect (tank-direction (make-tank (- WIDTH 100) (- HEIGHT 100)  1) "right") (make-tank (- WIDTH 100) (- HEIGHT 100)  1))
(check-expect (tank-direction (make-tank (- WIDTH 100) (- HEIGHT 100) -1) "right") (make-tank (- WIDTH 100) (- HEIGHT 100)  1))
;(define (tank-direction g ke) T0); stub
 
(define (tank-direction t ke)
  (cond [(string=? ke "left" ) (make-tank (tank-x t) (tank-y   t) -1)]
        [(string=? ke "right") (make-tank (tank-x t) (tank-y   t)  1)]))

;; Game -> Game
;; Fire missiles only if there is no fire in the game
(check-expect (fire-missiles (make-game T0 (make-fire 0 0) LOI-1)) (make-game T0 (make-fire 0 0) LOI-1) )
(check-expect (fire-missiles (make-game T0  empty          LOI-1)) (make-game T0 (make-fire (tank-x T0) FIRE-Y) LOI-1))
;(define (fire-missiles g) g);stub

(define (fire-missiles g)
  (if (empty? (game-f g))
      (make-game (game-t g) (make-fire (tank-x (game-t g)) FIRE-Y) (game-loi g))
      g))

