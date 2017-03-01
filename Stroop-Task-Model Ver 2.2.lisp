;Wei's Stroop Task Model ver 2.2

(clear-all)

(define-model Stroop-Task-Model-Ver-2.2

(sgp :esc t  :ga 2.0  :mas 2.0  :ul T :auto-attend t)

;;Stroop-Device-Codes

(chunk-type (stroop-stimulus (:include visual-object)) kind color word)

(chunk-type (stroop-screen (:include visual-object)) kind value)

(chunk-type (stroop-stimulus-location (:include visual-location)) kind color word)

;;Define Chunks

(chunk-type attention task attend state)

(chunk-type answer attend response type)

(chunk-type imaginal slot1 slot2)

(add-dm

(g1 ISA attention task color attend red state start)
(g2 ISA attention task color attend blue state start)
(g3 ISA attention task word attend red state start)
(g4 ISA attention task word attend blue state start)

(r1 ISA answer attend red response r type output)
(r2 ISA answer attend blue response b type output)

(start ISA chunk) (see-stimulus ISA chunk) (process ISA chunk) (retrieve-from-LTM ISA chunk)
(motor-output ISA chunk) (finish ISA chunk) (r ISA chunk) (b ISA chunk) (color ISA chunk)
(output ISA chunk) (pre-vocal-output ISA chunk) (vocal-output-blue ISA chunk) (stimulus ISA chunk)
(stroop-stimulus ISA chunk) (blocked ISA chunk)

)


;;Set goal to attend to color or word and see stimulus


(p set-goal-see-stimulus

  =goal>
    ISA attention
    state start

  ?visual-location>
    state free
    buffer empty

  ?visual>
    state free
    buffer empty


==>

  =goal>
    ISA attention
    state process

  +visual-location>
    ISA stroop-stimulus-location
    screen-x 0
    screen-y 0

)




;; Four p for process/don't process word/color 


(p process-color

  =goal>
    ISA attention
    task color
    state process 

  =visual>
    ISA stroop-stimulus
    color =C
    value =W

  ?imaginal>
    state free
    buffer empty

==>

  =goal>
    ISA attention
    state retrieve-from-LTM

  =visual>

  +imaginal>  
    slot1 =C
    slot2 =W
)


(p dont-process-color

  =goal>
    ISA attention
    task word
    state process

  =visual>
    ISA stroop-stimulus
    color =C
    value =W

  ?imaginal>
    state free
    buffer empty

==>

  =goal>
    ISA attention
    state retrieve-from-LTM

  =visual>

  +imaginal>  
    slot1 =W
    slot2 blocked

)


(p process-word

  =goal>
    ISA attention
    task word
    state process

  =visual>
    ISA stroop-stimulus
    color =C
    value =W

  ?imaginal>
    state free
    buffer empty

==>

  =goal>
    ISA attention
    state retrieve-from-LTM

  =visual>

  +imaginal>  
    slot1 =W
    slot2 =C

)


(p dont-process-word

  =goal>
    ISA attention
    task color
    state process 

  =visual>
    ISA stroop-stimulus
    color =C
    value =W

  ?imaginal>
    state free
    buffer empty

==>

  =goal>
    ISA attention
    state retrieve-from-LTM

  =visual>

  +imaginal>  
    slot1 =C
    slot2 blocked

)


;;retrieve from LTM (slot2 is Interference)

(p retrieve-from-LTM

  =goal>
    ISA attention
    state retrieve-from-LTM

  =imaginal>
    slot1 =R
    slot2 =I

  ?retrieval>
    state free
    buffer empty

  =visual>
    color =R

==>
  =visual>
  =goal>
    ISA attention
    state pre-vocal-output

  =imaginal>

  +retrieval>
    ISA answer
    type output
    attend =R

)


;; vocal-output

(p pre-vocal-output

  =goal>
    ISA attention
    state pre-vocal-output

  =retrieval>
    ISA answer
    response =R

==>

  =goal>
    ISA attention
    state =R

)


(p vocal-output-red

  =goal>
    ISA attention
    state r

  ?vocal>
    state free

==>

  =goal>
    ISA attention
    state finish

  +vocal>
    ISA speak
    cmd speak
    string "Red"

  -visual>
  
  -imaginal>
  
  -retrieval>

)


(p vocal-output-blue

  =goal>
    ISA attention
    state b

  ?vocal>
    state free

==>

  =goal>
    ISA attention 
    state finish

  +vocal>
    ISA speak
    cmd speak
    string "Blue"

  -visual>

  -imaginal>

  -retrieval>

)

(p prepare
   =goal>
      state finish

   ?goal>
      state free
   =visual>
      kind stroop-screen
      value pause
 ==>
    *goal>
      state process
      attend nil
)

(goal-focus g1)



;;Stroop-Device-Codes

(install-device (make-instance 'stroop-task))

(init (current-device))

(proc-display)


)