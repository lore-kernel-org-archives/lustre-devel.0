From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 Nov 2016 14:35:45 -0500
Subject: [lustre-devel] [PATCH 07/19] staging: lustre: lnet: remove unused
	lib_me_dump
In-Reply-To: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
References: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479411357-28979-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Remove unused lib_me_dump.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/lib-me.c |   18 ------------------
 1 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index b430046..eb796a8 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -271,21 +271,3 @@
 	lnet_res_lh_invalidate(&me->me_lh);
 	lnet_me_free(me);
 }
-
-#if 0
-static void
-lib_me_dump(lnet_me_t *me)
-{
-	CWARN("Match Entry %p (%#llx)\n", me,
-	      me->me_lh.lh_cookie);
-
-	CWARN("\tMatch/Ignore\t= %016lx / %016lx\n",
-	      me->me_match_bits, me->me_ignore_bits);
-
-	CWARN("\tMD\t= %p\n", me->md);
-	CWARN("\tprev\t= %p\n",
-	      list_entry(me->me_list.prev, lnet_me_t, me_list));
-	CWARN("\tnext\t= %p\n",
-	      list_entry(me->me_list.next, lnet_me_t, me_list));
-}
-#endif
-- 
1.7.1
