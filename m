From: NeilBrown <neilb@suse.com>
Date: Wed, 04 Jul 2018 14:43:50 +1000
Subject: [lustre-devel] [PATCH 11/11] lustre: avoid alloc(sizeof(struct ...))
In-Reply-To: <153067941050.30111.13691201276059352926.stgit@noble>
References: <153067941050.30111.13691201276059352926.stgit@noble>
Message-ID: <153067943093.30111.13601987501540697866.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

checkpatch suggests that

 struct foo *bar;

 bar = kmalloc(sizeof(struct foo), GFP_XX);

is better written as

 bar = kmalloc(sizeof(*bar), GFP_XX);

and this does seem more robust.  So make this
change throughput lustre.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/nidstrings.c    |    4 ++--
 drivers/staging/lustre/lnet/selftest/console.c   |    8 ++++----
 drivers/staging/lustre/lnet/selftest/framework.c |    8 ++++----
 drivers/staging/lustre/lustre/llite/file.c       |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c    |    2 +-
 5 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 0f6c3fa16c65..43d957f9022a 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -169,7 +169,7 @@ parse_addrange(const struct cfs_lstr *src, struct nidrange *nidrange)
 		return 0;
 	}
 
-	addrrange = kzalloc(sizeof(struct addrrange), GFP_NOFS);
+	addrrange = kzalloc(sizeof(*addrrange), GFP_NOFS);
 	if (!addrrange)
 		return -ENOMEM;
 	list_add_tail(&addrrange->ar_link, &nidrange->nr_addrranges);
@@ -228,7 +228,7 @@ add_nidrange(const struct cfs_lstr *src,
 		return nr;
 	}
 
-	nr = kzalloc(sizeof(struct nidrange), GFP_NOFS);
+	nr = kzalloc(sizeof(*nr), GFP_NOFS);
 	if (!nr)
 		return NULL;
 	list_add_tail(&nr->nr_link, nidlist);
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 3c1c1b5997e0..d5806f22ee94 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -165,7 +165,7 @@ lstcon_ndlink_find(struct list_head *hash, struct lnet_process_id id,
 	if (rc)
 		return rc;
 
-	ndl = kzalloc(sizeof(struct lstcon_ndlink), GFP_NOFS);
+	ndl = kzalloc(sizeof(*ndl), GFP_NOFS);
 	if (!ndl) {
 		lstcon_node_put(nd);
 		return -ENOMEM;
@@ -805,7 +805,7 @@ lstcon_group_info(char *name, struct lstcon_ndlist_ent __user *gents_p,
 	}
 
 	/* non-verbose query */
-	gentp = kzalloc(sizeof(struct lstcon_ndlist_ent), GFP_NOFS);
+	gentp = kzalloc(sizeof(*gentp), GFP_NOFS);
 	if (!gentp) {
 		CERROR("Can't allocate ndlist_ent\n");
 		lstcon_group_decref(grp);
@@ -854,7 +854,7 @@ lstcon_batch_add(char *name)
 		return rc;
 	}
 
-	bat = kzalloc(sizeof(struct lstcon_batch), GFP_NOFS);
+	bat = kzalloc(sizeof(*bat), GFP_NOFS);
 	if (!bat) {
 		CERROR("Can't allocate descriptor for batch %s\n", name);
 		return -ENOMEM;
@@ -969,7 +969,7 @@ lstcon_batch_info(char *name, struct lstcon_test_batch_ent __user *ent_up,
 	}
 
 	/* non-verbose query */
-	entp = kzalloc(sizeof(struct lstcon_test_batch_ent), GFP_NOFS);
+	entp = kzalloc(sizeof(*entp), GFP_NOFS);
 	if (!entp)
 		return -ENOMEM;
 
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 741af10560ad..361571aa94ce 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -143,7 +143,7 @@ sfw_register_test(struct srpc_service *service,
 		return -EEXIST;
 	}
 
-	tsc = kzalloc(sizeof(struct sfw_test_case), GFP_NOFS);
+	tsc = kzalloc(sizeof(*tsc), GFP_NOFS);
 	if (!tsc)
 		return -ENOMEM;
 
@@ -344,7 +344,7 @@ sfw_bid2batch(struct lst_bid bid)
 	if (bat)
 		return bat;
 
-	bat = kzalloc(sizeof(struct sfw_batch), GFP_NOFS);
+	bat = kzalloc(sizeof(*bat), GFP_NOFS);
 	if (!bat)
 		return NULL;
 
@@ -447,7 +447,7 @@ sfw_make_session(struct srpc_mksn_reqst *request, struct srpc_mksn_reply *reply)
 	}
 
 	/* brand new or create by force */
-	sn = kzalloc(sizeof(struct sfw_session), GFP_NOFS);
+	sn = kzalloc(sizeof(*sn), GFP_NOFS);
 	if (!sn) {
 		CERROR("dropping RPC mksn under memory pressure\n");
 		return -ENOMEM;
@@ -795,7 +795,7 @@ sfw_add_test_instance(struct sfw_batch *tsb, struct srpc_server_rpc *rpc)
 			sfw_unpack_id(id);
 
 		for (j = 0; j < tsi->tsi_concur; j++) {
-			tsu = kzalloc(sizeof(struct sfw_test_unit), GFP_NOFS);
+			tsu = kzalloc(sizeof(*tsu), GFP_NOFS);
 			if (!tsu) {
 				rc = -ENOMEM;
 				CERROR("Can't allocate tsu for %d\n",
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 54da6f19da21..3f0f379ce050 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -615,7 +615,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 
 			goto restart;
 		}
-		*och_p = kzalloc(sizeof(struct obd_client_handle), GFP_KERNEL);
+		*och_p = kzalloc(sizeof(**och_p), GFP_KERNEL);
 		if (!*och_p) {
 			rc = -ENOMEM;
 			goto out_och_free;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index fee4e498b143..7a3d83c0e50b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -576,7 +576,7 @@ ptlrpc_init_rq_pool(int num_rq, int msgsize,
 {
 	struct ptlrpc_request_pool *pool;
 
-	pool = kzalloc(sizeof(struct ptlrpc_request_pool), GFP_NOFS);
+	pool = kzalloc(sizeof(*pool), GFP_NOFS);
 	if (!pool)
 		return NULL;
 
