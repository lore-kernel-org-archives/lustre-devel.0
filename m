From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 Nov 2016 14:35:50 -0500
Subject: [lustre-devel] [PATCH 12/19] staging: lustre: libcfs: remove == 0
	testing
In-Reply-To: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
References: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479411357-28979-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Testing == 0 is not kernel style so remove this
type of testing from libcfs.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/debug.c         |    8 +++---
 drivers/staging/lustre/lnet/libcfs/hash.c          |   27 +++++++++----------
 drivers/staging/lustre/lnet/libcfs/libcfs_lock.c   |    4 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |   16 ++++++------
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |   12 ++++----
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |    4 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |   14 +++++-----
 drivers/staging/lustre/lnet/libcfs/workitem.c      |    2 +-
 8 files changed, 43 insertions(+), 44 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index 57cdc76..67f043e 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -259,13 +259,13 @@ static int param_set_uintpos(const char *val, const struct kernel_param *kp)
 	const char   *token;
 	int	   i;
 
-	if (mask == 0) {			/* "0" */
+	if (!mask) {			/* "0" */
 		if (size > 0)
 			str[0] = '0';
 		len = 1;
 	} else {				/* space-separated tokens */
 		for (i = 0; i < 32; i++) {
-			if ((mask & (1 << i)) == 0)
+			if (!(mask & (1 << i)))
 				continue;
 
 			token = fn(i);
@@ -416,9 +416,9 @@ int libcfs_debug_init(unsigned long bufsize)
 		max = max / num_possible_cpus();
 		max <<= (20 - PAGE_SHIFT);
 	}
-	rc = cfs_tracefile_init(max);
 
-	if (rc == 0) {
+	rc = cfs_tracefile_init(max);
+	if (!rc) {
 		libcfs_register_panic_notifier();
 		libcfs_debug_mb = cfs_trace_get_debug_mb();
 	}
diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index 1b67536..22e1e25 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -507,7 +507,7 @@ struct cfs_hash_dhead_dep {
 
 	bd->bd_bucket->hsb_depmax = dep_cur;
 # if CFS_HASH_DEBUG_LEVEL >= CFS_HASH_DEBUG_1
-	if (likely(warn_on_depth == 0 ||
+	if (likely(!warn_on_depth ||
 		   max(warn_on_depth, hs->hs_dep_max) >= dep_cur))
 		return;
 
@@ -531,7 +531,7 @@ struct cfs_hash_dhead_dep {
 	rc = hs->hs_hops->hop_hnode_add(hs, bd, hnode);
 	cfs_hash_bd_dep_record(hs, bd, rc);
 	bd->bd_bucket->hsb_version++;
-	if (unlikely(bd->bd_bucket->hsb_version == 0))
+	if (unlikely(!bd->bd_bucket->hsb_version))
 		bd->bd_bucket->hsb_version++;
 	bd->bd_bucket->hsb_count++;
 
@@ -551,7 +551,7 @@ struct cfs_hash_dhead_dep {
 	LASSERT(bd->bd_bucket->hsb_count > 0);
 	bd->bd_bucket->hsb_count--;
 	bd->bd_bucket->hsb_version++;
-	if (unlikely(bd->bd_bucket->hsb_version == 0))
+	if (unlikely(!bd->bd_bucket->hsb_version))
 		bd->bd_bucket->hsb_version++;
 
 	if (cfs_hash_with_counter(hs)) {
@@ -571,7 +571,7 @@ struct cfs_hash_dhead_dep {
 	struct cfs_hash_bucket *nbkt = bd_new->bd_bucket;
 	int rc;
 
-	if (cfs_hash_bd_compare(bd_old, bd_new) == 0)
+	if (!cfs_hash_bd_compare(bd_old, bd_new))
 		return;
 
 	/* use cfs_hash_bd_hnode_add/del, to avoid atomic & refcount ops
@@ -584,11 +584,11 @@ struct cfs_hash_dhead_dep {
 	LASSERT(obkt->hsb_count > 0);
 	obkt->hsb_count--;
 	obkt->hsb_version++;
-	if (unlikely(obkt->hsb_version == 0))
+	if (unlikely(!obkt->hsb_version))
 		obkt->hsb_version++;
 	nbkt->hsb_count++;
 	nbkt->hsb_version++;
-	if (unlikely(nbkt->hsb_version == 0))
+	if (unlikely(!nbkt->hsb_version))
 		nbkt->hsb_version++;
 }
 
@@ -883,7 +883,7 @@ struct hlist_node *
 	struct cfs_hash_bucket **new_bkts;
 	int i;
 
-	LASSERT(old_size == 0 || old_bkts);
+	LASSERT(!old_size || old_bkts);
 
 	if (old_bkts && old_size == new_size)
 		return old_bkts;
@@ -1016,12 +1016,11 @@ struct cfs_hash *
 	LASSERT(cur_bits > 0);
 	LASSERT(cur_bits >= bkt_bits);
 	LASSERT(max_bits >= cur_bits && max_bits < 31);
-	LASSERT(ergo((flags & CFS_HASH_REHASH) == 0, cur_bits == max_bits));
-	LASSERT(ergo(flags & CFS_HASH_REHASH,
-		     (flags & CFS_HASH_NO_LOCK) == 0));
+	LASSERT(ergo(!(flags & CFS_HASH_REHASH), cur_bits == max_bits));
+	LASSERT(ergo(flags & CFS_HASH_REHASH, !(flags & CFS_HASH_NO_LOCK)));
 	LASSERT(ergo(flags & CFS_HASH_REHASH_KEY, ops->hs_keycpy));
 
-	len = (flags & CFS_HASH_BIGNAME) == 0 ?
+	len = !(flags & CFS_HASH_BIGNAME) ?
 	      CFS_HASH_NAME_LEN : CFS_HASH_BIGNAME_LEN;
 	LIBCFS_ALLOC(hs, offsetof(struct cfs_hash, hs_name[len]));
 	if (!hs)
@@ -1107,12 +1106,12 @@ struct cfs_hash *
 				cfs_hash_exit(hs, hnode);
 			}
 		}
-		LASSERT(bd.bd_bucket->hsb_count == 0);
+		LASSERT(!bd.bd_bucket->hsb_count);
 		cfs_hash_bd_unlock(hs, &bd, 1);
 		cond_resched();
 	}
 
-	LASSERT(atomic_read(&hs->hs_count) == 0);
+	LASSERT(!atomic_read(&hs->hs_count));
 
 	cfs_hash_buckets_free(hs->hs_buckets, cfs_hash_bkt_size(hs),
 			      0, CFS_HASH_NBKT(hs));
@@ -1388,7 +1387,7 @@ void cfs_hash_putref(struct cfs_hash *hs)
 	bits = cfs_hash_rehash_bits(hs);
 	cfs_hash_unlock(hs, 1);
 	/* NB: it's race on cfs_has_t::hs_iterating, see above */
-	if (remained == 0)
+	if (!remained)
 		hs->hs_iterating = 0;
 	if (bits > 0) {
 		cfs_hash_rehash(hs, atomic_read(&hs->hs_count) <
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
index 1deea76..66f020b 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
@@ -114,7 +114,7 @@ struct cfs_percpt_lock *
 	/* exclusive lock request */
 	for (i = 0; i < ncpt; i++) {
 		spin_lock(pcl->pcl_locks[i]);
-		if (i == 0) {
+		if (!i) {
 			LASSERT(!pcl->pcl_locked);
 			/* nobody should take private lock after this
 			 * so I wouldn't starve for too long time
@@ -141,7 +141,7 @@ struct cfs_percpt_lock *
 	}
 
 	for (i = ncpt - 1; i >= 0; i--) {
-		if (i == 0) {
+		if (!i) {
 			LASSERT(pcl->pcl_locked);
 			pcl->pcl_locked = 0;
 		}
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
index 9c58f82..6f6f240 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
@@ -79,7 +79,7 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 		for (i = 0; i < 32; i++) {
 			debugstr = bit2str(i);
 			if (debugstr && strlen(debugstr) == len &&
-			    strncasecmp(str, debugstr, len) == 0) {
+			    !strncasecmp(str, debugstr, len)) {
 				if (op == '-')
 					newmask &= ~(1 << i);
 				else
@@ -89,7 +89,7 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 			}
 		}
 		if (!found && len == 3 &&
-		    (strncasecmp(str, "ALL", len) == 0)) {
+		    !strncasecmp(str, "ALL", len)) {
 			if (op == '-')
 				newmask = minmask;
 			else
@@ -182,7 +182,7 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 		next->ls_len--;
 	}
 
-	if (next->ls_len == 0) /* whitespaces only */
+	if (!next->ls_len) /* whitespaces only */
 		return 0;
 
 	if (*next->ls_str == delim) {
@@ -417,7 +417,7 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 
 	list_for_each_entry(expr, &expr_list->el_exprs, re_link) {
 		if (value >= expr->re_lo && value <= expr->re_hi &&
-		    ((value - expr->re_lo) % expr->re_stride) == 0)
+		    !((value - expr->re_lo) % expr->re_stride))
 			return 1;
 	}
 
@@ -442,12 +442,12 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 
 	list_for_each_entry(expr, &expr_list->el_exprs, re_link) {
 		for (i = expr->re_lo; i <= expr->re_hi; i++) {
-			if (((i - expr->re_lo) % expr->re_stride) == 0)
+			if (!((i - expr->re_lo) % expr->re_stride))
 				count++;
 		}
 	}
 
-	if (count == 0) /* empty expression list */
+	if (!count) /* empty expression list */
 		return 0;
 
 	if (count > max) {
@@ -463,7 +463,7 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 	count = 0;
 	list_for_each_entry(expr, &expr_list->el_exprs, re_link) {
 		for (i = expr->re_lo; i <= expr->re_hi; i++) {
-			if (((i - expr->re_lo) % expr->re_stride) == 0)
+			if (!((i - expr->re_lo) % expr->re_stride))
 				val[count++] = i;
 		}
 	}
@@ -540,7 +540,7 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 		}
 	} else {
 		rc = cfs_range_expr_parse(&src, min, max, 0, &expr);
-		if (rc == 0)
+		if (!rc)
 			list_add_tail(&expr->re_link, &expr_list->el_exprs);
 	}
 
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 44a8790..8c3fcdb 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -375,7 +375,7 @@ struct cfs_cpt_table *
 {
 	int	i;
 
-	if (cpumask_weight(mask) == 0 ||
+	if (!cpumask_weight(mask) ||
 	    cpumask_any_and(mask, cpu_online_mask) >= nr_cpu_ids) {
 		CDEBUG(D_INFO, "No online CPU is found in the CPU mask for CPU partition %d\n",
 		       cpt);
@@ -516,7 +516,7 @@ struct cfs_cpt_table *
 	rotor %= weight;
 
 	for_each_node_mask(node, *mask) {
-		if (rotor-- == 0)
+		if (!rotor--)
 			return node;
 	}
 
@@ -584,7 +584,7 @@ struct cfs_cpt_table *
 
 		rc = set_cpus_allowed_ptr(current, cpumask);
 		set_mems_allowed(*nodemask);
-		if (rc == 0)
+		if (!rc)
 			schedule(); /* switch to allowed CPU */
 
 		return rc;
@@ -658,7 +658,7 @@ struct cfs_cpt_table *
 					goto out;
 				}
 
-				if (--number == 0)
+				if (!--number)
 					goto out;
 			}
 			cpu = cpumask_first(socket);
@@ -750,7 +750,7 @@ struct cfs_cpt_table *
 	}
 
 	num = num_online_cpus() / ncpt;
-	if (num == 0) {
+	if (!num) {
 		CERROR("CPU changed while setting CPU partition\n");
 		goto failed;
 	}
@@ -848,7 +848,7 @@ struct cfs_cpt_table *
 		}
 	}
 
-	if (ncpt == 0 ||
+	if (!ncpt ||
 	    (node && ncpt > num_online_nodes()) ||
 	    (!node && ncpt > num_online_cpus())) {
 		CERROR("Invalid pattern %s, or too many partitions %d\n",
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index 3d85cc5..ac2e055 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -152,7 +152,7 @@ int cfs_crypto_hash_digest(enum cfs_crypto_hash_alg hash_alg,
 	int			err;
 	const struct cfs_crypto_hash_type	*type;
 
-	if (!buf || buf_len == 0 || !hash_len)
+	if (!buf || !buf_len || !hash_len)
 		return -EINVAL;
 
 	err = cfs_crypto_hash_alloc(hash_alg, &type, &req, key, key_len);
@@ -440,6 +440,6 @@ int cfs_crypto_register(void)
  */
 void cfs_crypto_unregister(void)
 {
-	if (adler32 == 0)
+	if (!adler32)
 		cfs_crypto_adler32_unregister();
 }
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 9f5eeb3..a15cedd 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -236,7 +236,7 @@ static void cfs_tcd_shrink(struct cfs_trace_cpu_data *tcd)
 	INIT_LIST_HEAD(&pc.pc_pages);
 
 	list_for_each_entry_safe(tage, tmp, &tcd->tcd_pages, linkage) {
-		if (pgcount-- == 0)
+		if (!pgcount--)
 			break;
 
 		list_move_tail(&tage->linkage, &pc.pc_pages);
@@ -320,7 +320,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 	if (!tcd)		/* arch may not log in IRQ context */
 		goto console;
 
-	if (tcd->tcd_cur_pages == 0)
+	if (!tcd->tcd_cur_pages)
 		header.ph_flags |= PH_FLAG_FIRST_RECORD;
 
 	if (tcd->tcd_shutting_down) {
@@ -423,7 +423,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 	__LASSERT(tage->used <= PAGE_SIZE);
 
 console:
-	if ((mask & libcfs_printk) == 0) {
+	if (!(mask & libcfs_printk)) {
 		/* no console output requested */
 		if (tcd)
 			cfs_trace_put_tcd(tcd);
@@ -871,13 +871,13 @@ int cfs_trace_daemon_command(char *str)
 
 	cfs_tracefile_write_lock();
 
-	if (strcmp(str, "stop") == 0) {
+	if (!strcmp(str, "stop")) {
 		cfs_tracefile_write_unlock();
 		cfs_trace_stop_thread();
 		cfs_tracefile_write_lock();
 		memset(cfs_tracefile, 0, sizeof(cfs_tracefile));
 
-	} else if (strncmp(str, "size=", 5) == 0) {
+	} else if (!strncmp(str, "size=", 5)) {
 		unsigned long tmp;
 
 		rc = kstrtoul(str + 5, 10, &tmp);
@@ -917,7 +917,7 @@ int cfs_trace_daemon_command_usrstr(void __user *usr_str, int usr_str_nob)
 
 	rc = cfs_trace_copyin_string(str, usr_str_nob + 1,
 				     usr_str, usr_str_nob);
-	if (rc == 0)
+	if (!rc)
 		rc = cfs_trace_daemon_command(str);
 
 	kfree(str);
@@ -1072,7 +1072,7 @@ static int tracefiled(void *arg)
 		__LASSERT(list_empty(&pc.pc_pages));
 end_loop:
 		if (atomic_read(&tctl->tctl_shutdown)) {
-			if (last_loop == 0) {
+			if (!last_loop) {
 				last_loop = 1;
 				continue;
 			} else {
diff --git a/drivers/staging/lustre/lnet/libcfs/workitem.c b/drivers/staging/lustre/lnet/libcfs/workitem.c
index b9eda17..f5f1e9e 100644
--- a/drivers/staging/lustre/lnet/libcfs/workitem.c
+++ b/drivers/staging/lustre/lnet/libcfs/workitem.c
@@ -325,7 +325,7 @@ static int cfs_wi_scheduler(void *arg)
 	list_del(&sched->ws_list);
 
 	spin_unlock(&cfs_wi_data.wi_glock);
-	LASSERT(sched->ws_nscheduled == 0);
+	LASSERT(!sched->ws_nscheduled);
 
 	LIBCFS_FREE(sched, sizeof(*sched));
 }
-- 
1.7.1
