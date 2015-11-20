From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:35:45 -0500
Subject: [lustre-devel] [PATCH 09/40] staging: lustre: Dynamic LNet
	Configuration (DLC)
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

This is the first patch of a set of patches that enables DLC.

This patch adds some cleanup in the config.c as well as some
preparatory changes in peer.c to enable dynamic network
configuration

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2456
Change-Id: I8c8bbf3b55acf4d76f22a8be587b553a70d31889
Reviewed-on: http://review.whamcloud.com/9830
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    2 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |    5 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    8 +-
 drivers/staging/lustre/lnet/lnet/config.c          |   29 ++++-
 drivers/staging/lustre/lnet/lnet/peer.c            |  134 ++++++++++++++------
 5 files changed, 124 insertions(+), 54 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 09c6bfe..1e0b236 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -685,7 +685,7 @@ int lnet_parse_networks(struct list_head *nilist, char *networks);
 int lnet_nid2peer_locked(lnet_peer_t **lpp, lnet_nid_t nid, int cpt);
 lnet_peer_t *lnet_find_peer_locked(struct lnet_peer_table *ptable,
 				   lnet_nid_t nid);
-void lnet_peer_tables_cleanup(void);
+void lnet_peer_tables_cleanup(lnet_ni_t *ni);
 void lnet_peer_tables_destroy(void);
 int lnet_peer_tables_create(void);
 void lnet_debug_peer(lnet_nid_t nid);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index d792c4a..39381d9 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -343,6 +343,8 @@ typedef struct lnet_peer {
 struct lnet_peer_table {
 	int			 pt_version;	/* /proc validity stamp */
 	int			 pt_number;	/* # peers extant */
+	/* # zombies to go to deathrow (and not there yet) */
+	int			 pt_zombies;
 	struct list_head	 pt_deathrow;	/* zombie peers */
 	struct list_head	*pt_hash;	/* NID->peer hash */
 };
@@ -600,9 +602,6 @@ typedef struct {
 	/* registered LNDs */
 	struct list_head		  ln_lnds;
 
-	/* space for network names */
-	char				 *ln_network_tokens;
-	int				  ln_network_tokens_nob;
 	/* test protocol compatibility flags */
 	int				  ln_testprotocompat;
 
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 284150f..f3c9937 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -882,7 +882,7 @@ lnet_shutdown_lndnis(void)
 
 	/* Clear the peer table and wait for all peers to go (they hold refs on
 	 * their NIs) */
-	lnet_peer_tables_cleanup();
+	lnet_peer_tables_cleanup(NULL);
 
 	lnet_net_lock(LNET_LOCK_EX);
 	/* Now wait for the NI's I just nuked to show up on ln_zombie_nis
@@ -939,12 +939,6 @@ lnet_shutdown_lndnis(void)
 
 	the_lnet.ln_shutdown = 0;
 	lnet_net_unlock(LNET_LOCK_EX);
-
-	if (the_lnet.ln_network_tokens != NULL) {
-		LIBCFS_FREE(the_lnet.ln_network_tokens,
-			    the_lnet.ln_network_tokens_nob);
-		the_lnet.ln_network_tokens = NULL;
-	}
 }
 
 static int
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 867c96e..7bb140b 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -96,6 +96,8 @@ lnet_net_unique(__u32 net, struct list_head *nilist)
 void
 lnet_ni_free(struct lnet_ni *ni)
 {
+	int i;
+
 	if (ni->ni_refs != NULL)
 		cfs_percpt_free(ni->ni_refs);
 
@@ -105,6 +107,10 @@ lnet_ni_free(struct lnet_ni *ni)
 	if (ni->ni_cpts != NULL)
 		cfs_expr_list_values_free(ni->ni_cpts, ni->ni_ncpts);
 
+	for (i = 0; i < LNET_MAX_INTERFACES && ni->ni_interfaces[i]; i++) {
+		LIBCFS_FREE(ni->ni_interfaces[i],
+			    strlen(ni->ni_interfaces[i]) + 1);
+	}
 	LIBCFS_FREE(ni, sizeof(*ni));
 }
 
@@ -199,8 +205,6 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 		return -ENOMEM;
 	}
 
-	the_lnet.ln_network_tokens = tokens;
-	the_lnet.ln_network_tokens_nob = tokensize;
 	memcpy(tokens, networks, tokensize);
 	str = tmp = tokens;
 
@@ -319,7 +323,23 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 				goto failed;
 			}
 
-			ni->ni_interfaces[niface++] = iface;
+			/*
+			 * Allocate a separate piece of memory and copy
+			 * into it the string, so we don't have
+			 * a depencency on the tokens string.  This way we
+			 * can free the tokens at the end of the function.
+			 * The newly allocated ni_interfaces[] can be
+			 * freed when freeing the NI
+			 */
+			LIBCFS_ALLOC(ni->ni_interfaces[niface],
+				     strlen(iface) + 1);
+			if (!ni->ni_interfaces[niface]) {
+				CERROR("Can't allocate net interface name\n");
+				goto failed;
+			}
+			strncpy(ni->ni_interfaces[niface], iface,
+				strlen(iface));
+			niface++;
 			iface = comma;
 		} while (iface != NULL);
 
@@ -344,6 +364,8 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 	}
 
 	LASSERT(!list_empty(nilist));
+
+	LIBCFS_FREE(tokens, tokensize);
 	return 0;
 
  failed_syntax:
@@ -360,7 +382,6 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 		cfs_expr_list_free(el);
 
 	LIBCFS_FREE(tokens, tokensize);
-	the_lnet.ln_network_tokens = NULL;
 
 	return -EINVAL;
 }
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 1fceed3..bb5a0bb 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -103,62 +103,116 @@ lnet_peer_tables_destroy(void)
 	the_lnet.ln_peer_tables = NULL;
 }
 
+static void
+lnet_peer_table_cleanup_locked(lnet_ni_t *ni, struct lnet_peer_table *ptable)
+{
+	int i;
+	lnet_peer_t *lp;
+	lnet_peer_t *tmp;
+
+	for (i = 0; i < LNET_PEER_HASH_SIZE; i++) {
+		list_for_each_entry_safe(lp, tmp, &ptable->pt_hash[i],
+					 lp_hashlist) {
+			if (ni && ni != lp->lp_ni)
+				continue;
+			list_del_init(&lp->lp_hashlist);
+			/* Lose hash table's ref */
+			ptable->pt_zombies++;
+			lnet_peer_decref_locked(lp);
+		}
+	}
+}
+
+static void
+lnet_peer_table_deathrow_wait_locked(struct lnet_peer_table *ptable,
+				     int cpt_locked)
+{
+	int i;
+
+	for (i = 3; ptable->pt_zombies != 0; i++) {
+		lnet_net_unlock(cpt_locked);
+
+		if (IS_PO2(i)) {
+			CDEBUG(D_WARNING,
+			       "Waiting for %d zombies on peer table\n",
+			       ptable->pt_zombies);
+		}
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		schedule_timeout(cfs_time_seconds(1) >> 1);
+		lnet_net_lock(cpt_locked);
+	}
+}
+
+static void
+lnet_peer_table_del_rtrs_locked(lnet_ni_t *ni, struct lnet_peer_table *ptable,
+				int cpt_locked)
+{
+	lnet_peer_t *lp;
+	lnet_peer_t *tmp;
+	lnet_nid_t lp_nid;
+	int i;
+
+	for (i = 0; i < LNET_PEER_HASH_SIZE; i++) {
+		list_for_each_entry_safe(lp, tmp, &ptable->pt_hash[i],
+					 lp_hashlist) {
+			if (ni != lp->lp_ni)
+				continue;
+
+			if (lp->lp_rtr_refcount == 0)
+				continue;
+
+			lp_nid = lp->lp_nid;
+
+			lnet_net_unlock(cpt_locked);
+			lnet_del_route(LNET_NIDNET(LNET_NID_ANY), lp_nid);
+			lnet_net_lock(cpt_locked);
+		}
+	}
+}
+
 void
-lnet_peer_tables_cleanup(void)
+lnet_peer_tables_cleanup(lnet_ni_t *ni)
 {
 	struct lnet_peer_table *ptable;
+	struct list_head deathrow;
+	lnet_peer_t *lp;
 	int i;
-	int j;
 
-	LASSERT(the_lnet.ln_shutdown);	/* i.e. no new peers */
+	INIT_LIST_HEAD(&deathrow);
 
+	LASSERT(the_lnet.ln_shutdown || ni);
+	/*
+	 * If just deleting the peers for a NI, get rid of any routes these
+	 * peers are gateways for.
+	 */
 	cfs_percpt_for_each(ptable, i, the_lnet.ln_peer_tables) {
 		lnet_net_lock(i);
-
-		for (j = 0; j < LNET_PEER_HASH_SIZE; j++) {
-			struct list_head *peers = &ptable->pt_hash[j];
-
-			while (!list_empty(peers)) {
-				lnet_peer_t *lp = list_entry(peers->next,
-								 lnet_peer_t,
-								 lp_hashlist);
-				list_del_init(&lp->lp_hashlist);
-				/* lose hash table's ref */
-				lnet_peer_decref_locked(lp);
-			}
-		}
-
+		lnet_peer_table_del_rtrs_locked(ni, ptable, i);
 		lnet_net_unlock(i);
 	}
 
+	/*
+	 * Start the process of moving the applicable peers to
+	 * deathrow.
+	 */
 	cfs_percpt_for_each(ptable, i, the_lnet.ln_peer_tables) {
-		LIST_HEAD(deathrow);
-		lnet_peer_t *lp;
-
 		lnet_net_lock(i);
+		lnet_peer_table_cleanup_locked(ni, ptable);
+		lnet_net_unlock(i);
+	}
 
-		for (j = 3; ptable->pt_number != 0; j++) {
-			lnet_net_unlock(i);
-
-			if ((j & (j - 1)) == 0) {
-				CDEBUG(D_WARNING,
-				       "Waiting for %d peers on peer table\n",
-				       ptable->pt_number);
-			}
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			schedule_timeout(cfs_time_seconds(1) / 2);
-			lnet_net_lock(i);
-		}
+	/* Cleanup all entries on deathrow. */
+	cfs_percpt_for_each(ptable, i, the_lnet.ln_peer_tables) {
+		lnet_net_lock(i);
+		lnet_peer_table_deathrow_wait_locked(ptable, i);
 		list_splice_init(&ptable->pt_deathrow, &deathrow);
-
 		lnet_net_unlock(i);
+	}
 
-		while (!list_empty(&deathrow)) {
-			lp = list_entry(deathrow.next,
-					    lnet_peer_t, lp_hashlist);
-			list_del(&lp->lp_hashlist);
-			LIBCFS_FREE(lp, sizeof(*lp));
-		}
+	while (!list_empty(&deathrow)) {
+		lp = list_entry(deathrow.next, lnet_peer_t, lp_hashlist);
+		list_del(&lp->lp_hashlist);
+		LIBCFS_FREE(lp, sizeof(*lp));
 	}
 }
 
@@ -181,6 +235,8 @@ lnet_destroy_peer_locked(lnet_peer_t *lp)
 	lp->lp_ni = NULL;
 
 	list_add(&lp->lp_hashlist, &ptable->pt_deathrow);
+	LASSERT(ptable->pt_zombies > 0);
+	ptable->pt_zombies--;
 }
 
 lnet_peer_t *
-- 
1.7.1
