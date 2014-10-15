;; Copyright (c) 2014 Frank Terbeck <ft@bewatermyfriend.org>
;; All rights reserved.
;;
;; Terms for redistribution and use can be found in LICENCE.

(setlocale LC_ALL "")

(define cr-1 "Copyright (c) 2014 Frank Terbeck <ft@bewatermyfriend.org>")
(define cr-2 "All rights reserved.")
(define cr-3 "Terms for redistribution and use can be found in LICENCE.")

(define (strass fmt . args)
  "String assemble, in case you were wondering."
  (apply format #f fmt args))

(define gps-header
  `("/*"
    ,(strass " * ~a" cr-1)
    ,(strass " * ~a" cr-2)
    " *"
    ,(strass " * ~a" cr-3)
    " *"
    " * This file is generated by ‘gen-gps.scm’."
    " */"
    ""
    "#include <stddef.h>"
    "#include <stdlib.h>"
    "#include <stdint.h>"
    "#include <stdio.h>"
    "#include <errno.h>"
    ""
    "#include <termios.h>"
    "#include \"config.h\""
    ""
    "int"
    "main(int argc, char *argv[])"
    "{"
    ,(strass "    printf(\";; ~a\\n\");" cr-1)
    ,(strass "    printf(\";; ~a\\n\");" cr-2)
    "    printf(\";;\\n\");"
    ,(strass "    printf(\";; ~a\\n\");" cr-3)
    "    printf(\";;\\n\");"
    ,(strass "    printf(\";; ~a\\n\");"
             "This file is generated by ‘gen-platform-specifics.c‘.")
    "    printf(\"\\n\");"
    "    printf(\"(define-module (termios system)\\n\");"
    "    printf(\"  #:use-module (system foreign))\\n\");"))

(define gps-footer
  `(""
    "    return EXIT_SUCCESS;"
    "}"))

(define gps-types
  '((cc-t . cc_t)
    (speed-t . speed_t)
    (tcflag-t . tcflag_t)))

(define gps-defines
  '(NCCS
    B0
    B50
    B75
    B110
    B134
    B150
    B200
    B300
    B600
    B1200
    B1800
    B2400
    B4800
    B9600
    B19200
    B38400
    B57600
    B576000
    B115200
    B230400
    B460800
    B500000
    B921600
    B1000000
    B1152000
    B1500000
    B2000000
    B2500000
    B3000000
    B3500000
    B4000000
    BRKINT
    BS0
    BS1
    BSDLY
    CBAUD
    CBAUDEX
    CIBAUD
    CLOCAL
    CMSPAR
    CR0
    CR1
    CR2
    CR3
    CRDLY
    CREAD
    CRTSCTS
    CS5
    CS6
    CS7
    CS8
    CSIZE
    CSTOPB
    ECHO
    ECHOCTL
    ECHOE
    ECHOK
    ECHOKE
    ECHONL
    ECHOPRT
    EXTA
    EXTB
    EXTPROC
    FF0
    FF1
    FFDLY
    FLUSHO
    HUPCL
    ICANON
    ICRNL
    IEXTEN
    IGNBRK
    IGNCR
    IGNPAR
    IMAXBEL
    INLCR
    INPCK
    ISIG
    ISTRIP
    IUCLC
    IUTF8
    IXANY
    IXOFF
    IXON
    NL0
    NL1
    NLDLY
    NOFLSH
    OCRNL
    OFDEL
    OFILL
    OLCUC
    ONLCR
    ONLRET
    ONOCR
    OPOST
    PARENB
    PARMRK
    PARODD
    PENDIN
    TAB0
    TAB1
    TAB2
    TAB3
    TABDLY
    TCIFLUSH
    TCIOFLUSH
    TCIOFF
    TCION
    TCOFLUSH
    TCOOFF
    TCOON
    TCSADRAIN
    TCSAFLUSH
    TCSANOW
    TOSTOP
    VDISCARD
    VEOF
    VEOL
    VEOL2
    VERASE
    VINTR
    VKILL
    VLNEXT
    VMIN
    VQUIT
    VREPRINT
    VSTART
    VSTOP
    VSUSP
    VSWTC
    VSWTCH
    VT0
    VT1
    VTDLY
    VTIME
    VWERASE
    XCASE
    XTABS))

(define gps-offsets
  '((c-iflag c_iflag tcflag-t GUILE_TERMIOS_HAS_C_IFLAG)
    (c-oflag c_oflag tcflag-t GUILE_TERMIOS_HAS_C_OFLAG)
    (c-cflag c_cflag tcflag-t GUILE_TERMIOS_HAS_C_CFLAG)
    (c-lflag c_lflag tcflag-t GUILE_TERMIOS_HAS_C_LFLAG)
    (c-line c_line cc-t GUILE_TERMIOS_HAS_C_LINE)
    (c-cc c_cc "(make-list termios-NCCS cc-t)" GUILE_TERMIOS_HAS_C_CC)
    (c-ispeed c_ispeed speed-t GUILE_TERMIOS_HAS_C_ISPEED)
    (c-ospeed c_ospeed speed-t GUILE_TERMIOS_HAS_C_OSPEED)))

(define (print-list lst)
  (map (lambda (x)
         (display x)
         (newline))
       lst))

(define (print-types lst)
  (newline)
  (format #t "    printf(\"\\n;; Types:\\n\");~%")
  (map (lambda (x)
         (display "    printf(\"")
         (format #t "(define-public ~a uint%d)\\n\"," (car x))
         (format #t " sizeof(~a) * 8" (cdr x))
         (display ");")
         (newline))
       lst)
  (display "    printf(\"")
  (format #t "(define-public errno-t int%d)\\n\", (sizeof errno) * 8")
  (display ");")
  (newline))

(define (print-defines lst)
  (newline)
  (format #t "    printf(\"\\n;; #defines:\\n\");~%")
  (map (lambda (x)
         (format #t "#ifdef ~a~%" x)
         (format #t "    printf(\"(define-public termios-~a %ld)\\n\", ~a);~%"
                 x x)
         (format #t "#else~%")
         (format #t "    printf(\"(define-public termios-~a #f)\\n\");~%" x)
         (format #t "#endif /* ~a */~%" x))
       lst))

(define (print-offsets lst)
  (newline)
  (format #t "    printf(\"\\n;; struct termios:\\n\");~%")
  (format #t "    printf(\"(define-public termios-struct-offsets\\n (sort `(\\n\");~%")
  (map (lambda (x)
         (let ((needed-macro (cadddr x)))
           (format #t "#ifdef ~a~%" needed-macro)
           (format #t "    printf(\"  (~a %ld . ,~a)\\n\"" (car x) (caddr x))
           (format #t ", (long) offsetof(struct termios, ~a));~%" (cadr x))
           (format #t "#endif /* ~a */~%" needed-macro)))
       lst)
  (format #t "    printf(\"")
  (format #t " )\\n (lambda (x y) (< (cadr x) (cadr y)))))")
  (format #t "\\n\");~%"))

(print-list gps-header)
(print-types gps-types)
(print-defines gps-defines)
(print-offsets gps-offsets)
(print-list gps-footer)
