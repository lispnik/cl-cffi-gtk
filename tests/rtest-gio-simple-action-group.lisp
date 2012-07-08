;;; ----------------------------------------------------------------------------
;;; rtest-gio-simple-action-group.lisp
;;;
;;; Copyright (C) 2012 Dieter Kaiser
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU Lesser General Public License for Lisp
;;; as published by the Free Software Foundation, either version 3 of the
;;; License, or (at your option) any later version and with a preamble to
;;; the GNU Lesser General Public License that clarifies the terms for use
;;; with Lisp programs and is referred as the LLGPL.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU Lesser General Public License for more details.
;;;
;;; You should have received a copy of the GNU Lesser General Public
;;; License along with this program and the preamble to the Gnu Lesser
;;; General Public License.  If not, see <http://www.gnu.org/licenses/>
;;; and <http://opensource.franz.com/preamble.html>.
;;; ----------------------------------------------------------------------------

(asdf:operate 'asdf:load-op :lisp-unit)
(asdf:operate 'asdf:load-op :bordeaux-threads)
(asdf:operate 'asdf:load-op :cl-cffi-gtk-glib)

(defpackage :gio-tests
  (:use :gio :gobject :glib :cffi :common-lisp :lisp-unit))

(in-package :gio-tests)

;;; ----------------------------------------------------------------------------

(define-test gio-simple-action-group
  (assert-true  (g-type-is-object "GSimpleActionGroup"))
  (assert-false (g-type-is-abstract "GSimpleActionGroup"))
  (assert-true  (g-type-is-derived "GSimpleActionGroup"))
  (assert-false (g-type-is-fundamental "GSimpleActionGroup"))
  (assert-true  (g-type-is-value-type "GSimpleActionGroup"))
  (assert-true  (g-type-has-value-table "GSimpleActionGroup"))
  (assert-true  (g-type-is-classed "GSimpleActionGroup"))
  (assert-true  (g-type-is-instantiatable "GSimpleActionGroup"))
  (assert-true  (g-type-is-derivable "GSimpleActionGroup"))
  (assert-true  (g-type-is-deep-derivable "GSimpleActionGroup"))
  (assert-false (g-type-is-interface "GSimpleActionGroup"))

  ;; Check the registered name
  (assert-eq 'g-simple-action-group
             (registered-object-type-by-name "GSimpleActionGroup"))
  
  (let ((class (g-type-class-ref (gtype "GSimpleActionGroup"))))
    (assert-equal (gtype "GSimpleActionGroup")  (g-type-from-class class))
    (assert-equal (gtype "GSimpleActionGroup") (g-object-class-type class))
    (assert-equal "GSimpleActionGroup" (g-object-class-name class))
    (assert-equal (gtype "GSimpleActionGroup")
                  (g-type-from-class (g-type-class-peek "GSimpleActionGroup")))
    (assert-equal (gtype "GSimpleActionGroup")
                  (g-type-from-class (g-type-class-peek-static "GSimpleActionGroup")))
    (g-type-class-unref class))
  
  (let ((class (find-class 'g-simple-action-group)))
    ;; Check the class name and type of the class
    (assert-eq 'g-simple-action-group (class-name class))
    (assert-eq 'gobject-class (type-of class))
    (assert-eq (find-class 'gobject-class) (class-of class))
    ;; Properties of the metaclass gobject-class
    (assert-equal "GSimpleActionGroup" (gobject-class-g-type-name class))
    (assert-equal "GSimpleActionGroup" (gobject-class-direct-g-type-name class))
    (assert-equal "g_simple_action_group_get_type"
                  (gobject-class-g-type-initializer class))
    (assert-false (gobject-class-interface-p class)))
  
  (assert-equal (gtype "GObject") (g-type-parent "GSimpleActionGroup"))
  (assert-eql 2 (g-type-depth "GSimpleActionGroup"))
  (assert-eql   (gtype "GSimpleActionGroup")
                (g-type-next-base "GSimpleActionGroup" "GObject"))
  (assert-true  (g-type-is-a "GSimpleActionGroup" "GObject"))
  (assert-false (g-type-is-a "GSimpleActionGroup" "gboolean"))
  (assert-false (g-type-is-a "GSimpleActionGroup" "GtkWindow"))
  (assert-equal '("GApplicationExportedActions")
                (mapcar #'gtype-name (g-type-children "GSimpleActionGroup")))
  (assert-equal '("GActionGroup" "GActionMap")
                (mapcar #'gtype-name (g-type-interfaces "GSimpleActionGroup")))
  
  ;; Query infos about the class
  (with-foreign-object (query 'g-type-query)
    (g-type-query "GSimpleActionGroup" query)
    (assert-equal (gtype "GSimpleActionGroup")
                  (foreign-slot-value query 'g-type-query :type))
    (assert-equal "GSimpleActionGroup"
                  (foreign-slot-value query 'g-type-query :type-name))
    (assert-eql 116 (foreign-slot-value query 'g-type-query :class-size))
    (assert-eql  16 (foreign-slot-value query 'g-type-query :instance-size)))
  
  ;; Get the names of the class properties
  (assert-equal
       '()
     (mapcar #'param-spec-name
             (g-object-class-list-properties (gtype "GSimpleActionGroup"))))

  ;; Get the class definition
  (assert-equal
     '(DEFINE-G-OBJECT-CLASS "GSimpleActionGroup" G-SIMPLE-ACTION-GROUP
                               (:SUPERCLASS G-OBJECT :EXPORT T :INTERFACES
                                ("GActionGroup" "GActionMap"))
                               NIL)
     (get-g-class-definition (gtype "GSimpleActionGroup")))

  ;; Check functions
  (let ((simple (g-simple-action-group-new)))
    (g-signal-connect simple "action-added"
       (lambda (action-group action-name)
         (declare (ignore action-group))
         (format t "~&Signal ACTION-ADDED for ~A~%" action-name)))
    (g-signal-connect simple "action-enabled-changed"
       (lambda (action-group action-name enabled)
         (declare (ignore action-group enabled))
         (format t "Signal ACTION-ENABLED-CHANGED called for ~A~%" action-name)))
    (g-signal-connect simple "action-removed"
       (lambda (action-group action-name)
         (declare (ignore action-group))
         (format t "Signal ACTION-REMOVED called for ~A~%" action-name)))
    (g-signal-connect simple "action-state-changed"
       (lambda (action-group action-name value)
         (declare (ignore action-group value))
         (format t "Signal ACTION-REMOVED called for ~A~%" action-name)))

    (g-simple-action-group-insert simple
                                  (g-simple-action-new "first"
                                                       (g-variant-type-new "b")))
    (g-simple-action-group-insert simple
                                  (g-simple-action-new "second"
                                                       (g-variant-type-new "b")))
    (assert-eq 'g-simple-action
               (type-of (g-simple-action-group-lookup simple "first")))
    (assert-eq 'g-simple-action
               (type-of (g-simple-action-group-lookup simple "second")))

))

;;; --- End of file rtest-gio-simple-action-group.lisp -------------------------