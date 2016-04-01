From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Fri, 1 Apr 2016 14:23:03 +0000
Subject: [lustre-devel] [RFC PATCH 0/3] staging: lustre: detypedef
In-Reply-To: <cover.1459515208.git.joe@perches.com>
References: <cover.1459515208.git.joe@perches.com>
Message-ID: <0586F4EF-3E2B-419A-8343-3A4A7E34628D@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>, James Simmons <jsimmons@infradead.org>
Cc: "<linux-kernel@vger.kernel.org>" <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "<devel@driverdev.osuosl.org>" <devel@driverdev.osuosl.org>, "<lustre-devel@lists.lustre.org>" <lustre-devel@lists.lustre.org>


On Apr 1, 2016, at 9:02 AM, Joe Perches wrote:

> Question about removing lustre typedefs.
> 
> Various bits of lustre code use a mix of struct foo and foo_t.
> 
> When would be an appropriate time to submit patches similar to
> below that individually remove various typedefs from lustre code?

I think now is as good time as any.
the only small correction is those are LNet typedefs.
While LNet is technically part of Lustre, it's a bit of a separate
thing useful without Lustre too.

I know James is working on cleaning up LNet, but I don't know if he has
anything this would be conflicting at this moment or not.

Thanks for the patches. I wonder if you are generating them automatically?
Because it would be great if it also fixes the alignment issues
due to longer definitions, like:
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -307,7 +307,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
		r = the_lnet.ln_routers.next;

		while (r != &the_lnet.ln_routers) {
-			lnet_peer_t *lp = list_entry(r, lnet_peer_t,
+			struct lnet_peer *lp = list_entry(r, struct lnet_peer,
						     lp_rtr_list);
that would need a separate patch to fix later.


> 
> These are pretty trivial to produce and verify so there's no
> particular hurry to do them now but applying them will require
> resync points for active and actually useful developers.
> 
> A few scripted examples are done:
> 
> Joe Perches (3):
>  staging: lustre: Remove typedef lnet_peer_t
>  staging: lustre: Remove typedef lnd_t
>  staging: lustre: Remove typedef lnet_msg_t
> 
> .../staging/lustre/include/linux/lnet/lib-lnet.h   | 62 +++++++--------
> .../staging/lustre/include/linux/lnet/lib-types.h  | 22 +++---
> .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  4 +-
> .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  6 +-
> .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  8 +-
> .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  2 +-
> .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |  6 +-
> .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |  6 +-
> drivers/staging/lustre/lnet/lnet/api-ni.c          | 16 ++--
> drivers/staging/lustre/lnet/lnet/lib-move.c        | 92 +++++++++++-----------
> drivers/staging/lustre/lnet/lnet/lib-msg.c         | 24 +++---
> drivers/staging/lustre/lnet/lnet/lib-ptl.c         |  4 +-
> drivers/staging/lustre/lnet/lnet/lo.c              |  8 +-
> drivers/staging/lustre/lnet/lnet/peer.c            | 30 +++----
> drivers/staging/lustre/lnet/lnet/router.c          | 28 +++----
> drivers/staging/lustre/lnet/lnet/router_proc.c     |  4 +-
> 16 files changed, 161 insertions(+), 161 deletions(-)
> 
> -- 
> 2.8.0.rc4.16.g56331f8
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
