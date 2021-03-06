;Wei's Stroop Task Model ver 4.3 (Original Structure)

(clear-all)

(define-model Stroop-Task-Model-Ver-4.2-Original-Structure

(sgp :esc t
     :act nil
     :reward-hook bg-reward-hook
     :imaginal-activation 3.0
     :mas 4.0
     :ul T
     :alpha 0.2
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

(chunk-type imaginal slot1 slot2 output)

(add-dm

(g1 ISA goal task name focus word)
(g2 ISA goal task name focus color)
 
(r1 ISA answer attend red)
(r2 ISA answer attend blue)
(r3 ISA answer attend green)
(r4 ISA answer attend yellow)

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
(name ISA chunk)
(fill-slot-2 ISA chunk)
(retrieve ISA chunk)
(check ISA chunk)
(fill-slot-3 ISA chunk)
(yes ISA chunk)
(no ISA chunk)
;;clean up the ISA chunk stuff later
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
      output no
)

;; Attention (Fill in slot1)
(p process-color-red
   =goal>
      ISA goal
      task name
      focus color
   =visual>
      kind stroop-stimulus
      color red
   ?imaginal>
      state free
   =imaginal>
      slot1 nil
      slot2 nil
==>
   =goal>
      ISA goal
      task fill-slot-2
   =visual>
   *imaginal>  
      slot1 red
)

(p process-word-red
   =goal>
      ISA goal
      task name
      focus word 
   =visual>
      kind stroop-stimulus
      word red
   ?imaginal>
      state free
   =imaginal>
      slot1 nil
      slot2 nil
==>
   =goal>
      task fill-slot-2
   =visual>
   *imaginal>  
      slot1 red
)

(p process-color-blue
   =goal>
      ISA goal
      task name
      focus color
   =visual>
      kind stroop-stimulus
      color blue
   ?imaginal>
      state free
   =imaginal>
      slot1 nil
      slot2 nil
==>
   =goal>
      ISA goal
      task fill-slot-2
   =visual>
   *imaginal>  
      slot1 blue
)

(p process-word-blue
   =goal>
      ISA goal
      task name
      focus word 
   =visual>
      kind stroop-stimulus
      word blue
   ?imaginal>
      state free
   =imaginal>
      slot1 nil
      slot2 nil
==>
   =goal>
      task fill-slot-2
   =visual>
   *imaginal>  
      slot1 blue
)

(p process-color-green
   =goal>
      ISA goal
      task name
      focus color
   =visual>
      kind stroop-stimulus
      color green
   ?imaginal>
      state free
   =imaginal>
      slot1 nil
      slot2 nil
==>
   =goal>
      ISA goal
      task fill-slot-2
   =visual>
   *imaginal>  
      slot1 green
)

(p process-word-green
   =goal>
      ISA goal
      task name
      focus word 
   =visual>
      kind stroop-stimulus
      word green
   ?imaginal>
      state free
   =imaginal>
      slot1 nil
      slot2 nil
==>
   =goal>
      task fill-slot-2
   =visual>
   *imaginal>  
      slot1 green
)

(p process-color-yellow
   =goal>
      ISA goal
      task name
      focus color
   =visual>
      kind stroop-stimulus
      color yellow
   ?imaginal>
      state free
   =imaginal>
      slot1 nil
      slot2 nil
==>
   =goal>
      ISA goal
      task fill-slot-2
   =visual>
   *imaginal>  
      slot1 yellow
)

(p process-word-yellow
   =goal>
      ISA goal
      task name
      focus word 
   =visual>
      kind stroop-stimulus
      word yellow
   ?imaginal>
      state free
   =imaginal>
      slot1 nil
      slot2 nil
==>
   =goal>
      task fill-slot-2
   =visual>
   *imaginal>  
      slot1 yellow
)

;;Fill Slot 2
(p dont-process-color-red
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
    - slot1 nil
      slot2 nil 
==>
   =goal>
      task retrieve
   =visual>
   *imaginal>  
      slot2 red
)

(p dont-process-word-red
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
    - slot1 nil
      slot2 nil 
==>
   =goal>
      task retrieve
   =visual>
   *imaginal> 
      slot2 red
)

(p dont-process-color-blue
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
    - slot1 nil
      slot2 nil 
==>
   =goal>
      task retrieve
   =visual>
   *imaginal>  
      slot2 blue
)

(p dont-process-word-blue
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
    - slot1 nil
      slot2 nil 
==>
   =goal>
      task retrieve
   =visual>
   *imaginal> 
      slot2 blue
)

(p dont-process-color-green
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
    - slot1 nil
      slot2 nil 
==>
   =goal>
      task retrieve
   =visual>
   *imaginal>  
      slot2 green
)

(p dont-process-word-green
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
    - slot1 nil
      slot2 nil 
==>
   =goal>
      task retrieve
   =visual>
   *imaginal> 
      slot2 green
)

(p dont-process-color-yellow
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
    - slot1 nil
      slot2 nil 
==>
   =goal>
      task retrieve
   =visual>
   *imaginal>  
      slot2 yellow
)

(p dont-process-word-yellow
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
    - slot1 nil
      slot2 nil 
==>
   =goal>
      task retrieve
   =visual>
   *imaginal> 
      slot2 yellow
)

;;Reach threshold and retrieve from LTM
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

;; Check Task
(p re-select-color
   =goal>
      task check
      focus color
   =retrieval>
      ISA answer
    - attend =ans
   =imaginal>
      slot1 =ans
   =visual>
      kind stroop-stimulus
      color =ans
==>
   =goal>
      task fill-slot-2
   -retrieval>
   *imaginal>
      slot2 nil
   =visual>
)

(p re-select-word
   =goal>
      task check
      focus word
   =retrieval>
      ISA answer
    - attend =ans
   =imaginal>
      slot1 =ans
   =visual>
      kind stroop-stimulus
      word =ans
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
      task name
   =retrieval>   
   =visual>
   *imaginal>
      output yes
)

(p to-output-word
   =goal>
      task check
      focus word
   =imaginal>
      slot1 =ans
   =retrieval>
      ISA answer
      attend =ans
   =visual>
      kind stroop-stimulus
      word =ans
==>
   =goal>
      task name         
   =retrieval>   
   =visual>
   *imaginal>
      output yes
)

;; vocal-output
(p vocal-output-red
   =imaginal>
    - slot1 nil
    - slot2 nil
      output yes
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
      output yes
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

(p vocal-output-green
   =imaginal>
    - slot1 nil
    - slot2 nil
      output yes
   =retrieval>
      ISA answer
      attend green
   ?vocal>
      state free
==>
   +vocal>
      ISA speak
      cmd speak
      string "Green"
   -imaginal> 
   -retrieval>
)

(p vocal-output-yellow   
   =imaginal>
    - slot1 nil
    - slot2 nil
      output yes
   =retrieval>
      ISA answer
      attend yellow
   ?vocal>
      state free
==>
   +vocal>
      ISA speak
      cmd speak
      string "Yellow"
   -imaginal> 
   -retrieval>
)

(goal-focus g2)

(spp process-word-red :u 2)
(spp process-color-red :u 0)
(spp dont-process-color-red :u 2)
(spp dont-process-word-red :u 0)
(spp process-word-blue :u 2)
(spp process-color-blue :u 0)
(spp dont-process-color-blue :u 2)
(spp dont-process-word-blue :u 0)
(spp process-word-green :u 2)
(spp process-color-green :u 0)
(spp dont-process-color-green :u 2)
(spp dont-process-word-green :u 0)
(spp process-word-yellow :u 2)
(spp process-color-yellow :u 0)
(spp dont-process-color-yellow :u 2)
(spp dont-process-word-yellow :u 0)
(spp re-select-color :reward -1)
(spp re-select-word :reward -1)
(spp to-output-word :reward 1)
(spp to-output-color :reward 1)

;;Stroop-Device-Codes
(install-device (make-instance 'stroop-task))

(init (current-device))

(proc-display)

;;Maybe dont process fill slot 2 because it is not conciously monitered?
;;Process fill slot 1 because it could be altered by attention
;;Slot 3 is output (so that we don't confuse it with the actual filling of slots)
;;word 75 color 161

)
