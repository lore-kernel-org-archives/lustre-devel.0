From: Simmons, James A. <simmonsja@ornl.gov>
Date: Mon, 9 Nov 2015 21:41:15 +0000
Subject: [lustre-devel] next-20151101 - depmod issues with Lustre modules
In-Reply-To: <CAJwJo6YTNB38rYAYwExom4WW5yRJ9eUSXNV4a+xW026VY2iwTg@mail.gmail.com>
References: <8398.1446478793@turing-police.cc.vt.edu>
	<CAJwJo6YTNB38rYAYwExom4WW5yRJ9eUSXNV4a+xW026VY2iwTg@mail.gmail.com>
Message-ID: <966fe8db98d34137928b3cc86b7a2f17@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


>Reproduced on mainline v4.3-9038-g27eb427bdc0960 with
>Arch Linux default config (attached):
>
>depmod: ERROR: Found 2 modules in dependency cycles!
>depmod: ERROR: Cycle detected: lnet -> libcfs -> lnet
>make: *** [_modinst_post] Error 1

I submitted a patch (staging: lustre: remove IOC_LIBCFS_PING_TEST ioctl) to fix this.
It should be merged soon.
