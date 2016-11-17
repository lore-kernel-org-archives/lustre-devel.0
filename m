From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 Nov 2016 14:35:49 -0500
Subject: [lustre-devel] [PATCH 11/19] staging: lustre: libcfs: remove != 0
	testing
In-Reply-To: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
References: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479411357-28979-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Testing != 0 is not kernel style so remove this
type of testing from libcfs.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/debug.c         |    4 +-
 drivers/staging/lustre/lnet/libcfs/hash.c          |   24 ++++++++++----------
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |    6 ++--
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |   14 +++++-----
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |    6 ++--
 .../lustre/lnet/libcfs/linux/linux-tracefile.c     |   10 ++++----
 drivers/staging/lustre/lnet/libcfs/module.c        |    4 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |   14 +++++-----
 drivers/staging/lustre/lnet/libcfs/workitem.c      |    6 ++--
 9 files changed, 44 insertions(+), 44 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index f95764c..57cdc76 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -278,7 +278,7 @@ static int param_set_uintpos(const char *val, const struct kernel_param *kp)
 				len++;
 			}
 
-			while (*token != 0) {
+			while (*token) {
 				if (len < size)
 					str[len] = *token;
 				token++;
@@ -315,7 +315,7 @@ static int param_set_uintpos(const char *val, const struct kernel_param *kp)
 	t = sscanf(str, "%i%n", &m, &matched);
 	if (t >= 1 && matched == n) {
 		/* don't print warning for lctl set_param debug=0 or -1 */
-		if (m != 0 && m != -1)
+		if (m && m != -1)
 			CWARN("You are trying to use a numerical value for the mask - this will be deprecated in a future release.\n");
 		*mask = m;
 		return 0;
diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index 530def6..1b67536 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -492,7 +492,7 @@ struct cfs_hash_dhead_dep {
 		cfs_hash_bd_from_key(hs, hs->hs_buckets,
 				     hs->hs_cur_bits, key, bd);
 	} else {
-		LASSERT(hs->hs_rehash_bits != 0);
+		LASSERT(hs->hs_rehash_bits);
 		cfs_hash_bd_from_key(hs, hs->hs_rehash_buckets,
 				     hs->hs_rehash_bits, key, bd);
 	}
@@ -629,7 +629,7 @@ enum cfs_hash_lookup_intent {
 	struct hlist_head *hhead = cfs_hash_bd_hhead(hs, bd);
 	struct hlist_node *ehnode;
 	struct hlist_node *match;
-	int intent_add = (intent & CFS_HS_LOOKUP_MASK_ADD) != 0;
+	int intent_add = intent & CFS_HS_LOOKUP_MASK_ADD;
 
 	/* with this function, we can avoid a lot of useless refcount ops,
 	 * which are expensive atomic operations most time.
@@ -643,13 +643,13 @@ enum cfs_hash_lookup_intent {
 			continue;
 
 		/* match and ... */
-		if ((intent & CFS_HS_LOOKUP_MASK_DEL) != 0) {
+		if (intent & CFS_HS_LOOKUP_MASK_DEL) {
 			cfs_hash_bd_del_locked(hs, bd, ehnode);
 			return ehnode;
 		}
 
 		/* caller wants refcount? */
-		if ((intent & CFS_HS_LOOKUP_MASK_REF) != 0)
+		if (intent & CFS_HS_LOOKUP_MASK_REF)
 			cfs_hash_get(hs, ehnode);
 		return ehnode;
 	}
@@ -815,7 +815,7 @@ struct hlist_node *
 		return;
 	}
 
-	LASSERT(hs->hs_rehash_bits != 0);
+	LASSERT(hs->hs_rehash_bits);
 	cfs_hash_bd_from_key(hs, hs->hs_rehash_buckets,
 			     hs->hs_rehash_bits, key, &bds[1]);
 
@@ -976,7 +976,7 @@ static void cfs_hash_depth_wi_cancel(struct cfs_hash *hs)
 		return;
 
 	spin_lock(&hs->hs_dep_lock);
-	while (hs->hs_dep_bits != 0) {
+	while (hs->hs_dep_bits) {
 		spin_unlock(&hs->hs_dep_lock);
 		cond_resched();
 		spin_lock(&hs->hs_dep_lock);
@@ -1010,16 +1010,16 @@ struct cfs_hash *
 	LASSERT(ops->hs_get);
 	LASSERT(ops->hs_put_locked);
 
-	if ((flags & CFS_HASH_REHASH) != 0)
+	if (flags & CFS_HASH_REHASH)
 		flags |= CFS_HASH_COUNTER; /* must have counter */
 
 	LASSERT(cur_bits > 0);
 	LASSERT(cur_bits >= bkt_bits);
 	LASSERT(max_bits >= cur_bits && max_bits < 31);
 	LASSERT(ergo((flags & CFS_HASH_REHASH) == 0, cur_bits == max_bits));
-	LASSERT(ergo((flags & CFS_HASH_REHASH) != 0,
+	LASSERT(ergo(flags & CFS_HASH_REHASH,
 		     (flags & CFS_HASH_NO_LOCK) == 0));
-	LASSERT(ergo((flags & CFS_HASH_REHASH_KEY) != 0, ops->hs_keycpy));
+	LASSERT(ergo(flags & CFS_HASH_REHASH_KEY, ops->hs_keycpy));
 
 	len = (flags & CFS_HASH_BIGNAME) == 0 ?
 	      CFS_HASH_NAME_LEN : CFS_HASH_BIGNAME_LEN;
@@ -1948,7 +1948,7 @@ struct cfs_hash_cond_arg {
 	/* can't refer to @hs anymore because it could be destroyed */
 	if (bkts)
 		cfs_hash_buckets_free(bkts, bsize, new_size, old_size);
-	if (rc != 0)
+	if (rc)
 		CDEBUG(D_INFO, "early quit of rehashing: %d\n", rc);
 	/* return 1 only if cfs_wi_exit is called */
 	return rc == -ESRCH;
@@ -2017,7 +2017,7 @@ void cfs_hash_debug_header(struct seq_file *m)
 	if (!hs->hs_rehash_buckets)
 		return hs->hs_buckets;
 
-	LASSERT(hs->hs_rehash_bits != 0);
+	LASSERT(hs->hs_rehash_bits);
 	return hs->hs_rehash_bits > hs->hs_cur_bits ?
 	       hs->hs_rehash_buckets : hs->hs_buckets;
 }
@@ -2029,7 +2029,7 @@ void cfs_hash_debug_header(struct seq_file *m)
 	if (!hs->hs_rehash_buckets)
 		return CFS_HASH_NBKT(hs);
 
-	LASSERT(hs->hs_rehash_bits != 0);
+	LASSERT(hs->hs_rehash_bits);
 	return hs->hs_rehash_bits > hs->hs_cur_bits ?
 	       CFS_HASH_RH_NBKT(hs) : CFS_HASH_NBKT(hs);
 }
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
index 8db9157..9c58f82 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
@@ -391,7 +391,7 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 		i += scnprintf(buffer + i, count - i, "[");
 
 	list_for_each_entry(expr, &expr_list->el_exprs, re_link) {
-		if (j++ != 0)
+		if (j++)
 			i += scnprintf(buffer + i, count - i, ",");
 		i += cfs_range_expr_print(buffer + i, count - i, expr,
 					  numexprs > 1);
@@ -533,7 +533,7 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 			}
 
 			rc = cfs_range_expr_parse(&tok, min, max, 1, &expr);
-			if (rc != 0)
+			if (rc)
 				break;
 
 			list_add_tail(&expr->re_link, &expr_list->el_exprs);
@@ -544,7 +544,7 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 			list_add_tail(&expr->re_link, &expr_list->el_exprs);
 	}
 
-	if (rc != 0)
+	if (rc)
 		cfs_expr_list_free(expr_list);
 	else
 		*elpp = expr_list;
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 268a8ef..44a8790 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -712,7 +712,7 @@ struct cfs_cpt_table *
 	 */
 	ncpt = min(2U, ncpt);
 #endif
-	while (ncpu % ncpt != 0)
+	while (ncpu % ncpt)
 		ncpt--; /* worst case is 1 */
 
 	return ncpt;
@@ -737,7 +737,7 @@ struct cfs_cpt_table *
 		      ncpt, rc);
 	}
 
-	if (num_online_cpus() % ncpt != 0) {
+	if (num_online_cpus() % ncpt) {
 		CERROR("CPU number %d is not multiple of cpu_npartition %d, please try different cpu_npartitions value or set pattern string by cpu_pattern=STRING\n",
 		       (int)num_online_cpus(), ncpt);
 		goto failed;
@@ -888,7 +888,7 @@ struct cfs_cpt_table *
 		int			n;
 
 		if (!bracket) {
-			if (*str != 0) {
+			if (*str) {
 				CERROR("Invalid pattern %s\n", str);
 				goto failed;
 			}
@@ -911,7 +911,7 @@ struct cfs_cpt_table *
 			goto failed;
 		}
 
-		if (cfs_cpt_weight(cptab, cpt) != 0) {
+		if (cfs_cpt_weight(cptab, cpt)) {
 			CERROR("Partition %d has already been set.\n", cpt);
 			goto failed;
 		}
@@ -930,14 +930,14 @@ struct cfs_cpt_table *
 		}
 
 		if (cfs_expr_list_parse(str, (bracket - str) + 1,
-					0, high, &el) != 0) {
+					0, high, &el)) {
 			CERROR("Can't parse number range: %s\n", str);
 			goto failed;
 		}
 
 		list_for_each_entry(range, &el->el_exprs, re_link) {
 			for (i = range->re_lo; i <= range->re_hi; i++) {
-				if ((i - range->re_lo) % range->re_stride != 0)
+				if ((i - range->re_lo) % range->re_stride)
 					continue;
 
 				rc = node ? cfs_cpt_set_node(cptab, cpt, i) :
@@ -1044,7 +1044,7 @@ struct cfs_cpt_table *
 	register_hotcpu_notifier(&cfs_cpu_notifier);
 #endif
 
-	if (*cpu_pattern != 0) {
+	if (*cpu_pattern) {
 		cfs_cpt_table = cfs_cpt_table_create_pattern(cpu_pattern);
 		if (!cfs_cpt_table) {
 			CERROR("Failed to create cptab from pattern %s\n",
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index 7f56d2c..3d85cc5 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -93,12 +93,12 @@ static int cfs_crypto_hash_alloc(enum cfs_crypto_hash_alg hash_alg,
 
 	if (key)
 		err = crypto_ahash_setkey(tfm, key, key_len);
-	else if ((*type)->cht_key != 0)
+	else if ((*type)->cht_key)
 		err = crypto_ahash_setkey(tfm,
 					  (unsigned char *)&((*type)->cht_key),
 					  (*type)->cht_size);
 
-	if (err != 0) {
+	if (err) {
 		ahash_request_free(*req);
 		crypto_free_ahash(tfm);
 		return err;
@@ -156,7 +156,7 @@ int cfs_crypto_hash_digest(enum cfs_crypto_hash_alg hash_alg,
 		return -EINVAL;
 
 	err = cfs_crypto_hash_alloc(hash_alg, &type, &req, key, key_len);
-	if (err != 0)
+	if (err)
 		return err;
 
 	if (!hash || *hash_len < type->cht_size) {
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
index 8b551d2..404c2cc 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
@@ -224,21 +224,21 @@ void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
 {
 	char *prefix = "Lustre", *ptype = NULL;
 
-	if ((mask & D_EMERG) != 0) {
+	if (mask & D_EMERG) {
 		prefix = dbghdr_to_err_string(hdr);
 		ptype = KERN_EMERG;
-	} else if ((mask & D_ERROR) != 0) {
+	} else if (mask & D_ERROR) {
 		prefix = dbghdr_to_err_string(hdr);
 		ptype = KERN_ERR;
-	} else if ((mask & D_WARNING) != 0) {
+	} else if (mask & D_WARNING) {
 		prefix = dbghdr_to_info_string(hdr);
 		ptype = KERN_WARNING;
-	} else if ((mask & (D_CONSOLE | libcfs_printk)) != 0) {
+	} else if (mask & (D_CONSOLE | libcfs_printk)) {
 		prefix = dbghdr_to_info_string(hdr);
 		ptype = KERN_INFO;
 	}
 
-	if ((mask & D_CONSOLE) != 0) {
+	if (mask & D_CONSOLE) {
 		printk("%s%s: %.*s", ptype, prefix, len, buf);
 	} else {
 		printk("%s%s: %d:%d:(%s:%d:%s()) %.*s", ptype, prefix,
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 86b4d25..cd057f1 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -547,7 +547,7 @@ static int libcfs_init(void)
 	}
 
 	rc = cfs_cpu_init();
-	if (rc != 0)
+	if (rc)
 		goto cleanup_debug;
 
 	rc = misc_register(&libcfs_dev);
@@ -566,7 +566,7 @@ static int libcfs_init(void)
 	rc = min(cfs_cpt_weight(cfs_cpt_table, CFS_CPT_ANY), 4);
 	rc = cfs_wi_sched_create("cfs_rh", cfs_cpt_table, CFS_CPT_ANY,
 				 rc, &cfs_sched_rehash);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Startup workitem scheduler: error: %d\n", rc);
 		goto cleanup_deregister;
 	}
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 1c7efdf..9f5eeb3 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -432,7 +432,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 
 	if (cdls) {
 		if (libcfs_console_ratelimit &&
-		    cdls->cdls_next != 0 &&     /* not first time ever */
+		    cdls->cdls_next &&		/* not first time ever */
 		    !cfs_time_after(cfs_time_current(), cdls->cdls_next)) {
 			/* skipping a console message */
 			cdls->cdls_count++;
@@ -489,7 +489,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 		put_cpu();
 	}
 
-	if (cdls && cdls->cdls_count != 0) {
+	if (cdls && cdls->cdls_count) {
 		string_buf = cfs_trace_get_console_buffer();
 
 		needed = snprintf(string_buf, CFS_TRACE_CONSOLE_BUFFER_SIZE,
@@ -847,12 +847,12 @@ int cfs_trace_dump_debug_buffer_usrstr(void __user *usr_str, int usr_str_nob)
 	int	   rc;
 
 	rc = cfs_trace_allocate_string_buffer(&str, usr_str_nob + 1);
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	rc = cfs_trace_copyin_string(str, usr_str_nob + 1,
 				     usr_str, usr_str_nob);
-	if (rc != 0)
+	if (rc)
 		goto out;
 
 	if (str[0] != '/') {
@@ -912,7 +912,7 @@ int cfs_trace_daemon_command_usrstr(void __user *usr_str, int usr_str_nob)
 	int   rc;
 
 	rc = cfs_trace_allocate_string_buffer(&str, usr_str_nob + 1);
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	rc = cfs_trace_copyin_string(str, usr_str_nob + 1,
@@ -1003,7 +1003,7 @@ static int tracefiled(void *arg)
 
 		filp = NULL;
 		cfs_tracefile_read_lock();
-		if (cfs_tracefile[0] != 0) {
+		if (cfs_tracefile[0]) {
 			filp = filp_open(cfs_tracefile,
 					 O_CREAT | O_RDWR | O_LARGEFILE,
 					 0600);
@@ -1141,7 +1141,7 @@ int cfs_tracefile_init(int max_pages)
 	int		    factor;
 
 	rc = cfs_tracefile_init_arch();
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	cfs_tcd_for_each(tcd, i, j) {
diff --git a/drivers/staging/lustre/lnet/libcfs/workitem.c b/drivers/staging/lustre/lnet/libcfs/workitem.c
index 84118b5..b9eda17 100644
--- a/drivers/staging/lustre/lnet/libcfs/workitem.c
+++ b/drivers/staging/lustre/lnet/libcfs/workitem.c
@@ -208,7 +208,7 @@ static int cfs_wi_scheduler(void *arg)
 
 	/* CPT affinity scheduler? */
 	if (sched->ws_cptab)
-		if (cfs_cpt_bind(sched->ws_cptab, sched->ws_cpt) != 0)
+		if (cfs_cpt_bind(sched->ws_cptab, sched->ws_cpt))
 			CWARN("Failed to bind %s on CPT %d\n",
 			      sched->ws_name, sched->ws_cpt);
 
@@ -247,7 +247,7 @@ static int cfs_wi_scheduler(void *arg)
 			rc = (*wi->wi_action) (wi);
 
 			spin_lock(&sched->ws_lock);
-			if (rc != 0) /* WI should be dead, even be freed! */
+			if (rc) /* WI should be dead, even be freed! */
 				continue;
 
 			wi->wi_running = 0;
@@ -447,7 +447,7 @@ static int cfs_wi_scheduler(void *arg)
 	list_for_each_entry(sched, &cfs_wi_data.wi_scheds, ws_list) {
 		spin_lock(&cfs_wi_data.wi_glock);
 
-		while (sched->ws_nthreads != 0) {
+		while (sched->ws_nthreads) {
 			spin_unlock(&cfs_wi_data.wi_glock);
 			set_current_state(TASK_UNINTERRUPTIBLE);
 			schedule_timeout(cfs_time_seconds(1) / 20);
-- 
1.7.1
