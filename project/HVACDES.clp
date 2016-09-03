
;;====================================================================
;; Joseph Del Rocco
;; EEL5874 - Expert Systems & Knowledge Engineering
;; Spring 2011
;;
;; Term Project: HVAC Diagnostics Expert System
;;
;; Use with CLIPS Version 6.3
;; To execute, simply (load) this file, (reset) and (run).
;;====================================================================

;;-------------------------------------
;; UTILITY FUNCTIONS
;;-------------------------------------

(deffunction restart-program ()
  (reset)
  (assert (program started))
  (assert (menu))
  (run)
)

(deffunction ask-question (?question $?allowed-values)
  (printout t ?question)
  (bind ?answer (read))
  (if (lexemep ?answer) then (bind ?answer (lowcase ?answer)))
  (while (not (member ?answer ?allowed-values)) do
    (printout t ?question)
    (bind ?answer (read))
    (if (lexemep ?answer) then (bind ?answer (lowcase ?answer))))
  ?answer
)

(deffunction ask-yes-or-no (?question)
  (bind ?response (ask-question ?question yes no y n))
  (if (or (eq ?response yes) (eq ?response y)) then TRUE else FALSE)
)

(deffunction ask-continue ()
  (ask-question "Press 'c' to continue..." c C)
)

;;-------------------------------------
;; SYSTEM BANNERS (MENU, HELP, etc.)
;;-------------------------------------

(defrule r_startup ""
  (not (program started))
  =>
  (printout t crlf)
  (printout t "======================================================================" crlf)
  (printout t "~ HVAC Diagnostics Expert System ~"                                     crlf)
  (printout t "======================================================================" crlf)
  (assert (program started))
  (assert (menu))
)

(defrule r_whatsMyFocus ""
  ?m <- (menu)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "What would you like to do?"                                             crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "(1) My HVAC unit is not cooling."                                       crlf)
  (printout t "(2) My HVAC unit is not heating."                                       crlf)
  (printout t "(3) My HVAC unit is leaking."                                           crlf)
  (printout t "(4) See Help Guide."                                                    crlf)
  (printout t "(5) Exit."                                                              crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (bind ?i (ask-question "Please select a menu item above: " 1 2 3 4 5))
  (retract ?m)
  (assert (thefocus (nth$ ?i (create$ cool heat leak guide end))))
)

(defrule r_guide ""
  (thefocus guide)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "Intended Target Audience:                                             " crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "The intended user of this system is anyone seeking help with basic    " crlf)
  (printout t "diagnostics of residential HVAC systems.  Experience doing so is not  " crlf)
  (printout t "intended to be required of the user of this system.  That having been " crlf)
  (printout t "said though, it will be helpful if the user of this system has basic  " crlf)
  (printout t "mechanical knowledge or familiarity with multi-meters, pressure gages," crlf)
  (printout t "screwdrivers, etc.  The reason for this is because this system may ask" crlf)
  (printout t "you for the status or measurement of various components located inside" crlf)
  (printout t "an air-handler, requiring the use of at least a screwdriver to gain   " crlf)
  (printout t "access to them as well as a multi-meter or gages to measure them.     " crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "What This Program Does:                                               " crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "This expert system attempts to diagnose common malfunctions that occur" crlf)
  (printout t "with residential HVAC systems.  Though there are many brands & models " crlf)
  (printout t "of systems on the market today, the core operational concepts and     " crlf)
  (printout t "diagnostic routines are roughly the same.  It will ask you various    " crlf)
  (printout t "questions, some more specific than others, and eventually give you a  " crlf)
  (printout t "final answer as to the most likely diagnosis and recommended fix for  " crlf)
  (printout t "your system.                                                          " crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "What This Program Does NOT Do:                                        " crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "This expert system will not delve into the detailed specifics of how  " crlf)
  (printout t "to repair an isolated component,such as a compressor, once a problem  " crlf)
  (printout t "is diagnosed.  If the expert system thinks that your compressor is bad" crlf)
  (printout t "it will report so but will not necessarily tell you how to repair it  " crlf)
  (printout t "specifically.  There are several reasons for this:                    " crlf)
  (printout t " (1) The goal here is to diagnose the problem.                        " crlf)
  (printout t " (2) Repair can often be as detailed a topic as diagnostics.          " crlf)
  (printout t " (3) In general, most HVAC components should be replaced outright.    " crlf)
  (printout t " (4) Sub-components vary enough to warrant detailed repair FAQs.      " crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "Discrepancies w/ Your HVAC System:                                    " crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "Note there may be discrepancies between what is stated in this program" crlf)
  (printout t "and your own HVAC system, simply because there are many different     " crlf)
  (printout t "models and configurations on the market today, and from many different" crlf)
  (printout t "vendors.  So it is definitely possible that the configuration of a    " crlf)
  (printout t "particular sub-system unique to your HVAC unit has not been accounted " crlf)
  (printout t "for and is therefore not mentioned specifically.                      " crlf)
  (printout t "To address this, the expert has made a valiant effort to try and      " crlf)
  (printout t "tackle diagnostics generically across all residential HVAC systems.   " crlf)
  (printout t "Keep this in mind and accomodate as necessary.                        " crlf)
  (printout t "For Example:                                                          " crlf)
  (printout t "If the expert system asks you to check the power circuits associated  " crlf)
  (printout t "with say 5 heating elements, but you find that your system has as many" crlf)
  (printout t "as 8 or as few as 3 heating element circuits, then adjust accordingly." crlf)
  (printout t "You should expect to check all of them, as a problem with any of them " crlf)
  (printout t "will affect the heating efficiency of your system.                    " crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (ask-continue)
  (restart-program)
)

(defrule r_goodbye ""
  (thefocus end)
  =>
  (printout t crlf)
  (printout t "======================================================================" crlf)
  (printout t "Thank You for using the JDR HVAC Diagnostics Expert System."            crlf)
  (printout t "======================================================================" crlf)
  (printout t "University of Central Florida - EEL5874 - Spring 2011"                  crlf)
  (printout t crlf)
  (printout t "Programmed by:"                                                         crlf)
  (printout t "Joseph A. Del Rocco"                                                    crlf)
  (printout t "University of Central Florida"                                          crlf)
  (printout t crlf)
  (printout t "Expert knowledge provided by:"                                          crlf)
  (printout t "Joseph J. Del Rocco"                                                    crlf)
  (printout t "Walt Disney Company - Engineering"                                      crlf)
  (printout t "======================================================================" crlf)
  (printout t crlf)
  (exit)
)

(defrule r_diagnosis ""
  (diagnosis ?d)
  (diaginfo  ?d ?desc $?explanation)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "Diagnosis -> " ?desc crlf)
  (printout t crlf)
  (foreach ?i $?explanation (printout t ?i crlf))
  (printout t "----------------------------------------------------------------------" crlf)
  (ask-continue)
  (restart-program)
)

;;-------------------------------------
;; COMMON DIAGNOSTICS
;;-------------------------------------

(defrule r_common_power ""
  (or (thefocus heat) (thefocus cool))
  (working-now FALSE)
  =>
  (assert (power (ask-yes-or-no "Does the unit have incoming power (~240v single phase)? (y/n) ")))
)

(defrule r_common_calibration ""
  (or (thefocus heat) (thefocus cool))
  (thermostat TRUE)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "Set the thermostat temperature to the respective extreme, really high"  crlf)
  (printout t "if heating, really low if cooling."                                     crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t crlf)
  (assert (evap-fan (ask-yes-or-no "Does the evaporator fan come on (allow for delay)? (y/n) ")))
)

(defrule r_common_status ""
  (or (thefocus heat) (thefocus cool))
  (thermostat TRUE)
  (evap-fan TRUE)
  =>
  (assert (working-now (ask-yes-or-no "Is unit blowing conditioned air now (allow for delay)? (y/n) ")))
)

;;------------

(defrule r_common_evap_fan_dead ""
  (or (thefocus heat) (thefocus cool))
  (evap-fan FALSE)
  =>
  (assert (diagnosis evap_fan_dead))
)

(defrule r_common_thermostat_wrong ""
  (or (thefocus heat) (thefocus cool))
  (thermostat FALSE)
  =>
  (assert (diagnosis thermostat_wrong))
)

(defrule r_common_miscalibration ""
  (or (thefocus heat) (thefocus cool))
  (thermostat TRUE)
  (evap-fan TRUE)
  (working-now TRUE)
  =>
  (assert (diagnosis thermostat_calibration))
)

(defrule r_common_open_breaker ""
  (or (thefocus heat) (thefocus cool))
  (power FALSE)
  =>
  (assert (diagnosis open_breaker))
)

;;-------------------------------------
;; COOLING DIAGNOSTICS
;;-------------------------------------

(defrule r_cool ""
  (thefocus cool)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "The system will now attempt to diagnose the problem of not cooling."    crlf)
  (printout t crlf)
  (printout t "Note that this could be due to any number of conditions including a"    crlf)
  (printout t "bad compressor, bad condensing fan or coil, low freon charge, dirty"    crlf)
  (printout t "evaporator coil, bad contactor on condensing unit, etc."                crlf)
  (printout t crlf)
  (printout t "Note that many residential systems are 2-unit systems.  The inside"     crlf)
  (printout t "unit ('air-handler') houses the evaporator fan, coil, drainpan, filter" crlf)
  (printout t "drain-line, heating circuit, step-down transformer, thermostat connex," crlf)
  (printout t "etc.  This is the unit that moves the air throughout the house.  The"   crlf)
  (printout t "outside unit ('condensing unit') houses the compressor, condensing"     crlf)
  (printout t "coil, a cooling fan, etc.  If your HVAC system is only 1-unit, all"     crlf)
  (printout t "of these components will be in that one unit obviously."                crlf)
  (printout t crlf)
  (printout t "Note that in general, almost all residential HVAC thermostats will use" crlf)
  (printout t "the following color convention for thermostat control wires:"           crlf)
  (printout t " (Y)ellow = cool"                                                       crlf)
  (printout t " (W)hite  = heat"                                                       crlf)
  (printout t " (G)reen  = fan"                                                        crlf)
  (printout t "Of course there may be additional wires as well, but the ones above"    crlf)
  (printout t "are very common.  Keep this in mind during diagnostics."                crlf)
  (printout t crlf)
  (printout t "Note that you might have to wait a bit for the evaporator fan to turn"  crlf)
  (printout t "on if the system has a sequencer (turns the fan on after some delay)."  crlf)
  (printout t "Consider this delay before answering the evap. fan-related questions."  crlf)
  (printout t "This applies the condensing fan as well."                               crlf)
  (printout t crlf)
  (printout t "Please turn the system on and set it to COOL."                          crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t crlf)
  (bind ?set  (ask-yes-or-no "Is the thermostat set to COOL? (y/n) "))
  (bind ?temp (ask-yes-or-no "Is the temperature set BELOW ambient temperature? (y/n) "))
  (if (and (eq ?set TRUE) (eq ?temp TRUE)) then (assert (thermostat TRUE)) else (assert (thermostat FALSE)))
)

(defrule r_cool_gages ""
  (thefocus cool)
  (compressor TRUE)
  (condensing-fan TRUE)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "When set to cool, if both the condensing fan and the compressor are"    crlf)
  (printout t "running, then the best way to diagnose is to apply the gages and read"  crlf)
  (printout t "the head pressure (HP) and back pressure (BP).  These pressures alone"  crlf)
  (printout t "can indicate a lot to an HVAC diagnostic expert."                       crlf)
  (printout t crlf)
  (printout t "Connect the gages where possible, typically on the condensing unit."    crlf)
  (printout t "Read the HP and BP pressures.  Note that the pressures below pertain"   crlf)
  (printout t "to an HVAC system charged with freon-22 particularly, whereas a system" crlf)
  (printout t "with freon-410A runs at higher pressures."                              crlf)
  (printout t crlf)
  (printout t "Which of the following conditions is true? "                            crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "(1) HP > ~400"                                                          crlf)
  (printout t "(2) HP = ~200-250, BP starts normal, then runs to 0 or vacuum"          crlf)
  (printout t "(3) HP < ~200,     BP = ~40-50  (assuming high ambient temperature)"    crlf)
  (printout t "(4) HP < ~150,     BP = ~80-100"                                        crlf)
  (printout t "(5) HP = BP"                                                            crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (bind ?i (ask-question "Please select a menu item above: " 1 2 3 4 5))
  (assert (gages-indicate (nth$ ?i (create$ restriction refrigerant-circuit freon compressor-valves compressor-mechanical))))
)

(defrule r_cool_compressor_LRA ""
  (thefocus cool)
  (or (compressor-resistance good) (compressor-restart FALSE))
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "The compressor could be in a locked-rotor amperage (LRA) state, which"  crlf)
  (printout t "occurs when the compressor is trying to start but the rotor is locked"  crlf)
  (printout t "for some reason.  The compressor keeps drawing amperage, but is not"    crlf)
  (printout t "actually compressing anything, and thus the amperage builds up."        crlf)
  (printout t crlf)
  (printout t "If in LRA state, you can typically hear an atypical loud hum coming"    crlf)
  (printout t "from the compressor before it shuts off prematurely."                   crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t crlf)
  (assert (compressor-in-LRA (ask-yes-or-no "Is the compressor in LRA? (y/n) ")))
)

(defrule r_cool_compressor_restart ""
  (thefocus cool)
  (compressor-resistance-now TRUE)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "It is very likely that the internal overload is triggering."            crlf)
  (printout t crlf)
  (printout t "Reconnect the compressor and feed line voltage to it again (assuming"   crlf)
  (printout t "thermostat still set to cool).  The compressor may start now."          crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t crlf)
  (assert (compressor-restart (ask-yes-or-no "Does the compressor start now? (y/n) ")))
)

(defrule r_cool_compressor_recheck ""
  (thefocus cool)
  (compressor-hot TRUE)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "Cool the compressor down - either wait for it to cool (if in shade),"   crlf)
  (printout t "or take a hose and run it over the compressor for a bit.  It should be" crlf)
  (printout t "cool enough to touch, not even warm."                                   crlf)
  (printout t crlf)
  (printout t "Once the compressor has cooled-down, check for resistance again across" crlf)
  (printout t "(C)ommon with (S)tart or (R)un, both scenarios."                        crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t crlf)
  (assert (compressor-resistance-now (ask-yes-or-no "Is there resistance now? (y/n) ")))
)

(defrule r_cool_compressor_overload ""
  (thefocus cool)
  (compressor-resistance overload)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "The compressor's internal overload may have triggered, which happens"   crlf)
  (printout t "when the windings are hotter than they should be."                      crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t crlf)
  (assert (compressor-hot (ask-yes-or-no "Is the compressor very hot? (y/n) ")))
)

(defrule r_cool_compressor_wires_resistance ""
  (thefocus cool)
  (compressor-voltage TRUE)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "With the power still off for the condensing unit, check resistance"     crlf)
  (printout t "across the compressor wires by removing the ends not connected to the"  crlf)
  (printout t "compressor, and then ohm check them.  Check the resistance across all," crlf)
  (printout t "(C)ommon to (R)un, (C)ommon to (S)tart, (R)un to (S)tart."              crlf)
  (printout t crlf)
  (printout t "What is the result of the ohm check across the wires? "                 crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "(1) Resistance between all the wires."                                  crlf)
  (printout t "(2) No resistance between (R)un and (S)tart."                           crlf)
  (printout t "(3) No resistance between (C)ommon and either (R)un or (S)tart."        crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (bind ?i (ask-question "Please select a menu item above: " 1 2 3))
  (assert (compressor-resistance (nth$ ?i (create$ good bad overload))))
)

(defrule r_cool_compressor_wires_visual ""
  (thefocus cool)
  (compressor FALSE)
  (condensing-fan TRUE)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "Cut the line voltage to the condensing unit."                           crlf)
  (printout t crlf)
  (printout t "Inspect the compressor terminal connection.  Gain access by removing"   crlf)
  (printout t "the terminal cover at the condensing unit.  If the unit is outside,"    crlf)
  (printout t "you may even have to remove the grill and fan as well to access it."    crlf)
  (printout t crlf)
  (printout t "Inspect the compressor terminal wires specifically (typically 3)."      crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t crlf)
  (assert (compressor-wires-burnt (ask-yes-or-no "Do any of the terminal wires look burnt? (y/n) ")))
)

(defrule r_cool_compressor_terminal ""
  (thefocus cool)
  (compressor-wires-burnt FALSE)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "Whether the compressor terminal wires are burnt or not, you still have" crlf)
  (printout t "to make sure that you have power across all the wires (typically 3)."   crlf)
  (printout t "Check power across the (C)ommon to (R)un circuit and check power"       crlf)
  (printout t "across the (C)ommon to (S)tart circuit."                                crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t crlf)
  (assert (compressor-voltage (ask-yes-or-no "Do you have proper voltage to the compressor (~240)? (y/n) ")))
)

(defrule r_cool_terminal ""
  (thefocus cool)
  (contactor FALSE)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "Remove the thermostat cover.  Check the terminal of the (Y)ellow"       crlf)
  (printout t "cooling wire sending the signal to the contactor in the condensing"     crlf)
  (printout t "unit.  We already know there is no charge on the wire itself."          crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t crlf)
  (assert (terminal (ask-yes-or-no "Is the (Y)ellow wire terminal energized (~24v)? (y/n) ")))
)

(defrule r_cool_contactor ""
  (thefocus cool)
  (condensing-fan FALSE)
  (compressor FALSE)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "There is a contactor (relay) in the condensing unit (outside unit)"     crlf)
  (printout t "that you can gain access to via a panel somewhere on the unit"          crlf)
  (printout t "typically near where the power and freon lines are connected.  This"    crlf)
  (printout t "contactor receives a (24v) signal from the thermostat and closes the"   crlf)
  (printout t "points that feed the (240v) power to the compressor and fan motor."     crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t crlf)
  (assert (contactor (ask-yes-or-no "Is the condensing contactor energized (~24v)? (y/n) ")))
)

(defrule r_cool_condensing_fan ""
  (thefocus cool)
  (power TRUE)
  =>
  (assert (condensing-fan (ask-yes-or-no "Is condenser fan running (outside unit cooling condensing unit)? (y/n) ")))
)

(defrule r_cool_compressor ""
  (thefocus cool)
  (power TRUE)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "The compressor is typically located within the outside unit and has a"  crlf)
  (printout t "very distinct, loud hum when running.  You can have someone turn the"   crlf)
  (printout t "HVAC system on for you while you listen outside, or often there is a"   crlf)
  (printout t "separate breaker located outside near the condensing unit that can be"  crlf)
  (printout t "flipped on/off."                                                        crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t crlf)
  (assert (compressor (ask-yes-or-no "Can you hear the compressor running (typically outside)? (y/n) ")))
)

;;------------

(defrule r_cool_condensing_fan_dead ""
  (thefocus cool)
  (compressor TRUE)
  (condensing-fan FALSE)
  =>
  (assert (diagnosis condensing_fan_dead))
)

(defrule r_cool_bad_contactor ""
  (thefocus cool)
  (contactor TRUE)
  =>
  (assert (diagnosis bad_contactor))
)

(defrule r_cool_bad_thermostat ""
  (thefocus cool)
  (terminal FALSE)
  =>
  (assert (diagnosis bad_thermostat))
)

(defrule r_cool_bad_y_wire ""
  (thefocus cool)
  (terminal TRUE)
  =>
  (assert (diagnosis bad_y_wire))
)

(defrule r_cool_burnt_compressor_wires ""
  (thefocus cool)
  (compressor-wires-burnt TRUE)
  =>
  (assert (diagnosis burnt_compressor_wires))
)

(defrule r_cool_bad_compressor_wires ""
  (thefocus cool)
  (compressor-voltage FALSE)
  =>
  (assert (diagnosis bad_compressor_wires))
)

(defrule r_cool_bad_compressor_circuit ""
  (thefocus cool)
  (or (compressor-resistance bad) (compressor-hot TRUE) (compressor-resistance-now FALSE) (compressor-in-LRA FALSE))
  =>
  (assert (diagnosis bad_compressor_circuit))
)

(defrule r_cool_low_freon ""
  (thefocus cool)
  (or (compressor-restart TRUE) (gages-indicate freon))
  =>
  (assert (diagnosis low_freon))
)

(defrule r_cool_compressor_in_LRA ""
  (thefocus cool)
  (compressor-in-LRA TRUE)
  =>
  (assert (diagnosis compressor_in_LRA))
)

(defrule r_cool_air_restriction ""
  (thefocus cool)
  (gages-indicate restriction)
  =>
  (assert (diagnosis air_restriction))
)

(defrule r_cool_refrigerant_circuit ""
  (thefocus cool)
  (gages-indicate refrigerant-circuit)
  =>
  (assert (diagnosis refrigerant_circuit))
)

(defrule r_cool_bad_compressor_valves ""
  (thefocus cool)
  (gages-indicate compressor-valves)
  =>
  (assert (diagnosis bad_compressor_valves))
)

(defrule r_cool_bad_compressor_pistons ""
  (thefocus cool)
  (gages-indicate compressor-mechanical)
  =>
  (assert (diagnosis bad_compressor_pistons))
)

(defrule r_cool_DEFAULT ""
  (declare (salience -1000))
  (thefocus cool)
  =>
  (assert (diagnosis cool_DEFAULT))
)

;;-------------------------------------
;; HEATING DIAGNOSTICS
;;-------------------------------------

(defrule r_heat ""
  (thefocus heat)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "The system will now attempt to diagnose the problem of not heating."    crlf)
  (printout t crlf)
  (printout t "Note that this could be due to any number of conditions including a"    crlf)
  (printout t "burnt out heating element or fuseable link, bad heating contactor,"     crlf)
  (printout t "problem with the fan, severly dirty/clogged filter, bad HLS, etc."      crlf)
  (printout t "This expert system will diagnose all the most common cases.  If this"   crlf)
  (printout t "program cannot identify the problem and the unit is still not heating," crlf)
  (printout t "then you'll need to consider contacting a certified technician."        crlf)
  (printout t crlf)
  (printout t "Note that in general, almost all residential HVAC thermostats will use" crlf)
  (printout t "the following color convention for thermostat control wires:"           crlf)
  (printout t " (Y)ellow = cool"                                                       crlf)
  (printout t " (W)hite  = heat"                                                       crlf)
  (printout t " (G)reen  = fan"                                                        crlf)
  (printout t "Of course there may be additional wires as well, but the ones above"    crlf)
  (printout t "are very common.  Keep this in mind during diagnostics."                crlf)
  (printout t crlf)
  (printout t "Note that you might have to wait a bit for the evaporator fan to turn"  crlf)
  (printout t "on if the system has a sequencer (turns the fan on after some delay)."  crlf)
  (printout t "Consider this delay before answering the evap. fan-related questions."  crlf)
  (printout t crlf)
  (printout t "Please turn the system on and set it to HEAT."                          crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t crlf)
  (bind ?set  (ask-yes-or-no "Is the thermostat set to HEAT? (y/n) "))
  (bind ?temp (ask-yes-or-no "Is the temperature set ABOVE ambient temperature? (y/n) "))
  (if (and (eq ?set TRUE) (eq ?temp TRUE)) then (assert (thermostat TRUE)) else (assert (thermostat FALSE)))
)

(defrule r_heat_air_restriction ""
  (thefocus heat)
  (HLS-on-state toggle)
  =>
  (assert (air-filter-dirty (ask-yes-or-no "Is the air-filter very dirty (or other air restriction)? (y/n) ")))
)

(defrule r_heat_HLS_state ""
  (thefocus heat)
  (HLS-off-state FALSE)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "Turn the HVAC unit back on (set to heat)."                              crlf)
  (printout t "Stick a temperature probe in the exhaust duct downstream of elements."  crlf)
  (printout t crlf)
  (printout t "What is the state of the HLS? "                                         crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "(1) HLS opens immediately when unit starts heating."                    crlf)
  (printout t "(2) HLS opens prematurely before temperature gets hot (> 150F)."        crlf)
  (printout t "(3) HLS seems to be cycling on/off regularly when temp is very high."   crlf)
  (printout t "(4) HLS stays closed (doesn't interrupt heating circuit)."              crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (bind ?i (ask-question "Please select a menu item above: " 1 2 3 4))
  (assert (HLS-on-state (nth$ ?i (create$ bad bad toggle good))))
)

(defrule r_heat_HLS_test ""
  (thefocus heat)
  (w-wire TRUE)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "Somewhere along the heating circuit exists a high limit switch (HLS)."  crlf)
  (printout t "In fact there may be more than one, though this is rare.  This switch"  crlf)
  (printout t "is a bi-metal switch that is designed to open the heating circuit if"   crlf)
  (printout t "the heating air gets too hot, which protects the elements from over-"   crlf)
  (printout t "heating and the unit from putting out air that is too hot.  Check to"   crlf)
  (printout t "see if the HLS is open all the time or opening prematurely in general." crlf)
  (printout t crlf)
  (printout t "Turn the unit off, remove one wire from the HLS and check resistence"   crlf)
  (printout t "across it with an ohm-meter.  You should get no resistence if the HLS"  crlf)
  (printout t "is closed, which is the expected state when the unit is off."           crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t crlf)
  (assert (HLS-off-state (ask-yes-or-no "Is the HLS open when the HVAC unit is off? (y/n) ")))
)

(defrule r_heat_elements ""
  (thefocus heat)
  (contactors-load TRUE)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "Check power at the heating elements themselves."                        crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t crlf)
  (assert (elements-power (ask-yes-or-no "Is each heating element energized (~240v)? (y/n) ")))
)

(defrule r_heat_w_wire ""
  (thefocus heat)
  (thermostat-power TRUE)
  =>
  (assert (w-wire (ask-yes-or-no "Is the (W)hite heating wire to unit energized (~24v)? (y/n) ")))
)

(defrule r_heat_thermostat_power ""
  (thefocus heat)
  (contactors-power FALSE)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "Remove the cover to the thermostat so you can check the power there to" crlf)
  (printout t "see if it is routing power back to the heating circuit."                crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t crlf)
  (assert (thermostat-power (ask-yes-or-no "Is the thermostat energized (~24v)? (y/n) ")))
)

(defrule r_heat_contactors_load ""
  (thefocus heat)
  (contactors-power TRUE)
  =>
  (assert (contactors-load (ask-yes-or-no "Is there power on load side of each heating contactor (~24v)? (y/n) ")))
)

(defrule r_heat_contactors_power ""
  (thefocus heat)
  (power TRUE)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "Inspect the heating contactors on the heating circuits, which are"      crlf)
  (printout t "relays that control power to the heating elements.  There could be any" crlf)
  (printout t "number of these in the unit (one per element, one total, 2, etc.  You"  crlf)
  (printout t "need to inspect each one."                                              crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t crlf)
  (assert (contactors-power (ask-yes-or-no "Is each heating contactor energized (~24v)? (y/n) ")))
)

;;------------

(defrule r_heat_bad_contactor ""
  (thefocus heat)
  (contactors-load FALSE)
  =>
  (assert (diagnosis bad_heating_contactor))
)

(defrule r_heat_bad_transformer ""
  (thefocus heat)
  (thermostat-power FALSE)
  =>
  (assert (diagnosis bad_transformer))
)

(defrule r_heat_bad_w_wire ""
  (thefocus heat)
  (w-wire FALSE)
  =>
  (assert (diagnosis bad_w_wire))
)

(defrule r_heat_bad_element ""
  (thefocus heat)
  (elements-power TRUE)
  =>
  (assert (diagnosis bad_element))
)

(defrule r_heat_bad_element_wire ""
  (thefocus heat)
  (elements-power FALSE)
  =>
  (assert (diagnosis bad_element_wire))
)

(defrule r_heat_bad_HLS ""
  (thefocus heat)
  (or (HLS-off-state TRUE) (HLS-on-state bad) (air-filter-dirty FALSE))
  =>
  (assert (diagnosis bad_HLS))
)

(defrule r_heat_dirty_filter ""
  (thefocus heat)
  (air-filter-dirty TRUE)
  =>
  (assert (diagnosis dirty_filter))
)

(defrule r_heat_DEFAULT ""
  (declare (salience -1000))
  (thefocus heat)
  =>
  (assert (diagnosis heat_DEFAULT))
)

;;-------------------------------------
;; LEAKING WATER DIAGNOSTICS
;;-------------------------------------

(defrule r_leak ""
  (thefocus leak)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "The system will now attempt to diagnose the leaking problem."           crlf)
  (printout t crlf)
  (printout t "Note that this is typically due to either a frozen coil, clogged"       crlf)
  (printout t "drainline, or piping leak in a water-cooled system, because in general" crlf)
  (printout t "there are no other places from which water could flowing."              crlf)
  (printout t "If you are positive that the neither of these conditions are true,"     crlf)
  (printout t "then it is likely that the leak is not actually coming from the HVAC"   crlf)
  (printout t "unit itself, but from an alternative source (maybe from a water pipe"   crlf)
  (printout t "in a wall nearby the HVAC unit, etc.)"                                  crlf)
  (printout t crlf)
  (printout t "Note that most residential HVAC systems are not water-cooled, however"  crlf)
  (printout t "if so, they are typically a one-unit indoor system with no outside"     crlf)
  (printout t "component.  The indoor air-handler houses all system components like"   crlf)
  (printout t "condenser, compressor, evaporator, motor, etc. and the cooling water"   crlf)
  (printout t "circuit is used to remove heat in the condenser."                       crlf)
  (printout t crlf)
  (printout t "Please remove the cover of the indoor air-handler to gain access to"    crlf)
  (printout t "the coil, drainpan, drainline, etc.  You will need a basic screwdriver" crlf)
  (printout t "for the cover, either phillips, star, or appropriate nut-driver."       crlf)
  (printout t crlf)
  (printout t "Please turn the system on and set it to COOL."                          crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t crlf)
  (assert (water-cooled (ask-yes-or-no "Is the system water-cooled? (y/n) ")))
  (assert (cooling (ask-yes-or-no "When you set the unit to COOL, is it actually blowing cold air? (y/n) ")))
)

(defrule r_leak_drainpan ""
  (thefocus leak)
  (cooling TRUE)
  =>
  (assert (drainpan-bad (ask-yes-or-no "Is the drain-pan pretty rusty and old, or do you see any cracks/holes? (y/n) ")))
)

(defrule r_leak_drainage ""
  (thefocus leak)
  (cooling TRUE)
  =>
  (assert (drainpan-overflow (ask-yes-or-no "Is there water overflowing from the drain-pan? (y/n) ")))
  (assert (drainline-flowing (ask-yes-or-no "Is there any water draining from drain-line (typically outside)? (y/n) ")))
)

(defrule r_leak_coil ""
  (thefocus leak)
  (cooling FALSE)
  =>
  (assert (ice-on-coil (ask-yes-or-no "Is there ice or frost on the evaporator coil? (y/n) ")))
)

(defrule r_leak_wcc ""
  (declare (salience 1000))
  (thefocus leak)
  (water-cooled TRUE)
  =>
  (printout t crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t "Inspect the water cooling circuit (piping) within the air-handler."     crlf)
  (printout t "Water in this piping is under pressure, so any leak should be obvious." crlf)
  (printout t "Look for a cracked pipe or leaking joint."                              crlf)
  (printout t "----------------------------------------------------------------------" crlf)
  (printout t crlf)
  (assert (wcc-leak (ask-yes-or-no "Did you discover a leak along the water cooling circuit? (y/n) ")))
)

;;------------

(defrule r_leak_drainline_restricted ""
  (thefocus leak)
  (drainpan-overflow TRUE)
  (drainline-flowing TRUE)
  =>
  (assert (diagnosis drainline_restricted))
)

(defrule r_leak_drainline_clogged ""
  (thefocus leak)
  (drainpan-overflow TRUE)
  (drainline-flowing FALSE)
  =>
  (assert (diagnosis drainline_clogged))
)

(defrule r_leak_drainline_broken ""
  (thefocus leak)
  (drainpan-overflow FALSE)
  (drainline-flowing FALSE)
  (drainpan-bad FALSE)
  =>
  (assert (diagnosis drainline_broken))
)

(defrule r_leak_drainpan_leak ""
  (thefocus leak)
  (drainpan-overflow FALSE)
  (drainpan-bad TRUE)
  =>
  (assert (diagnosis drainpan_leaking))
)

(defrule r_leak_wcc_leak ""
  (thefocus leak)
  (wcc-leak TRUE)
  =>
  (assert (diagnosis wcc_leak))
)

(defrule r_leak_coil_icy ""
  (thefocus leak)
  (ice-on-coil TRUE)
  =>
  (assert (diagnosis ice_on_coil))
)

(defrule r_leak_DEFAULT ""
  (declare (salience -1000))
  (thefocus leak)
  =>
  (assert (diagnosis leak_DEFAULT))
)

;;-------------------------------------
;; DIAGNOSTIC EXPLANATIONS
;;-------------------------------------

(deffacts diaginfo
  ;--------------------------------------------------------------------
  ; COMMON COMMON COMMON COMMON COMMON COMMON COMMON COMMON COMMON
  ;--------------------------------------------------------------------
  (diaginfo thermostat_wrong "The thermostat is not setup properly."
    "For heating, make sure it is set to HEAT and the temperature is set"
    "ABOVE ambient temperature.  For cooling, make sure it is set to COOL"
    "and temperature is set BELOW ambient."
  )
  (diaginfo thermostat_calibration "The thermostat is likely miscalibrated."
    "If the unit is heating only when you set the temperature much higher"
    "than ambient, or cooling only when temp. set much lower than ambient,"
    "then it probably just needs to be recalibrated (depending on the type"
    "of thermostat).  If it is an older and mechanical one (with mercury),"
    "then a special wrench can be purchased for very little money, and the"
    "thermostat can simple be adjusted with it.  If the thermostat is"
    "newer and electronic, then it may not be possible to recalibrate it."
    "Search online for recalibrating your specific thermostat.  If you find"
    "nothing, then spend the money to buy a new one; they are much cheaper"
    "then the price of a new HVAC system."
  )
  (diaginfo evap_fan_dead "There is something wrong with the evaporator (indoor) fan."
    "It could be that the motor is bad, a blown capacitor, a relay on the"
    "circuit to the fan, bad wire, etc.  Check the fan relay and either"
    "repair or replace the fan."
    ""
    "It is possible that there are additional problems with the HVAC unit,"
    "however evaporator fan operation is absolutely necessary for not only"
    "pushing conditioned air, but also preventing the high limit switch"
    "form opening prematurely when heating."
  )
  (diaginfo open_breaker "A circuit breaker to the HVAC unit is open."
    "Check the main breaker box.  If you are positive that breakers to"
    "other appliances have power, then reset the breaker to HVAC unit."
    "Note there may be another breaker closer to the unit itself, either"
    "inside or outside near the air-handler or condensing unit (if exists),"
    "so make sure both have been reset.  If there is still no power, then"
    "one of those breakers needs to be replaced, if not both."
  )

  ;--------------------------------------------------------------------
  ; COOLING COOLING COOLING COOLING COOLING COOLING COOLING COOLING
  ;--------------------------------------------------------------------
  (diaginfo condensing_fan_dead "Something wrong with condensing-unit (outdoor) fan."
    "It could be that the motor is bad, a blown capacitor, bad wire, etc."
    "Note that it is not the condensing contactor, as you have indicated"
    "that the compressor is running.  Check the fan relay and either"
    "repair or replace the fan."
  )
  (diaginfo bad_contactor "Bad contactor for condensing unit."
    "You have indicated that both the condensing unit fan and compressor"
    "are not running, yet there is power being sent from the thermostat"
    "to the contactor, thus it must be bad.  Replace the contactor."
  )
  (diaginfo bad_thermostat "Bad thermostat circuit."
    "You have indicated that the main power breaker is on and that there"
    "is enough power to run the evaporator fan.  However the condensing"
    "contactor is not energized and now we know the (Y) terminal in the"
    "thermostat is not energized.  So there must be something wrong with"
    "the thermostat circuit itself.  You will probably have to replace"
    "the thermostat completely."
  )
  (diaginfo bad_y_wire "Thermostat cooling wire (Y) is bad."
    "The (Y)ellow cooling wire must be bad if the (Y) terminal is powered"
    "but there is no power to the contactor in the condensing unit."
    "Trace the wire, looking for damage, and replace section damaged or"
    "entire wire if possible."
  )
  (diaginfo burnt_compressor_wires "Compressor terminal wires are burnt."
    "This is a common scenario in hot climates because the combination"
	"of high amperage drawn (surged) by the compressor when starting,"
    "together with the hot weather, can cause the terminal wires to"
    "overheat.  Replace the wires as necessary."
  )
  (diaginfo bad_compressor_wires "At-least one of the compressor terminal wires are bad."
    "One of the main three compressor wires (C)ommon, (S)tart or (R)un are"
    "bad.  They may not be burnt, but they are not delivering proper"
    "voltage to the compressor.  Replace the wires."
  )
  (diaginfo bad_compressor_circuit "Compressor's internal electrical circuit is bad."
    "Either the start winding is damaged or the internal overload is not"
    "functioning properly.  The compressor itself should be replaced."
  )
  (diaginfo low_freon "The HVAC system is probably low on freon."
    "This can cause the compressor's windings to run hotter than they"
    "normally would, triggering an internal overload.  At the very least,"
    "the gages will show pressures lower than normal readings."
    "Apply gages and restore system to proper freon level.  If this"
    "happens again, especially within less than six months, then the"
    "system likely has a freon leak and needs to be properly leak"
    "checked."
  )
  (diaginfo compressor_in_LRA "Compressor rotor is locked (LRA state)."
    "If the unit is in a locked-rotor amperage (LRA) state, then you can"
    "apply what is called a 'starter-kit', to give the compressor an edge"
    "when starting.  Bascially it is a tiny capacitor that delays the"
    "power circuit by a very small amount in an attempt shift the voltage"
    "wave by just enough that it knocks the compressor with a little more"
    "juice when starting."
    ""
    "If a starter-kit has already been applied by this point, or if the"
    "compressor still doesn't start, then you may have to replace it."
  )
  (diaginfo air_restriction "Something is restricting the air-flow dramatically."
    "Typically this is due to a dirty condenser coil, which needs to be"
    "cleaned.  In some cases it may be due to a very dirty air filter."
    "It can also be due to bent fins on the condenser coil which also"
    "restricts air-flow across it, though this is less common, but can"
    "happen if someone has bumped it."
    ""
    "Replace the air-filter and clean the condenser coil CAREFULLY.  Do"
    "not bend any of the coil fins when doing so.  You can buy cleaner to"
    "break down the algae and dirt, and then use a hose to spray it down"
    "with pressure."
  )
  (diaginfo bad_compressor_valves "Compressor valves are worn or leaking."
    "The compressor will have to be replaced, as these are internal to the"
    "compressor itself."
  )
  (diaginfo bad_compressor_pistons "Compressor pistons are not actually compressing."
    "This is a mechanical failure of the compressor.  The motor may be"
    "running, so you hear the hum, but mechanically the pistons are not"
    "compressing for whatever reason internal to the compressor itself."
  )
  (diaginfo refrigerant_circuit "Restriction in refrigerant circuit."
    "This is a big job, you might consider having a certified technician"
    "repair this problem for you.  Typcially either the capilary tubes"
    "or the expansion valve need to be replaced, but gaining access to"
    "them can be quite difficult.  Often the system will have to drained"
    "of freon (not released into the air due to environmental standards),"
    "then the evaporator coil will most likely have to be removed as well."
  )
  (diaginfo cool_DEFAULT "HVAC system should be cooling."
    "You have indicated that the unit has power, the evaporator fan is"
    "blowing, the condenser fan is running, the compressor is running, the"
    "freon charges are appropriate, etc.  These are the most common"
    "scenarios that cause an HVAC system to not cool properly."
    ""
    "Other than an exhaustive search of each wire and capacitor in the"
    "system, you might want to consider contacting a certified technician."
  )

  ;--------------------------------------------------------------------
  ; HEATING HEATING HEATING HEATING HEATING HEATING HEATING HEATING
  ;--------------------------------------------------------------------
  (diaginfo bad_transformer "The step-down transformer is bad."
    "Each HVAC unit has a step-down transformer that converts the 240v"
    "main power down to 24v for the thermostat, because theremostat does"
    "not need that much power and it would be dangerous to power it so."
    "If the thermostat is not energized, then this is likely the issue."
    "Note that if your thermostat takes a battery, that the battery is"
    "typically only used for a digital display, not the powering of the"
    "thermostat itself."
  )
  (diaginfo bad_w_wire "Thermostat heating wire (W) or thermostat circuit is bad."
    "The thermostat is energized, but there is no power to the (W)hite"
    "heating wire.  There are only two possibilities here, either the"
    "wire itself is bad (most likely), or the thermostat circuit is bad."
    "Check the terminal to determine the difference.  If wire bad, then"
    "completely replace if possible.  If terminal is not energized, then"
    "you will likely have to replace the entire thermostat."
  )
  (diaginfo bad_heating_contactor "Bad heating contactor relay."
    "Replace each heating contactor that is bad.  These are just relays"
    "so it is much easier, cheaper to just replace them outright.  They"
    "could have burnt points, bad coil, etc."
  )
  (diaginfo bad_element "Bad heating element or fuseable link."
    "A heating element or its fuseable link is bad."
    "Replace whichever is bad, do this for each heating element.  This can"
    "happen if the element itself breaks or corrodes due to dirt, hair,"
    "moisture, etc."
  )
  (diaginfo bad_element_wire "Wire bad between heating contactor relay and heating element."
    "If possible, trace the wire and look for traces of damage along it."
    "If possible, replace the wire completely."
  )
  (diaginfo bad_HLS "The heating limit switch (HLS) is bad."
    "It could be opening prematurely or too late for any number of reasons,"
    "but given what you've indicated, it should be replaced."
  )
  (diaginfo dirty_filter "The air-filter is clogged or something else is restricting air flow."
    "Ensure the air-filter is not dirty enough to restrict air-flow.  A"
    "little dirt is ok, and actually will filter the air better, but too"
    "much will restrict air flow.  This may cause the temperature to get"
    "too hot, triggering the HLS.  Replace filter if necessary."
    ""
    "Though this is rare, you should also make sure nothing else is"
    "restricting air flow, including debris in the ducts, a dead animal,"
    "etc.  Air should be flowing through the system across the elements."
  )
  (diaginfo heat_DEFAULT "HVAC unit should be heating."
    "You have indicated that the unit has power, the fan is blowing, the"
    "heat circuits are complete, the thermostat is powered and configured"
    "properly, all of the heating elements and fuseable links are good and"
    "the high limit switch (HLS) is not opening prematurely.  These are"
    "the most common scenarios that cause an HVAC unit to not heat"
    "properly."
    ""
    "Other than an exhaustive search of each wire and capacitor in the"
    "system, you might want to consider contacting a certified technician."
  )

  ;--------------------------------------------------------------------
  ; LEAKING LEAKING LEAKING LEAKING LEAKING LEAKING LEAKING LEAKING
  ;--------------------------------------------------------------------
  (diaginfo wcc_leak "Water cooling circuit is leaking."
    "Turn the HVAC unit off immediately and repair the tubing or piping"
    "as necessary."
  )
  (diaginfo drainline_clogged "Drain-line is clogged."
    "The drainline is most likely clogged."
    "Flush it (clear it) by using an air-tank or pressurized water line."
    "Yearly preventative maintenance includes pouring a little cleaner"
    "or bleach down the drainline once a year."
  )
  (diaginfo drainline_restricted "Drain-line is resticted, but not clogged completely."
    "The drainline is likely gunked-up with something that is restricting"
    "the flow, perhaps some algae, rust, dirt or small dead animal."
    "Flush it (clear it) by using an air-tank or pressurized water line."
    "Yearly preventative maintenance includes pouring a little cleaner"
    "or bleach down the drainline once a year."
  )
  (diaginfo drainline_broken "Drainage has been is interrupted, but is not clogged."
    "The drain-line may be cracked or broken somewhere in the wall.  It"
    "could also have loosened near a fitting, if made of PVC."
    "Trace the drain-line to find the source of the leak.  Make sure"
    "all fittings are tight and there are no cracks or holes in piping."
  )
  (diaginfo drainpan_leaking "It is possible the drain-pan is leaking."
    "This can happen when the pan is very rusty (if metal), or if there"
    "is an actual hole in the pan.  Have it replaced or repair it."
  )
  (diaginfo ice_on_coil "Evaporator Coil is frozen over."
    "This can happen if the system is not cooling efficiently or at all."
    "Turn the HVAC unit off immediately and defrost the coil.  Be"
    "careful if attempting to remove the ice manually, as you could bend"
    "the fins on the coil.  Replace the air filter if it is wet and not"
    "washable.  NOTE: You should now diagnose the cooling problem."
  )
  (diaginfo leak_DEFAULT "HVAC unit is probably not leaking."
    "There may be another source of water nearby that is pooling near or"
    "around the unit making it look like it's leaking."
    "Look for water damage nearby and inspect pipes in the area."
    ""
    "It is also possible that you missed something when answering."
    "Run leaking diagnostics again and check carefully to make sure."
  )
)
