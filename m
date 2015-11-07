From: Dmitry Safonov <0x7f454c46@gmail.com>
Date: Sat, 7 Nov 2015 23:37:40 +0300
Subject: [lustre-devel] next-20151101 - depmod issues with Lustre modules
In-Reply-To: <8398.1446478793@turing-police.cc.vt.edu>
References: <8398.1446478793@turing-police.cc.vt.edu>
Message-ID: <CAJwJo6YTNB38rYAYwExom4WW5yRJ9eUSXNV4a+xW026VY2iwTg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Reproduced on mainline v4.3-9038-g27eb427bdc0960 with
Arch Linux default config (attached):

depmod: ERROR: Found 2 modules in dependency cycles!
depmod: ERROR: Cycle detected: lnet -> libcfs -> lnet
make: *** [_modinst_post] Error 1

2015-11-02 18:39 GMT+03:00 Valdis Kletnieks <Valdis.Kletnieks@vt.edu>:
> next-20151101 compiles fine, but depmod has a cow:
>
> depmod: ERROR: Found 2 modules in dependency cycles!
> depmod: ERROR: Cycle detected: lnet -> libcfs -> lnet
>
> Sorry, not sure which commit(s) introduced the issue.  next-20151022
> was OK.
>
>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: config
Type: application/octet-stream
Size: 175569 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151107/6738d1cc/attachment-0001.obj>
