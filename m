From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 7 Nov 2015 14:30:44 -0800
Subject: [lustre-devel] next-20151101 - depmod issues with Lustre modules
In-Reply-To: <CAJwJo6YTNB38rYAYwExom4WW5yRJ9eUSXNV4a+xW026VY2iwTg@mail.gmail.com>
References: <8398.1446478793@turing-police.cc.vt.edu>
	<CAJwJo6YTNB38rYAYwExom4WW5yRJ9eUSXNV4a+xW026VY2iwTg@mail.gmail.com>
Message-ID: <CA+55aFxJYvGWszcgbWe-xAnrm7p=RpmXz30jRVRTZM4PbQPZbA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, Nov 7, 2015 at 12:37 PM, Dmitry Safonov <0x7f454c46@gmail.com> wrote:
> Reproduced on mainline v4.3-9038-g27eb427bdc0960 with
> Arch Linux default config (attached):
>
> depmod: ERROR: Found 2 modules in dependency cycles!
> depmod: ERROR: Cycle detected: lnet -> libcfs -> lnet
> make: *** [_modinst_post] Error 1

The reason seems to be that

 - lnet.ko provides the following functions needed by libcfs.ko:

    libcfs_next_nidstring
    libcfs_nid2str_r

 - libcfs.ko provides the following functions needed by lnet.ko:

    libcfs_debug
    libcfs_debug_msg
    libcfs_deregister_ioctl
    libcfs_register_ioctl
    libcfs_subsystem_debug
    lustre_insert_debugfs

but I may have messed up something.

Anyway, the problem seems to be that - insanely - lnet.ko provides
those libcfs nid handling functions. They should be in libcfs, as far
as I can tell, just judging by the name. Also judging by the use.

The cause seems to be commit 47ca6ec2673e ("staging: lustre: move
nidstring handling to LNet layer") by James Simmons.

I do wonder if linux-next could perhaps do some modprobe testing too?

                      Linus
