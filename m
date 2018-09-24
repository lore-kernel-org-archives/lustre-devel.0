From: NeilBrown <neilb@suse.com>
Date: Mon, 24 Sep 2018 16:03:18 +1000
Subject: [lustre-devel] [PATCH 20/34] lnet: discard ni_cpt_list
In-Reply-To: <CAAqp6i3CZTW_YbqeLc6p955AbKgbZbxNw2LCmA53-LoJ0JXDKg@mail.gmail.com>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137203.8267.14277020278461943610.stgit@noble>
 <C21D7B70-F41C-473E-8FD3-956078896EAE@cray.com>
 <874levqn9z.fsf@notabene.neil.brown.name>
 <CAAqp6i3CZTW_YbqeLc6p955AbKgbZbxNw2LCmA53-LoJ0JXDKg@mail.gmail.com>
Message-ID: <87lg7r4el5.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Sep 13 2018, Amir Shehata wrote:

> did you read my response to that question? Pasted below:
>
> ---
> This area was re-implemented. There is no need for ni_cptlist any longer. I
> looked at the current code and it's not being used.
> Originally it was being used to place the the ni on a global list:
> ln_nis_cpt. Which was traversed when attempting to calculate the cpt for a
> NID using lnet_cpt_of_nid_locked(). However that latter function has been
> re-implemented due to how MR works now. So there is not need for ni_cptlist.
> ___

Thanks.  I've queued this patch.

NeilBrown

From: NeilBrown <neilb@suse.com>
Date: Mon, 24 Sep 2018 15:57:13 +1000
Subject: [PATCH] lustre: remove ni_cptlist field.

This is never used in a meaningful way.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/include/linux/lnet/lib-types.h | 2 --
 drivers/staging/lustre/lnet/lnet/api-ni.c             | 5 -----
 drivers/staging/lustre/lnet/lnet/config.c             | 1 -
 3 files changed, 8 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 89158b52dc1b..1423aea83747 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -309,8 +309,6 @@ struct lnet_ni {
 	spinlock_t		ni_lock;
 	/* chain on the lnet_net structure */
 	struct list_head	ni_netlist;
-	/* chain on net_ni_cpt */
-	struct list_head	ni_cptlist;
 
 	/* number of CPTs */
 	int			ni_ncpts;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 69ea18ce2dcc..20fa3fea04b9 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1115,11 +1115,6 @@ lnet_ni_tq_credits(struct lnet_ni *ni)
 static void
 lnet_ni_unlink_locked(struct lnet_ni *ni)
 {
-	if (!list_empty(&ni->ni_cptlist)) {
-		list_del_init(&ni->ni_cptlist);
-		lnet_ni_decref_locked(ni, 0);
-	}
-
 	/* move it to zombie list and nobody can find it anymore */
 	LASSERT(!list_empty(&ni->ni_netlist));
 	list_move(&ni->ni_netlist, &ni->ni_net->net_ni_zombie);
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 92694b51f223..9539ce07ae05 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -438,7 +438,6 @@ lnet_ni_alloc(struct lnet_net *net, struct cfs_expr_list *el, char *iface)
 	}
 
 	spin_lock_init(&ni->ni_lock);
-	INIT_LIST_HEAD(&ni->ni_cptlist);
 	INIT_LIST_HEAD(&ni->ni_netlist);
 	ni->ni_refs = cfs_percpt_alloc(lnet_cpt_table(),
 				       sizeof(*ni->ni_refs[0]));
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180924/834df8e9/attachment.sig>
