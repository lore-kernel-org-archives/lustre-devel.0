From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 19 Dec 2017 00:52:06 +0000
Subject: [lustre-devel] [PATCH SERIES 4: 0/4] staging: lustre: use
 standard prng
In-Reply-To: <151356119565.24290.5570928075046338898.stgit@noble>
References: <151356119565.24290.5570928075046338898.stgit@noble>
Message-ID: <47156CF4-EC7A-40EB-B7B3-46D2E7B879D0@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

On Dec 17, 2017, at 18:41, NeilBrown <neilb@suse.com> wrote:
> 
> Lustre has its own internal PRNG code.
> This adds nothing of value to the Linux standard prng code,
> so switch over to using the standard interfaces.
> This adds a few callers to add_device_randomness(), which
> helps everyone, and removes unnecessary code.

Neil,
Thanks for the patches.  I'll run them through our testing system, but
they look good at first glance.

An interesting anecdote as this code is removed...  When it was first
added, we were running Lustre on a single-threaded runtime environment
without any local storage, interrupts, local clock, or h/w RNG (Catamount,
on the ASCI Red Storm https://en.wikipedia.org/wiki/Red_Storm_(computing)
supercomputer) and since there were thousands of nodes booting up and
mounting Lustre, there were often some with identical random number
states/seeds after boot, so we had to fold in the only unique state that
we had on each node - the network address.

That system is long gone, and it is good to clean up this code in a
more portable manner.

Cheers, Andreas


> ---
> 
> NeilBrown (4):
>      staging: lustre: replace cfs_rand() with prandom_u32_max()
>      staging: lustre: replace cfs_srand() calls with add_device_randomness().
>      staging: lustre: replace cfs_get_random_bytes calls with get_random_byte()
>      staging: lustre: libcfs: remove prng
> 
> 
> .../staging/lustre/include/linux/libcfs/libcfs.h   |   10 -
> drivers/staging/lustre/lnet/libcfs/Makefile        |    2 
> drivers/staging/lustre/lnet/libcfs/fail.c          |    2 
> drivers/staging/lustre/lnet/libcfs/prng.c          |  137 --------------------
> drivers/staging/lustre/lnet/lnet/net_fault.c       |   38 +++---
> drivers/staging/lustre/lnet/lnet/router.c          |   19 +--
> drivers/staging/lustre/lustre/include/obd_class.h  |    2 
> drivers/staging/lustre/lustre/llite/super25.c      |   17 +-
> drivers/staging/lustre/lustre/mgc/mgc_request.c    |    4 -
> .../lustre/lustre/obdclass/lustre_handles.c        |    9 -
> drivers/staging/lustre/lustre/ptlrpc/client.c      |    2 
> 11 files changed, 42 insertions(+), 200 deletions(-)
> delete mode 100644 drivers/staging/lustre/lnet/libcfs/prng.c
> 
> --
> Signature
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
