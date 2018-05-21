From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:12 +1000
Subject: [lustre-devel] [PATCH 09/30] staging: lustre: discard
 LOWEST_BIT_SET()
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731269.24196.12873538902260418047.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

This macro is only used once to test if a value is
a power of two.  So use is_power_of_2() instead and
discard the macro.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    2 --
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |    2 +-
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 7259544e4c32..084150e9d9ac 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -89,8 +89,6 @@
 
 #define LIBCFS_VERSION "0.7.0"
 
-#define LOWEST_BIT_SET(x)       ((x) & ~((x) - 1))
-
 /*
  * One jiffy
  */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index ea53b5cb3f72..c78e70373ab4 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -225,7 +225,7 @@ lnet_eq_enqueue_event(struct lnet_eq *eq, struct lnet_event *ev)
 	lnet_eq_wait_lock();
 	ev->sequence = eq->eq_enq_seq++;
 
-	LASSERT(eq->eq_size == LOWEST_BIT_SET(eq->eq_size));
+	LASSERT(is_power_of_2(eq->eq_size));
 	index = ev->sequence & (eq->eq_size - 1);
 
 	eq->eq_events[index] = *ev;
