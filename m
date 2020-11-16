From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:39 -0500
Subject: [lustre-devel] [PATCH 06/28] lustre: use memalloc_nofs_save() for
 GFP_NOFS kvmalloc allocations.
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.de>

The allocation of lo_sub should be GFP_NOFS as it can happen in support
of write-out, and should allow vmalloc as the array can be as much as
2000 pointers (16K).
So change it to kvmalloc_array() and use memalloc_nofs_save() as
GFP_NOFS doesn't work in kvmalloc_array().

The allocation in echo_client passes GFP_NOFS to kvmalloc_array()
which causes it to map directly to kmalloc_array().
So use memalloc_nofs_save() there too.

Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/lustre/lov/lov_object.c      | 13 +++++++------
 fs/lustre/obdecho/echo_client.c |  7 ++++++-
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 7285276..0762cc5 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -38,6 +38,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
+#include <linux/sched/mm.h>
 #include "lov_cl_internal.h"
 
 static inline struct lov_device *lov_object_dev(struct lov_object *obj)
@@ -207,6 +208,7 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 	struct cl_object_conf *subconf = &lti->lti_stripe_conf;
 	struct lu_fid *ofid = &lti->lti_fid;
 	struct cl_object *stripe;
+	unsigned int flags;
 	int result;
 	int psz, sz;
 	int i;
@@ -214,8 +216,10 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 	spin_lock_init(&r0->lo_sub_lock);
 	r0->lo_nr = lse->lsme_stripe_count;
 
-	r0->lo_sub = kcalloc(r0->lo_nr, sizeof(r0->lo_sub[0]),
-			     GFP_KERNEL);
+	flags = memalloc_nofs_save();
+	r0->lo_sub = kvmalloc_array(r0->lo_nr, sizeof(r0->lo_sub[0]),
+				    GFP_KERNEL | __GFP_ZERO);
+	memalloc_nofs_restore(flags);
 	if (!r0->lo_sub)
 		return -ENOMEM;
 
@@ -335,10 +339,7 @@ static void lov_fini_raid0(const struct lu_env *env,
 {
 	struct lov_layout_raid0 *r0 = &lle->lle_raid0;
 
-	if (r0->lo_sub) {
-		kvfree(r0->lo_sub);
-		r0->lo_sub = NULL;
-	}
+	kvfree(r0->lo_sub);
 }
 
 static int lov_print_raid0(const struct lu_env *env, void *cookie,
diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index a52e0362..3bee0c2 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -34,6 +34,7 @@
 #define DEBUG_SUBSYSTEM S_ECHO
 
 #include <linux/highmem.h>
+#include <linux/sched/mm.h>
 #include <obd.h>
 #include <obd_support.h>
 #include <obd_class.h>
@@ -1369,6 +1370,7 @@ static int echo_client_prep_commit(const struct lu_env *env,
 	struct niobuf_remote rnb;
 	u64 off;
 	u64 npages, tot_pages;
+	unsigned int flags;
 	int i, ret = 0, brw_flags = 0;
 
 	if (count <= 0 || (count & (~PAGE_MASK)) != 0)
@@ -1377,8 +1379,11 @@ static int echo_client_prep_commit(const struct lu_env *env,
 	npages = batch >> PAGE_SHIFT;
 	tot_pages = count >> PAGE_SHIFT;
 
+	flags = memalloc_nofs_save();
 	lnb = kvmalloc_array(npages, sizeof(*lnb),
-			     GFP_NOFS | __GFP_ZERO);
+			     GFP_KERNEL | __GFP_ZERO);
+	memalloc_nofs_restore(flags);
+
 	if (!lnb) {
 		ret = -ENOMEM;
 		goto out;
-- 
1.8.3.1
