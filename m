From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 11:46:30 +1100
Subject: [lustre-devel] [PATCH 10/15] staging: lustre: more conversions to
 GFP_KERNEL allocations.
In-Reply-To: <151355781721.6200.2136335532722530242.stgit@noble>
References: <151355781721.6200.2136335532722530242.stgit@noble>
Message-ID: <151355799056.6200.17314874815893234845.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

These are not called from filesystem context, so use
GFP_KERNEL, not LIBCFS_ALLOC().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/selftest/console.c     |   57 +++++++++-----------
 drivers/staging/lustre/lnet/selftest/framework.c   |    4 +
 drivers/staging/lustre/lnet/selftest/module.c      |    7 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |    4 +
 drivers/staging/lustre/lnet/selftest/selftest.h    |    2 -
 .../lustre/lustre/obdclass/lprocfs_status.c        |   14 ++---
 6 files changed, 40 insertions(+), 48 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index edf5e59a4351..1acd5cb324b1 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -88,7 +88,7 @@ lstcon_node_find(struct lnet_process_id id, struct lstcon_node **ndpp,
 	if (!create)
 		return -ENOENT;
 
-	LIBCFS_ALLOC(*ndpp, sizeof(**ndpp) + sizeof(*ndl));
+	*ndpp = kzalloc(sizeof(**ndpp) + sizeof(*ndl), GFP_KERNEL);
 	if (!*ndpp)
 		return -ENOMEM;
 
@@ -133,7 +133,7 @@ lstcon_node_put(struct lstcon_node *nd)
 	list_del(&ndl->ndl_link);
 	list_del(&ndl->ndl_hlink);
 
-	LIBCFS_FREE(nd, sizeof(*nd) + sizeof(*ndl));
+	kfree(nd);
 }
 
 static int
@@ -199,16 +199,16 @@ lstcon_group_alloc(char *name, struct lstcon_group **grpp)
 	struct lstcon_group *grp;
 	int i;
 
-	LIBCFS_ALLOC(grp, offsetof(struct lstcon_group,
-				   grp_ndl_hash[LST_NODE_HASHSIZE]));
+	grp = kmalloc(offsetof(struct lstcon_group,
+			       grp_ndl_hash[LST_NODE_HASHSIZE]),
+		      GFP_KERNEL);
 	if (!grp)
 		return -ENOMEM;
 
 	grp->grp_ref = 1;
 	if (name) {
 		if (strlen(name) > sizeof(grp->grp_name) - 1) {
-			LIBCFS_FREE(grp, offsetof(struct lstcon_group,
-				    grp_ndl_hash[LST_NODE_HASHSIZE]));
+			kfree(grp);
 			return -E2BIG;
 		}
 		strncpy(grp->grp_name, name, sizeof(grp->grp_name));
@@ -263,8 +263,7 @@ lstcon_group_decref(struct lstcon_group *grp)
 	for (i = 0; i < LST_NODE_HASHSIZE; i++)
 		LASSERT(list_empty(&grp->grp_ndl_hash[i]));
 
-	LIBCFS_FREE(grp, offsetof(struct lstcon_group,
-				  grp_ndl_hash[LST_NODE_HASHSIZE]));
+	kfree(grp);
 }
 
 static int
@@ -862,8 +861,8 @@ lstcon_batch_add(char *name)
 		return -ENOMEM;
 	}
 
-	LIBCFS_ALLOC(bat->bat_cli_hash,
-		     sizeof(struct list_head) * LST_NODE_HASHSIZE);
+	bat->bat_cli_hash = kmalloc(sizeof(struct list_head) * LST_NODE_HASHSIZE,
+				    GFP_KERNEL);
 	if (!bat->bat_cli_hash) {
 		CERROR("Can't allocate hash for batch %s\n", name);
 		kfree(bat);
@@ -871,19 +870,19 @@ lstcon_batch_add(char *name)
 		return -ENOMEM;
 	}
 
-	LIBCFS_ALLOC(bat->bat_srv_hash,
-		     sizeof(struct list_head) * LST_NODE_HASHSIZE);
+	bat->bat_srv_hash = kmalloc(sizeof(struct list_head) * LST_NODE_HASHSIZE,
+				    GFP_KERNEL);
 	if (!bat->bat_srv_hash) {
 		CERROR("Can't allocate hash for batch %s\n", name);
-		LIBCFS_FREE(bat->bat_cli_hash, LST_NODE_HASHSIZE);
+		kfree(bat->bat_cli_hash);
 		kfree(bat);
 
 		return -ENOMEM;
 	}
 
 	if (strlen(name) > sizeof(bat->bat_name) - 1) {
-		LIBCFS_FREE(bat->bat_srv_hash, LST_NODE_HASHSIZE);
-		LIBCFS_FREE(bat->bat_cli_hash, LST_NODE_HASHSIZE);
+		kfree(bat->bat_srv_hash);
+		kfree(bat->bat_cli_hash);
 		kfree(bat);
 		return -E2BIG;
 	}
@@ -1107,8 +1106,7 @@ lstcon_batch_destroy(struct lstcon_batch *bat)
 		lstcon_group_decref(test->tes_src_grp);
 		lstcon_group_decref(test->tes_dst_grp);
 
-		LIBCFS_FREE(test, offsetof(struct lstcon_test,
-					   tes_param[test->tes_paramlen]));
+		kfree(test);
 	}
 
 	LASSERT(list_empty(&bat->bat_trans_list));
@@ -1134,10 +1132,8 @@ lstcon_batch_destroy(struct lstcon_batch *bat)
 		LASSERT(list_empty(&bat->bat_srv_hash[i]));
 	}
 
-	LIBCFS_FREE(bat->bat_cli_hash,
-		    sizeof(struct list_head) * LST_NODE_HASHSIZE);
-	LIBCFS_FREE(bat->bat_srv_hash,
-		    sizeof(struct list_head) * LST_NODE_HASHSIZE);
+	kfree(bat->bat_cli_hash);
+	kfree(bat->bat_srv_hash);
 	kfree(bat);
 }
 
@@ -1311,7 +1307,8 @@ lstcon_test_add(char *batch_name, int type, int loop,
 	if (dst_grp->grp_userland)
 		*retp = 1;
 
-	LIBCFS_ALLOC(test, offsetof(struct lstcon_test, tes_param[paramlen]));
+	test = kzalloc(offsetof(struct lstcon_test, tes_param[paramlen]),
+		       GFP_KERNEL);
 	if (!test) {
 		CERROR("Can't allocate test descriptor\n");
 		rc = -ENOMEM;
@@ -1357,8 +1354,7 @@ lstcon_test_add(char *batch_name, int type, int loop,
 	/*  hold groups so nobody can change them */
 	return rc;
 out:
-	if (test)
-		LIBCFS_FREE(test, offsetof(struct lstcon_test, tes_param[paramlen]));
+	kfree(test);
 
 	if (dst_grp)
 		lstcon_group_decref(dst_grp);
@@ -2027,8 +2023,8 @@ lstcon_console_init(void)
 	INIT_LIST_HEAD(&console_session.ses_bat_list);
 	INIT_LIST_HEAD(&console_session.ses_trans_list);
 
-	LIBCFS_ALLOC(console_session.ses_ndl_hash,
-		     sizeof(struct list_head) * LST_GLOBAL_HASHSIZE);
+	console_session.ses_ndl_hash =
+		kmalloc(sizeof(struct list_head) * LST_GLOBAL_HASHSIZE, GFP_KERNEL);
 	if (!console_session.ses_ndl_hash)
 		return -ENOMEM;
 
@@ -2041,8 +2037,7 @@ lstcon_console_init(void)
 	rc = srpc_add_service(&lstcon_acceptor_service);
 	LASSERT(rc != -EBUSY);
 	if (rc) {
-		LIBCFS_FREE(console_session.ses_ndl_hash,
-			    sizeof(struct list_head) * LST_GLOBAL_HASHSIZE);
+		kfree(console_session.ses_ndl_hash);
 		return rc;
 	}
 
@@ -2064,8 +2059,7 @@ lstcon_console_init(void)
 	srpc_shutdown_service(&lstcon_acceptor_service);
 	srpc_remove_service(&lstcon_acceptor_service);
 
-	LIBCFS_FREE(console_session.ses_ndl_hash,
-		    sizeof(struct list_head) * LST_GLOBAL_HASHSIZE);
+	kfree(console_session.ses_ndl_hash);
 
 	srpc_wait_service_shutdown(&lstcon_acceptor_service);
 
@@ -2099,8 +2093,7 @@ lstcon_console_fini(void)
 	for (i = 0; i < LST_NODE_HASHSIZE; i++)
 		LASSERT(list_empty(&console_session.ses_ndl_hash[i]));
 
-	LIBCFS_FREE(console_session.ses_ndl_hash,
-		    sizeof(struct list_head) * LST_GLOBAL_HASHSIZE);
+	kfree(console_session.ses_ndl_hash);
 
 	srpc_wait_service_shutdown(&lstcon_acceptor_service);
 
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index b8d95a20b2eb..4592ece98d95 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -639,7 +639,7 @@ sfw_destroy_test_instance(struct sfw_test_instance *tsi)
 		rpc = list_entry(tsi->tsi_free_rpcs.next,
 				 struct srpc_client_rpc, crpc_list);
 		list_del(&rpc->crpc_list);
-		LIBCFS_FREE(rpc, srpc_client_rpc_size(rpc));
+		kfree(rpc);
 	}
 
 clean:
@@ -1767,7 +1767,7 @@ sfw_shutdown(void)
 				 struct srpc_client_rpc, crpc_list);
 		list_del(&rpc->crpc_list);
 
-		LIBCFS_FREE(rpc, srpc_client_rpc_size(rpc));
+		kfree(rpc);
 	}
 
 	for (i = 0; ; i++) {
diff --git a/drivers/staging/lustre/lnet/selftest/module.c b/drivers/staging/lustre/lnet/selftest/module.c
index 1d44d912f014..ba4b6145c953 100644
--- a/drivers/staging/lustre/lnet/selftest/module.c
+++ b/drivers/staging/lustre/lnet/selftest/module.c
@@ -72,9 +72,7 @@ lnet_selftest_exit(void)
 				continue;
 			cfs_wi_sched_destroy(lst_sched_test[i]);
 		}
-		LIBCFS_FREE(lst_sched_test,
-			    sizeof(lst_sched_test[0]) *
-			    cfs_cpt_number(lnet_cpt_table()));
+		kvfree(lst_sched_test);
 		lst_sched_test = NULL;
 		/* fall through */
 	case LST_INIT_WI_SERIAL:
@@ -103,7 +101,8 @@ lnet_selftest_init(void)
 	lst_init_step = LST_INIT_WI_SERIAL;
 
 	nscheds = cfs_cpt_number(lnet_cpt_table());
-	LIBCFS_ALLOC(lst_sched_test, sizeof(lst_sched_test[0]) * nscheds);
+	lst_sched_test = kvmalloc_array(nscheds, sizeof(lst_sched_test[0]),
+					GFP_KERNEL | __GFP_ZERO);
 	if (!lst_sched_test)
 		goto error;
 
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 7061f19f047f..e195b9ee544c 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -1322,8 +1322,8 @@ srpc_create_client_rpc(struct lnet_process_id peer, int service,
 {
 	struct srpc_client_rpc *rpc;
 
-	LIBCFS_ALLOC(rpc, offsetof(struct srpc_client_rpc,
-				   crpc_bulk.bk_iovs[nbulkiov]));
+	rpc = kzalloc(offsetof(struct srpc_client_rpc,
+			       crpc_bulk.bk_iovs[nbulkiov]), GFP_KERNEL);
 	if (!rpc)
 		return NULL;
 
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 8c10f0f149d5..b23a953d8efe 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -516,7 +516,7 @@ srpc_destroy_client_rpc(struct srpc_client_rpc *rpc)
 	LASSERT(!atomic_read(&rpc->crpc_refcount));
 
 	if (!rpc->crpc_fini)
-		LIBCFS_FREE(rpc, srpc_client_rpc_size(rpc));
+		kfree(rpc);
 	else
 		(*rpc->crpc_fini)(rpc);
 }
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 05d71f568837..85483a38c6c4 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1137,7 +1137,8 @@ struct lprocfs_stats *lprocfs_alloc_stats(unsigned int num,
 		num_entry = num_possible_cpus();
 
 	/* alloc percpu pointers for all possible cpu slots */
-	LIBCFS_ALLOC(stats, offsetof(typeof(*stats), ls_percpu[num_entry]));
+	stats = kvzalloc(offsetof(typeof(*stats), ls_percpu[num_entry]),
+			 GFP_KERNEL);
 	if (!stats)
 		return NULL;
 
@@ -1146,8 +1147,9 @@ struct lprocfs_stats *lprocfs_alloc_stats(unsigned int num,
 	spin_lock_init(&stats->ls_lock);
 
 	/* alloc num of counter headers */
-	LIBCFS_ALLOC(stats->ls_cnt_header,
-		     stats->ls_num * sizeof(struct lprocfs_counter_header));
+	stats->ls_cnt_header = kvmalloc_array(stats->ls_num,
+					      sizeof(struct lprocfs_counter_header),
+					      GFP_KERNEL | __GFP_ZERO);
 	if (!stats->ls_cnt_header)
 		goto fail;
 
@@ -1193,10 +1195,8 @@ void lprocfs_free_stats(struct lprocfs_stats **statsh)
 	for (i = 0; i < num_entry; i++)
 		if (stats->ls_percpu[i])
 			LIBCFS_FREE(stats->ls_percpu[i], percpusize);
-	if (stats->ls_cnt_header)
-		LIBCFS_FREE(stats->ls_cnt_header, stats->ls_num *
-					sizeof(struct lprocfs_counter_header));
-	LIBCFS_FREE(stats, offsetof(typeof(*stats), ls_percpu[num_entry]));
+	kvfree(stats->ls_cnt_header);
+	kvfree(stats);
 }
 EXPORT_SYMBOL(lprocfs_free_stats);
 
