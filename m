From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Oct 2017 15:59:27 +1100
Subject: [lustre-devel] [PATCH 10/10] staging: lustre: obdclass: simplify
 cl_lock_fini()
In-Reply-To: <150933945578.22133.8029060522107378499.stgit@noble>
References: <150933945578.22133.8029060522107378499.stgit@noble>
Message-ID: <150933956737.22133.10532579319852492812.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

Using list_first_entry_or_null() makes this (slightly)
simpler.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/cl_lock.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index 20e64051d2d6..fa97f4b39bd1 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -78,13 +78,12 @@ EXPORT_SYMBOL(cl_lock_slice_add);
 
 void cl_lock_fini(const struct lu_env *env, struct cl_lock *lock)
 {
+	struct cl_lock_slice *slice;
 	cl_lock_trace(D_DLMTRACE, env, "destroy lock", lock);
 
-	while (!list_empty(&lock->cll_layers)) {
-		struct cl_lock_slice *slice;
-
-		slice = list_entry(lock->cll_layers.next,
-				   struct cl_lock_slice, cls_linkage);
+	while ((slice = list_first_entry_or_null(&lock->cll_layers,
+						 struct cl_lock_slice,
+						 cls_linkage)) != NULL) {
 		list_del_init(lock->cll_layers.next);
 		slice->cls_ops->clo_fini(env, slice);
 	}
