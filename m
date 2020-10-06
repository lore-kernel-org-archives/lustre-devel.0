From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:59 -0400
Subject: [lustre-devel] [PATCH 20/42] lnet: don't read debugfs lnet stats
 when shutting down
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

A race exist on shutdown with an external application reading
the debugfs file containing lnet stats which causes an kernel
crash.

[  257.192117] BUG: unable to handle kernel paging request at fffffffffffffff0
[  257.194859] IP: [<ffffffffc0bb95c6>] cfs_percpt_number+0x6/0x10 [libcfs]
[  257.196863] PGD 7c14067 PUD 7c16067 PMD 0
[  257.198665] Oops: 0000 [#1] SMP
[  257.200431] Modules linked in: ksocklnd(OE) lnet(OE) libcfs(OE) dm_service_time iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi sunrpc zfs(POE) zunicode(POE) zavl(POE) icp(POE) zcommon(POE) znvpair(POE) spl(OE) ppdev iosf_mbi crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel lrw gf128mul glue_helper ablk_helper cryptd pcspkr sg e1000 video parport_pc parport i2c_piix4 dm_multipath dm_mod ip_tables xfs libcrc32c sd_mod crc_t10dif crct10dif_generic ata_generic pata_acpi crct10dif_pclmul crct10dif_common ata_piix serio_raw libata [last unloaded: obdclass]
[  257.222895] CPU: 0 PID: 7331 Comm: lctl Tainted: P           OE  ------------   3.10.0-957.el7_lustre.x86_64 #1
[  257.229312] Hardware name: innotek GmbH VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006
[  257.233659] task: ffff9c9fbaf15140 ti: ffff9c9fbabcc000 task.ti: ffff9c9fbabcc000
[  257.238388] RIP: 0010:[<ffffffffc0bb95c6>]  [<ffffffffc0bb95c6>] cfs_percpt_number+0x6/0x10 [libcfs]
[  257.243851] RSP: 0018:ffff9c9fbabcfdb0  EFLAGS: 00010296
[  257.246400] RAX: 0000000000000000 RBX: ffff9c9fba2a5200 RCX: 0000000000000000
[  257.250304] RDX: 0000000000000001 RSI: 00000000ffffffff RDI: 0000000000000000
[  257.253677] RBP: ffff9c9fbabcfdd0 R08: 000000000001f120 R09: ffff9c9fbe001700
[  257.257073] R10: ffffffffc0c376db R11: 0000000000000246 R12: 0000000000000000
[  257.260339] R13: 0000000000000000 R14: 0000000000001000 R15: ffff9c9fba2a5200
[  257.263204] FS:  00007fbdc89c6740(0000) GS:ffff9c9fbfc00000(0000) knlGS:0000000000000000
[  257.266409] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  257.269105] CR2: fffffffffffffff0 CR3: 0000000022e36000 CR4: 00000000000606f0
[  257.272529] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  257.275209] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  257.277936] Call Trace:
[  257.279245]  [<ffffffffc0c0a88b>] ? lnet_counters_get_common+0xeb/0x150 [lnet]
[  257.283071]  [<ffffffffc0c0a95c>] lnet_counters_get+0x6c/0x150 [lnet]
[  257.286224]  [<ffffffffc0c3771b>] __proc_lnet_stats+0xfb/0x810 [lnet]
[  257.288975]  [<ffffffffc0ba6602>] lprocfs_call_handler+0x22/0x50 [libcfs]
[  257.292387]  [<ffffffffc0c36bf5>] proc_lnet_stats+0x25/0x30 [lnet]
[  257.295184]  [<ffffffffc0ba665d>] lnet_debugfs_read+0x2d/0x40 [libcfs]

The solution is to only allow reading of the lnet stats when the
lnet state is LNET_STATE_RUNNING.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11986
Lustre-commit: f53eea15d470c9 ("LU-11986 lnet: don't read debugfs lnet stats when shutting down")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/39404
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Nathaniel Clark <nclark@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 include/linux/lnet/lib-lnet.h |  2 +-
 net/lnet/lnet/api-ni.c        | 40 +++++++++++++++++++++++++++++-----------
 net/lnet/lnet/router_proc.c   | 17 ++++++-----------
 3 files changed, 36 insertions(+), 23 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 6a9ea10..6253c16 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -664,7 +664,7 @@ int lnet_delay_rule_list(int pos, struct lnet_fault_attr *attr,
 /** @} lnet_fault_simulation */
 
 void lnet_counters_get_common(struct lnet_counters_common *common);
-void lnet_counters_get(struct lnet_counters *counters);
+int lnet_counters_get(struct lnet_counters *counters);
 void lnet_counters_reset(void);
 
 unsigned int lnet_iov_nob(unsigned int niov, struct kvec *iov);
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 0f325ec..af2089e 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -853,16 +853,17 @@ static void lnet_assert_wire_constants(void)
 }
 EXPORT_SYMBOL(lnet_unregister_lnd);
 
-void
-lnet_counters_get_common(struct lnet_counters_common *common)
+static void
+lnet_counters_get_common_locked(struct lnet_counters_common *common)
 {
 	struct lnet_counters *ctr;
 	int i;
 
+	/* FIXME !!! Their is no assert_lnet_net_locked() to ensure this
+	 * actually called under the protection of the lnet_net_lock.
+	 */
 	memset(common, 0, sizeof(*common));
 
-	lnet_net_lock(LNET_LOCK_EX);
-
 	cfs_percpt_for_each(ctr, i, the_lnet.ln_counters) {
 		common->lcc_msgs_max	 += ctr->lct_common.lcc_msgs_max;
 		common->lcc_msgs_alloc   += ctr->lct_common.lcc_msgs_alloc;
@@ -876,23 +877,35 @@ static void lnet_assert_wire_constants(void)
 		common->lcc_route_length += ctr->lct_common.lcc_route_length;
 		common->lcc_drop_length  += ctr->lct_common.lcc_drop_length;
 	}
+}
+
+void
+lnet_counters_get_common(struct lnet_counters_common *common)
+{
+	lnet_net_lock(LNET_LOCK_EX);
+	lnet_counters_get_common_locked(common);
 	lnet_net_unlock(LNET_LOCK_EX);
 }
 EXPORT_SYMBOL(lnet_counters_get_common);
 
-void
+int
 lnet_counters_get(struct lnet_counters *counters)
 {
 	struct lnet_counters *ctr;
 	struct lnet_counters_health *health = &counters->lct_health;
-	int i;
+	int i, rc = 0;
 
 	memset(counters, 0, sizeof(*counters));
 
-	lnet_counters_get_common(&counters->lct_common);
-
 	lnet_net_lock(LNET_LOCK_EX);
 
+	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
+		rc = -ENODEV;
+		goto out_unlock;
+	}
+
+	lnet_counters_get_common_locked(&counters->lct_common);
+
 	cfs_percpt_for_each(ctr, i, the_lnet.ln_counters) {
 		health->lch_rst_alloc += ctr->lct_health.lch_rst_alloc;
 		health->lch_resend_count += ctr->lct_health.lch_resend_count;
@@ -919,7 +932,9 @@ static void lnet_assert_wire_constants(void)
 		health->lch_network_timeout_count +=
 				ctr->lct_health.lch_network_timeout_count;
 	}
+out_unlock:
 	lnet_net_unlock(LNET_LOCK_EX);
+	return rc;
 }
 EXPORT_SYMBOL(lnet_counters_get);
 
@@ -931,9 +946,12 @@ static void lnet_assert_wire_constants(void)
 
 	lnet_net_lock(LNET_LOCK_EX);
 
+	if (the_lnet.ln_state != LNET_STATE_RUNNING)
+		goto avoid_reset;
+
 	cfs_percpt_for_each(counters, i, the_lnet.ln_counters)
 		memset(counters, 0, sizeof(struct lnet_counters));
-
+avoid_reset:
 	lnet_net_unlock(LNET_LOCK_EX);
 }
 
@@ -3680,9 +3698,9 @@ u32 lnet_get_dlc_seq_locked(void)
 			return -EINVAL;
 
 		mutex_lock(&the_lnet.ln_api_mutex);
-		lnet_counters_get(&lnet_stats->st_cntrs);
+		rc = lnet_counters_get(&lnet_stats->st_cntrs);
 		mutex_unlock(&the_lnet.ln_api_mutex);
-		return 0;
+		return rc;
 	}
 
 	case IOC_LIBCFS_CONFIG_RTR:
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index 7fe8d33..96cc506 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -83,8 +83,7 @@ static int proc_lnet_stats(struct ctl_table *table, int write,
 	size_t nob = *lenp;
 	loff_t pos = *ppos;
 	int len;
-	char *tmpstr;
-	const int tmpsiz = 256; /* 7 %u and 4 %llu */
+	char tmpstr[256]; /* 7 %u and 4 %llu */
 
 	if (write) {
 		lnet_counters_reset();
@@ -96,16 +95,13 @@ static int proc_lnet_stats(struct ctl_table *table, int write,
 	if (!ctrs)
 		return -ENOMEM;
 
-	tmpstr = kmalloc(tmpsiz, GFP_KERNEL);
-	if (!tmpstr) {
-		kfree(ctrs);
-		return -ENOMEM;
-	}
+	rc = lnet_counters_get(ctrs);
+	if (rc)
+		goto out_no_ctrs;
 
-	lnet_counters_get(ctrs);
 	common = ctrs->lct_common;
 
-	len = scnprintf(tmpstr, tmpsiz,
+	len = scnprintf(tmpstr, sizeof(tmpstr),
 			"%u %u %u %u %u %u %u %llu %llu %llu %llu",
 			common.lcc_msgs_alloc, common.lcc_msgs_max,
 			common.lcc_errors,
@@ -119,8 +115,7 @@ static int proc_lnet_stats(struct ctl_table *table, int write,
 	else
 		rc = cfs_trace_copyout_string(buffer, nob,
 					      tmpstr + pos, "\n");
-
-	kfree(tmpstr);
+out_no_ctrs:
 	kfree(ctrs);
 	return rc;
 }
-- 
1.8.3.1
