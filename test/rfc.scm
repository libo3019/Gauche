;;
;; testing rfc.* module
;;

(use gauche.test)
(test-start "rfc")

;;--------------------------------------------------------------------
(test-section "rfc.822")
(use rfc.822)

(define rfc822-header1
  "Received: by foo.bar.com id ZZZ55555; Thu, 31 May 2001 16:38:04 -1000 (HST)
Received: from ooo.ooo.com (ooo.ooo.com [1.2.3.4])
	by foo.bar.com (9.9.9+3.2W/3.7W-) with ESMTP id ZZZ55555
	for <yoo@bar.com>; Thu, 31 May 2001 16:38:02 -1000 (HST)
Received: from zzz ([1.2.3.5]) by ooo.ooo.com  with Maccrosoft SMTPSVC(5.5.1877.197.19);
	 Thu, 31 May 2001 22:33:16 -0400
Message-ID: <beefbeefbeefbeef@ooo.ooo.com>
Subject: Bogus Tester
From: Bogus Sender <bogus@ooo.com>
To: You <you@bar.com>, Another <another@ooo.com>
Date: Fri, 01 Jun 2001 02:37:31 (GMT)
Mime-Version: 1.0
Content-Type: text/html
Content-Transfer-Encoding: quoted-printable
X-MSMail-Priority: Normal
X-mailer: FooMail 4.0 4.03 (SMT460B92F)
Content-Length: 4349

")

(define rfc822-header1-list
  '(("received" "by foo.bar.com id ZZZ55555; Thu, 31 May 2001 16:38:04 -1000 (HST)")
    ("received" "from ooo.ooo.com (ooo.ooo.com [1.2.3.4])	by foo.bar.com (9.9.9+3.2W/3.7W-) with ESMTP id ZZZ55555	for <yoo@bar.com>; Thu, 31 May 2001 16:38:02 -1000 (HST)")
    ("received" "from zzz ([1.2.3.5]) by ooo.ooo.com  with Maccrosoft SMTPSVC(5.5.1877.197.19);	 Thu, 31 May 2001 22:33:16 -0400")
    ("message-id" "<beefbeefbeefbeef@ooo.ooo.com>")
    ("subject" "Bogus Tester")
    ("from" "Bogus Sender <bogus@ooo.com>")
    ("to" "You <you@bar.com>, Another <another@ooo.com>")
    ("date" "Fri, 01 Jun 2001 02:37:31 (GMT)")
    ("mime-version" "1.0")
    ("content-type" "text/html")
    ("content-transfer-encoding" "quoted-printable")
    ("x-msmail-priority" "Normal")
    ("x-mailer" "FooMail 4.0 4.03 (SMT460B92F)")
    ("content-length" "4349")
    ))

(test "rfc822-header->list" #t
      (lambda ()
        (equal? rfc822-header1-list
                (rfc822-header->list (open-input-string rfc822-header1)))))


;;--------------------------------------------------------------------
(test-section "rfc.base64")
(use rfc.base64)

(test "encode" "" (lambda () (base64-encode-string "")))
(test "encode" "YQ==" (lambda () (base64-encode-string "a")))
(test "encode" "MA==" (lambda () (base64-encode-string "0")))
(test "encode" "Cg==" (lambda () (base64-encode-string "\n")))
(test "encode" "YTA=" (lambda () (base64-encode-string "a0")))
(test "encode" "YTAK" (lambda () (base64-encode-string "a0\n")))
(test "encode" "PQk0" (lambda () (base64-encode-string "=\t4")))
(test "encode" "eTQ5YQ==" (lambda () (base64-encode-string "y49a")))
(test "encode" "RWdqYWk=" (lambda () (base64-encode-string "Egjai")))
(test "encode" "OTNiamFl" (lambda () (base64-encode-string "93bjae")))
(test "encode" "QkFSMGVyOQ==" (lambda () (base64-encode-string "BAR0er9")))

(test "decode" "" (lambda () (base64-decode-string "")))
(test "decode" "a" (lambda () (base64-decode-string "YQ==")))
(test "decode" "a" (lambda () (base64-decode-string "YQ=")))
(test "decode" "a" (lambda () (base64-decode-string "YQ")))
(test "decode" "a0" (lambda () (base64-decode-string "YTA=")))
(test "decode" "a0" (lambda () (base64-decode-string "YTA")))
(test "decode" "a0\n" (lambda () (base64-decode-string "YTAK")))
(test "decode" "y49a" (lambda () (base64-decode-string "eTQ5YQ==")))
(test "decode" "Egjai" (lambda () (base64-decode-string "RWdqYWk=")))
(test "decode" "93bjae" (lambda () (base64-decode-string "OTNiamFl")))
(test "decode" "BAR0er9" (lambda () (base64-decode-string "QkFSMGVyOQ==")))
(test "decode" "BAR0er9" (lambda () (base64-decode-string "QkFS\r\nMGVyOQ\r\n==")))

;;--------------------------------------------------------------------
(test-section "rfc.cookie")
(use rfc.cookie)

(test "parse, old" '(("foo" "bar")
                     ("aaa" "bbb" :path "/a/b" :domain "a.b.com")
                     ("x12" "Yy \"yY\" ;; Zz" :port "100, 200, 300")
                     ("zzz" #f)
                     ("_n_" "")
                     ("mmm" "ppp"))
      (lambda ()
        (parse-cookie-string " foo=bar; aaa = bbb ; $Path=/a/b;$Domain =a.b.com;x12=\"Yy \\\"yY\\\" ;; Zz\"; $Port=\"100, 200, 300\";zzz ;_n_=;mmm=ppp")))

(test "parse, new" '(("$Version" "1")
                     ("foo" "bar")
                     ("aaa" "bbb" :path "/a/b" :domain "a.b.com")
                     ("x12" "Yy \"yY\" ;; Zz" :port "100, 200, 300")
                     ("zzz" #f)
                     ("_n_" "")
                     ("mmm" "ppp"))
      (lambda ()
        (parse-cookie-string "$Version=1; foo=bar, aaa = bbb ; $Path=/a/b;$Domain =a.b.com,x12=\"Yy \\\"yY\\\" ;; Zz\"; $Port=\"100, 200, 300\",zzz ,_n_=,mmm=ppp")))

(test "parse, new" '(("foo" "bar")
                     ("aaa" "bbb" :path "/a/b" :domain "a.b.com")
                     ("x12" "Yy \"yY\" ;; Zz" :port "100, 200, 300")
                     ("zzz" #f)
                     ("_n_" "")
                     ("mmm" "ppp"))
      (lambda ()
        (parse-cookie-string " foo=bar, aaa = bbb ; $Path=/a/b;$Domain =a.b.com,x12=\"Yy \\\"yY\\\" ;; Zz\"; $Port=\"100, 200, 300\",zzz ,_n_=,mmm=ppp"
                      1)))

(define *cookie-spec*
  '(("guest-id" "foo123"
                :domain "foo.com" :path "/abc"
                :expires 1000000000 :max-age 864000
                :discard #t :comment "hogehoge"
                :comment-url "http://foo.com/hogehoge"
                :port "80, 8080" :version 1)
    ("guest-account" "87975348"
                     :domain "zzz.com" :path "/zzz"
                     :discard #f :secure #t :comment "ZzzZzz, OooOoo"
                     :comment-url "http://foo.com/hogehoge")))

(test "cookie, old"
      '("guest-id=foo123;Domain=foo.com;Path=/abc;Expires=Sun, 09-Sep-2001 01:46:40 GMT"
        "guest-account=87975348;Domain=zzz.com;Path=/zzz;Secure")
      (lambda ()
        (construct-cookie-string *cookie-spec* 0)))

(test "cookie, new"
      '("guest-id=foo123;Domain=foo.com;Path=/abc;Max-Age=864000;Discard;Comment=hogehoge;CommentURL=\"http://foo.com/hogehoge\";Port=\"80, 8080\";Version=1"
        "guest-account=87975348;Domain=zzz.com;Path=/zzz;Secure;Comment=\"ZzzZzz, OooOoo\";CommentURL=\"http://foo.com/hogehoge\"")
      (lambda ()
        (construct-cookie-string *cookie-spec* 1)))

;;--------------------------------------------------------------------
(test-section "rfc.uri")
(use rfc.uri)

(test "encode" "abc%3c%20%3e%20%22%20%23%25%7b%7c%7d%5c%5e"
      (lambda () (uri-encode-string "abc< > \" #%{|}\\^")))
(test "decode" "abc< > \" #%?{|}\\^"
      (lambda ()
        (uri-decode-string "abc%3c%20%3e%20%22%20%23%25%3f%7b%7c%7d%5c%5e")))
(test "decode" "abc<+>+\"+#%?{|}\\^"
      (lambda ()
        (uri-decode-string "abc%3c+%3e+%22+%23%25%3f%7b%7c%7d%5c%5e")))
(test "decode" "abc< > \" #%?{|}\\^"
      (lambda ()
        (uri-decode-string "abc%3c+%3e+%22+%23%25%3f%7b%7c%7d%5c%5e"
                           :cgi-decode #t)))



(test-end)

    