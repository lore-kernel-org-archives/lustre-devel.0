From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 11:46:30 +1100
Subject: [lustre-devel] [PATCH 02/15] staging: lustre: lnet: discard
 CFS_ALLOC_PTR
In-Reply-To: <151355781721.6200.2136335532722530242.stgit@noble>
References: <151355781721.6200.2136335532722530242.stgit@noble>
Message-ID: <151355799026.6200.16032725626950825179.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

These trivial wrappers hurt readability and
as they use kvmalloc, they are overly generic.

So discard them and use kmalloc/kfree as is
normal in Linux.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_private.h   |    3 ---
 drivers/staging/lustre/lnet/lnet/net_fault.c       |   10 +++++-----
 2 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index 940200ee632e..d230c7f7cced 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -215,9 +215,6 @@ do {							    \
 #define LASSERT_ATOMIC_ZERO(a)		  LASSERT_ATOMIC_EQ(a, 0)
 #define LASSERT_ATOMIC_POS(a)		   LASSERT_ATOMIC_GT(a, 0)
 
-#define CFS_ALLOC_PTR(ptr)      LIBCFS_ALLOC(ptr, sizeof(*(ptr)))
-#define CFS_FREE_PTR(ptr)       LIBCFS_FREE(ptr, sizeof(*(ptr)))
-
 /* implication */
 #define ergo(a, b) (!(a) || (b))
 /* logical equivalence */
diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
index 5a5d1811ffbe..0318e64c413f 100644
--- a/drivers/staging/lustre/lnet/lnet/net_fault.c
+++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
@@ -161,7 +161,7 @@ lnet_drop_rule_add(struct lnet_fault_attr *attr)
 	if (lnet_fault_attr_validate(attr))
 		return -EINVAL;
 
-	CFS_ALLOC_PTR(rule);
+	rule = kzalloc(sizeof(*rule), GFP_NOFS);
 	if (!rule)
 		return -ENOMEM;
 
@@ -223,7 +223,7 @@ lnet_drop_rule_del(lnet_nid_t src, lnet_nid_t dst)
 		       rule->dr_attr.u.drop.da_interval);
 
 		list_del(&rule->dr_link);
-		CFS_FREE_PTR(rule);
+		kfree(rule);
 		n++;
 	}
 
@@ -452,7 +452,7 @@ delay_rule_decref(struct lnet_delay_rule *rule)
 		LASSERT(list_empty(&rule->dl_msg_list));
 		LASSERT(list_empty(&rule->dl_link));
 
-		CFS_FREE_PTR(rule);
+		kfree(rule);
 	}
 }
 
@@ -738,7 +738,7 @@ lnet_delay_rule_add(struct lnet_fault_attr *attr)
 	if (lnet_fault_attr_validate(attr))
 		return -EINVAL;
 
-	CFS_ALLOC_PTR(rule);
+	rule = kzalloc(sizeof(*rule), GFP_NOFS);
 	if (!rule)
 		return -ENOMEM;
 
@@ -792,7 +792,7 @@ lnet_delay_rule_add(struct lnet_fault_attr *attr)
 	return 0;
 failed:
 	mutex_unlock(&delay_dd.dd_mutex);
-	CFS_FREE_PTR(rule);
+	kfree(rule);
 	return rc;
 }
 
