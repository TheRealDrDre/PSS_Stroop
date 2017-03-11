;Wei's Stroop Task Model ver 4.0

(clear-all)

(define-model Stroop-Task-Model-Ver-4.0

(sgp :esc t
     :act nil
     :imaginal-activation 3.0
     :mas 4.0
     :ul nil
     :auto-attend t
     :er t
     :egs 0.2
     :ans 0.5
     )

;;Stroop-Device-Codes

(chunk-type (stroop-stimulus (:include visual-object)) kind color word)

(chunk-type (stroop-screen (:include visual-object)) kind value)

(chunk-type (stroop-stimulus-location (:include visual-location)) kind color word)

;;Define Chunks

(chunk-type goal task focus)

(chunk-type answer attend)

(chunk-type imaginal slot1 slot2 slot3)

(add-dm

(g1 ISA goal task name-word focus word)
(g2 ISA goal task name-color focus color)
 
(r1 ISA answer attend red)
(r2 ISA answer attend blue)

(start ISA chunk)
(see-stimulus ISA chunk)
(process ISA chunk)
(retrieve-from-LTM ISA chunk)
(motor-output ISA chunk)
(finish ISA chunk)
(color ISA chunk)
(pre-vocal-output ISA chunk)
(vocal-output-blue ISA chunk)
(stimulus ISA chunk)
(stroop-stimulus ISA chunk)
(blocked ISA chunk)
(pause ISA chunk)
(stroop-screen ISA chunk)
(screen ISA chunk)
(done ISA chunk)
(name-word ISA chunk)
(name-color ISA chunk)
(fill-slot-2 ISA chunk)
(retrieve ISA chunk)
(check ISA chunk)


)


;;See stimulus


(p see-stimulus

  ?visual-location>
    state free
    buffer empty

  ?visual>
    state free
    buffer empty

  ?imaginal>
    state free

==>

  +visual-location>
    ISA stroop-stimulus-location
    screen-x 0
    screen-y 0
    )

(p prepare-wm
   
  =visual>
    kind stroop-stimulus
    color =C
    
  ?visual>
    state free
  
  ?imaginal>
    state free
    buffer empty

  ?vocal>
    preparation free
    processor free
    execution free

==>

  =visual>

  +imaginal>
    slot1 nil
    slot2 nil
)


;; Process (Fill in slot1)

(p process-color-s1

   =goal>
   ISA goal
   task name-color
   
   =visual>
   kind stroop-stimulus
   color =C

   ?imaginal>
   state free

   =imaginal>
   slot1 nil
   slot2 nil

==>

  =goal>
  ISA goal
  task fill-slot-2
  focus color
  
  =visual>

  *imaginal>  
    slot1 =C

)


(p process-word-s1

  =goal>
   ISA goal
   task name-word
   
  =visual>
    kind stroop-stimulus
    word =W

  ?imaginal>
    state free

  =imaginal>
    slot1 nil
    slot2 nil

==>

  =goal>
   task fill-slot-2
   focus word
   
  =visual>

  *imaginal>  
    slot1 =W

)


;(p dont-process-color-s1

;  =goal>
;   ISA goal
;   task name-word
   
;  =visual>
;    kind stroop-stimulus
;    word =W

;  ?imaginal>
;    state free

;  =imaginal>
;    slot1 nil

;==>

;  =goal>
;   task fill-slot-2
  
;  =visual>

;  *imaginal>  
;    slot1 =W

;)



;(p dont-process-word-s1

;  =goal>
;   ISA goal
;   task name-color
   
;  =visual>
;    kind stroop-stimulus
;    color =C

;  ?imaginal>
;    state free

;  =imaginal>
;    slot1 nil

;==>

;  =goal>
;   task fill-slot-2
  
;  =visual>

; *imaginal> 
;    slot1 =C

;)


;; Don't Process (fill in slot2)


;(p process-color-s2

;  =goal>
;   ISA goal
;   task name-color
   
;  =visual>
 ;   kind stroop-stimulus
  ;  color =C
   ; word =W

;  ?imaginal>
 ;   state free

 ; =imaginal>
 ; - slot1 nil
 ;   slot2 nil

;==>

;  =goal>
 ;  task name-color
  
;  =visual>

;  *imaginal>  
;    slot2 =C

;)


;(p process-word-s2

 ; =goal>
  ; ISA goal
  ; task name-word
   
;  =visual>
;    kind stroop-stimulus
;    color =C
;    word =W

;  ?imaginal>
;    state free

;  =imaginal>
;  - slot1 nil
;    slot2 nil

;==>

 ; =goal>
 ;  task name-word
  
;  =visual>

 ; *imaginal>  
 ;   slot2 =W

;)



(p dont-process-color-s2

  =goal>
  ISA goal
   task fill-slot-2
   
  =visual>
    kind stroop-stimulus
    color =C
    word =W

  ?imaginal>
    state free

  =imaginal>
    slot2 nil

==>

  =goal>
  task retrieve
  
  =visual>

  *imaginal>  
    slot2 =W


)



(p dont-process-word-s2

  =goal>
   ISA goal
   task fill-slot-2
   
  =visual>
    kind stroop-stimulus
    color =C
    word =W

  ?imaginal>
    state free

  =imaginal>
    slot2 nil

==>

  =goal>
   task retrieve
  
  =visual>

  *imaginal> 
    slot2 =C

)


;;Reach threshold and retrieve from LTM (slot1 is Response slot2 is Interference)

(p retrieve-from-LTM

   =goal>
   task retrieve
   
  =imaginal>
  - slot1 nil
  - slot2 nil

  ?retrieval>
    state free
    buffer empty

==>

   =goal>
      task check 

  =imaginal>

  +retrieval>
    ISA answer
  - attend nil

)

;; check task

(p re-select-color
   =goal>
      task check
      focus color
   =retrieval>
      ISA answer
      attend =ans
   =imaginal>
      slot1 =C
   =visual>
      kind stroop-stimulus
      color =C
    - color =ans 
==>
   =goal>
      task fill-slot-2
   -retrieval>
   *imaginal>
      slot2 nil
   =visual>
 )


(p to-output-color
   =goal>
      task check
      focus color
   =imaginal>
      slot1 =ans
   =retrieval>
      ISA answer
      attend =ans
   =visual>
      kind stroop-stimulus
      color =ans
==>
   =goal>
      task name-color
   =retrieval>   
   =visual>
   *imaginal>
      slot3 =ans
)

(p to-output-word
   =goal>
      task check
      focus word
   =imaginal>
      slot1 =ans
      slot2 =ans 
   =retrieval>
      ISA answer
      attend =ans
   =visual>
      kind stroop-stimulus
      word =ans
==>
   =goal>
      task name-word
   =imaginal>         
   =retrieval>   
   =visual>
   *imaginal>
      slot3 =ans
)

;; vocal-output


(p vocal-output-red
   
     =imaginal>
  - slot1 nil
  - slot2 nil
  - slot3 nil
   
  =retrieval>
    ISA answer
    attend red

  ?vocal>
    state free

==>

  +vocal>
    ISA speak
    cmd speak
    string "Red"
  
  -imaginal>
  
  -retrieval>


)


(p vocal-output-blue

     =imaginal>
  - slot1 nil
  - slot2 nil
  - slot3 nil
   
  =retrieval>
    ISA answer
    attend blue

  ?vocal>
    state free

==>

  +vocal>
    ISA speak
    cmd speak
    string "Blue"

  -imaginal>

  -retrieval>

)

(goal-focus g2)

(spp process-word-s1 :u 25)
(spp process-color-s1 :u 5)
;(spp dont-process-color-s1 :u 50)
;(spp dont-process-word-s1 :u 5)
;(spp process-word-s2 :u 50)
;(spp process-color-s2 :u 5)
(spp dont-process-color-s2 :u 25)
(spp dont-process-word-s2 :u 5)


;;Stroop-Device-Codes

(install-device (make-instance 'stroop-task))

(init (current-device))

(proc-display)


;;Maybe dont process fill slot 2 because it is not conciously monitered?
;;Process fill slot 1 becasue it could be altered by attention
;; word 14.694 color 4
;;try utility T fix word can't run complete


)
