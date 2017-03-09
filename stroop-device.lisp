;;; ------------------------------------------------------------------
;;; STROOP-DEVICE.LISP
;;; ------------------------------------------------------------------
;;; A class that provide an ACT-R GUI interface for a modified
;;; version of the Simon Task.
;;; ------------------------------------------------------------------


(defparameter *using-swank* t)

;;; ----------------------------------------------------------------
;;; ACT-R Functions
;;; ----------------------------------------------------------------

(defun act-r-loaded? ()
  "Cheap hack to check whether ACTR is loaded"
  (and (fboundp 'run-n-events)
       (fboundp 'start-environment)))

(defparameter *d1* 1)

(defparameter *d2* 1)

(defparameter *error-penalty* -1)

(defun bg-reward-hook (production reward time)
  (declare (ignore time))
  (let* ((pname (symbol-name production))
	 (start (subseq pname 0 4)))

    (cond ((string-equal start "PROC")
	   (* *d1* reward))
	  ((string-equal start "DONT")
	   (* *d2* reward))
	  (t
	   0.0))))

;; ---------------------------------------------------------------- ;;
;; Some utilities
;; ---------------------------------------------------------------- ;;

(defun pick (lst)
  "Picks up an element from a list"
  (when  (listp lst)
    (elt lst (random (length lst)))))


(defun scramble (lst &optional (sofar nil))
  "Scrambles a list of different elements"
  (if (null lst)
      sofar
    (let ((picked (pick lst)))
      (scramble (remove picked lst) (cons picked sofar)))))

(defun scramble* (lst)
  "Scrambles any list of objects"
  (let ((l (length lst))
        (pos nil))
    (dotimes (i l)
      (push i pos))
    (mapcar #'(lambda (x) (elt lst x)) (scramble pos))))

(defun mean (&rest nums)
  (when (every #'numberp nums)
    (/ (reduce #'+ nums)
       (length nums))))


(defun divide-into-pairs (lst &optional (partial nil) (open nil))
  "Recursively divides a list into pairs"
  (cond ((null lst)
	 (append partial open))
	((= (length (car open)) 2)
	 (divide-into-pairs (rest lst)
			    (append partial open)
			    (list (list (first lst)))))
	((= (length (car open)) 1)
	 (divide-into-pairs (rest lst)
			    partial
			    (list (list (caar open)
					(first lst)))))
	(t
	 (divide-into-pairs (rest lst)
			    partial
			    (list (list (first lst)))))))


;;; A stroop-trial of the form (shape circle location left)

(defparameter *default-stroop-rule* 'color)

(defparameter *responses* '((f . left) (j . right)))

(defparameter *default-stroop-congruent-stimuli* '((color blue word blue)
						   (color red word red)))

(defparameter *default-stroop-incongruent-stimuli* '((color blue word red)
						     (color red word blue)))


(defun stroop-stimulus? (lst)
  (and (consp lst)
       (evenp (length lst))))

(defun stimulus-correct-response (stimulus &optional (rule *default-stroop-rule*))
  (when (stroop-stimulus? stimulus)
    (second (assoc rule (divide-into-pairs stimulus)))))
    

(defun stimulus-congruent? (stimulus)
  (let* ((chunk (divide-into-pairs stimulus))
	 (col (second (assoc 'color chunk)))
	 (wrd (second (assoc 'word chunk))))
    (when (equalp col wrd)
      t)))


(defun stimulus-incongruent? (stimulus)
  (let* ((chunk (divide-into-pairs stimulus))
	 (col (second (assoc 'color chunk)))
	 (wrd (second (assoc 'word chunk))))
    (unless (equalp col wrd)
      t)))

(defun stimulus-type (stimulus)
  (if (stimulus-congruent? stimulus)
    'congruent
    'incongruent))

(defun make-stroop-trial (stim)
  (let ((trial (list stim 0 0 (stimulus-correct-response stim) nil nil)))
    (set-trial-type trial (stimulus-type stim))
    trial))

(defun trial-stimulus (trial)
  (nth 0 trial))

(defun set-trial-stimulus (trial stimulus)
  (when (stroop-stimulus? stimulus)
    (setf (nth 0 trial) stimulus)))

(defun trial-onset-time (trial)
  (nth 1 trial))

(defun set-trial-onset-time (trial tme)
  (setf (nth 1 trial) tme))

(defun trial-response-time (trial)
  (nth 2 trial))

(defun set-trial-response-time (trial tme)
  (setf (nth 2 trial) tme))

(defun trial-correct-response (trial &optional (task 'color))
  (let* ((stim (trial-stimulus trial))
	 (pairs (divide-into-pairs stim)))
    (cadr (assoc task pairs)))) 

(defun set-trial-correct-response (trial response)
  (setf (nth 3 trial) response))

(defun trial-actual-response (trial)
  (nth 4 trial))

(defun set-trial-actual-response (trial response)
  (setf (nth 4 trial) response))

(defun trial-type (trial)
  (nth 5 trial))

(defun set-trial-type (trial typ)
  (setf (nth 5 trial) typ))

(defun trial-congruent? (trial)
  (equalp (trial-type trial) 'congruent))

(defun generate-stimuli ()
  (let ((result nil))
    (dolist (stimulus *default-stroop-congruent-stimuli*)
      (dotimes (i 75)
	(push (copy-seq stimulus) result)))
    (dolist (stimulus *default-stroop-incongruent-stimuli*)
      (dotimes (i 25)
	(push (copy-seq stimulus) result)))
    result))

(defun generate-trials (stim-list)
  (mapcar #'make-stroop-trial stim-list))

(defun trial-rt (trial)
  (- (trial-response-time trial)
     (trial-onset-time trial)))

(defun trial-accuracy (trial &optional (task 'color))
  (let ((act-string (format nil "~A" (trial-actual-response trial)))
	(cor-string (format nil "~A" (trial-correct-response trial task))))
    (if (search act-string cor-string)
	1
	0))) 

(defclass stroop-task ()
  ((phase :accessor task-phase
	  :initform nil)
   (index :accessor index
	  :initform nil)
   (trials :accessor trials
	   :initform (generate-trials (generate-stimuli)))
   (current-trial :accessor current-trial
		  :initform nil)
   (experiment-log :accessor experiment-log
		   :initform nil))
  (:documentation "A manager for the PSS task"))

(defmethod init ((task stroop-task))
  "Initializes the PSS task manager"
  (unless (null (trials task))
    (setf (index task) 0)
    (setf (experiment-log task) nil)
    (setf (trials task) (scramble* (trials task)))
    (setf (current-trial task)
	  (nth (index task) (trials task)))
    (setf (task-phase task) 'stimulus)))

(defmethod respond ((task stroop-task) response)
  "Records a response in the PSS task"
  (unless (null (current-trial task))
    (let* ((trial (current-trial task)))
      (set-trial-actual-response trial response)
      (when (act-r-loaded?)
	(set-trial-response-time (current-trial task)
				 (mp-time))
	(if (= 1 (trial-accuracy (current-trial task)))
	    (trigger-reward 1)
	    (trigger-reward -1))
	(schedule-event-relative 0 #'next :params (list task))))))
      
      
(defmethod next ((task stroop-task))
  "Moves to the next step in a Stroop Task timeline"
  (cond ((equal (task-phase task) 'stimulus)
	 (setf (task-phase task) 'pause)
	 (push (current-trial task) (experiment-log task))
	 (setf (current-trial task) nil)
	 (when (act-r-loaded?)
	   (schedule-event-relative 1 'next :params (list task))))
	((equal (task-phase task) 'pause)
	 (incf (index task))
	 (cond ((>= (index task) (length (trials task)))
		(setf (task-phase task) 'done))
	       (t
		(setf (task-phase task) 'stimulus)
		(setf (current-trial task) (nth (index task)
						(trials task)))
		(when (act-r-loaded?)
		  (set-trial-onset-time (current-trial task)
					(mp-time)))))))
  (when (act-r-loaded?) 
    (schedule-event-relative 0 'proc-display :params nil)))
	     
	   
(defmethod device-handle-keypress ((task stroop-task) key)
  "Does nothing"
  (declare (ignore task))
  nil)

			   
(defmethod device-handle-click ((task stroop-task))
  "Does nothing"
  (declare (ignore task))
  nil)

(defmethod device-move-cursor-to ((task stroop-task) pos)
  "Does nothing"
  (declare (ignore task))
  nil)

(defmethod device-speak-string ((task stroop-task) str)
  "Responds to the model's vocal answers"
  (respond task (intern (string-upcase (format nil "~a" str)))))


(defmethod get-mouse-coordinates ((task stroop-task))
  "Does nothing"
  (declare (ignore task))
  (vector 0 0))

(defmethod cursor-to-vis-loc ((task stroop-task))
  "Does nothing"
  (declare (ignore task))
  nil)

(defmethod build-vis-locs-for ((task stroop-task) vismod)
  (if (equalp (task-phase task) 'stimulus)
      (build-vis-locs-for (trial-stimulus (current-trial task))
			  vismod)
      (build-vis-locs-for (task-phase task)
			  vismod)))

(defmethod build-vis-locs-for ((trial list) vismod)
  (let ((results nil))
    (push  `(isa stroop-stimulus-location 
		 kind stroop-stimulus
		 value stimulus
		 screen-x 0
		 screen-y 0
		 height 400 
		 width 400
		 ,@trial)
	   results)
    (define-chunks-fct results)))

(defmethod build-vis-locs-for ((phase symbol) vismod)
  (let ((results nil))
    (push  `(isa stroop-stimulus-location 
		 kind screen
		 value ,phase
		 color black
		 screen-x 0
		 screen-y 0
		 height 400 
		 width 400)
	   results)
    (define-chunks-fct results)))


(defmethod vis-loc-to-obj ((task stroop-task) vis-loc)
  "Transforms a visual-loc into a visual object"
  (let ((new-chunk nil)
	(phase (task-phase task))
	(stimulus (trial-stimulus (current-trial task))))
    (if (equal phase 'stimulus)
	(setf new-chunk (vis-loc-to-obj stimulus vis-loc))
	(setf new-chunk (vis-loc-to-obj phase vis-loc)))
    (fill-default-vis-obj-slots new-chunk vis-loc)
    new-chunk))


(defmethod vis-loc-to-obj ((stimulus list) vis-loc)
  "Transforms a stimulus into a visual object"
  (first (define-chunks-fct 
	     `((isa stroop-stimulus
		    kind stroop-stimulus 
		    ,@stimulus
		    )))))

(defmethod vis-loc-to-obj ((phase symbol) vis-loc)
  "Transforms a stimulus into a visual object"
  (first (define-chunks-fct 
	     `((isa stroop-screen
		    kind stroop-screen 
		    value ,phase
		    )))))

;;; ------------------------------------------------------------------
;;; STATS
;;; ------------------------------------------------------------------

(defun analyze-log (log &optional (task 'color))
  "Analyzes the log of a single run"
  (let* ((incong (remove-if #'trial-congruent? log))
	 (cong (remove-if-not #'trial-congruent? log))
	 (correct-incong (remove-if-not #'(lambda (x) (= (trial-accuracy x task) 1))
					incong))
	 (correct-cong (remove-if-not #'(lambda (x) (= (trial-accuracy x task) 1))
					cong)))
    
    (if (or (null correct-incong)
	    (null correct-cong))
	;; If we don't have enough trials, return NA
	;;'((:congruent :na) (:incongruent :na))
	'(:na :na :na :na)
	;; Otherwise, compute accuracies and RTs (on correct trials)
	(let* ((cong-acc (apply #'mean (mapcar #'(lambda (x) (trial-accuracy x task)) cong)))
	       (incong-acc (apply #'mean (mapcar #'(lambda (x) (trial-accuracy x task)) incong)))
	       (cong-rt (apply #'mean (mapcar #'trial-rt correct-cong)))
	       (incong-rt (apply #'mean (mapcar #'trial-rt correct-incong))))
	  (list cong-acc cong-rt incong-acc incong-rt)))))


(defun result? (lst)
  "A list is a result IFF it's made of at least four numbers"
  (and (>= (length lst) 4)
       (every #'(lambda (x) (or (numberp x)
				(keywordp x)))
	      lst)))

(defun result-congruent-accuracy (res)
  (nth 0 res))

(defun result-congruent-rt (res)
  (nth 1 res))

(defun result-incongruent-accuracy (res)
  (nth 2 res))

(defun result-incongruent-rt (res)
  (nth 3 res))

	  
(defun average-results (results)
  "Averages values across a list of results"
  (if (every #'result? results)
    (let* ((meanres nil)
	   (n (length (first results))))
      (dotimes (i n (reverse meanres))
	(let ((avg
	       (float
		(apply 'mean
		       (remove-if-not #'numberp
				      (mapcar #'(lambda (x) (nth i x))
					      results))))))
	  (push avg meanres))))
    (progn
      (format t "   Not every results is a result")
      (setf *results* results))))
    
(defparameter *results* nil)
