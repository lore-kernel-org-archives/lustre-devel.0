Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BA09C432BE
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:23 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 97C7E60F36
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 97C7E60F36
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1138C352D71;
	Mon,  2 Aug 2021 12:51:16 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9645D352BFC
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:50:59 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 7E68D1008053;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7BA73C2F46; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:38 -0400
Message-Id: <1627933851-7603-19-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 18/25] lustre: osc: Remove lockless truncate
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <pfarrell@whamcloud.com>

Lockless truncate does not work and cannot be made to work.

Fundamentally, it has no means of ensuring consistency
across clients because it can't force them all to drop
cached data without locking.

It's been off for years - let's just get rid of it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14838
Lustre-commit: 6335dba83995765 ("LU-14838 osc: Remove lockless truncate")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44204
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h         |  2 --
 fs/lustre/llite/llite_lib.c            |  3 +--
 fs/lustre/mdc/lproc_mdc.c              |  2 --
 fs/lustre/osc/lproc_osc.c              | 35 ----------------------------------
 fs/lustre/osc/osc_io.c                 | 10 ----------
 fs/lustre/osc/osc_lock.c               |  6 +-----
 fs/lustre/ptlrpc/wiretest.c            |  2 --
 include/uapi/linux/lustre/lustre_idl.h |  1 -
 8 files changed, 2 insertions(+), 59 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 13e9363..3a2d8bc 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -116,12 +116,10 @@ struct osc_device {
 	struct osc_stats {
 		u64		os_lockless_writes;	/* by bytes */
 		u64		os_lockless_reads;	/* by bytes */
-		u64		os_lockless_truncates;	/* by times */
 	} od_stats;
 
 	/* configuration item(s) */
 	time64_t		od_contention_time;
-	int			od_lockless_truncate;
 };
 
 /* \defgroup osc osc
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 7b8f1b5..63d0f02 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -284,7 +284,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	data->ocd_connect_flags = OBD_CONNECT_IBITS	| OBD_CONNECT_NODEVOH  |
 				  OBD_CONNECT_ATTRFID	| OBD_CONNECT_GRANT    |
 				  OBD_CONNECT_VERSION	| OBD_CONNECT_BRW_SIZE |
-				  OBD_CONNECT_SRVLOCK	| OBD_CONNECT_TRUNCLOCK|
+				  OBD_CONNECT_SRVLOCK	|
 				  OBD_CONNECT_CANCELSET | OBD_CONNECT_FID      |
 				  OBD_CONNECT_AT	| OBD_CONNECT_LOV_V3   |
 				  OBD_CONNECT_VBR	| OBD_CONNECT_FULL20   |
@@ -510,7 +510,6 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_REQPORTAL | OBD_CONNECT_BRW_SIZE |
 				  OBD_CONNECT_CANCELSET | OBD_CONNECT_FID      |
 				  OBD_CONNECT_SRVLOCK   |
-				  OBD_CONNECT_TRUNCLOCK |
 				  OBD_CONNECT_AT	| OBD_CONNECT_OSS_CAPA |
 				  OBD_CONNECT_VBR	| OBD_CONNECT_FULL20   |
 				  OBD_CONNECT_64BITHASH | OBD_CONNECT_MAXBYTES |
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index 02636ef..b3ace37 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -561,8 +561,6 @@ static int mdc_stats_seq_show(struct seq_file *seq, void *v)
 		   stats->os_lockless_writes);
 	seq_printf(seq, "lockless_read_bytes\t\t%llu\n",
 		   stats->os_lockless_reads);
-	seq_printf(seq, "lockless_truncate\t\t%llu\n",
-		   stats->os_lockless_truncates);
 	return 0;
 }
 
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index 3991b2c..bfc5df1 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -539,38 +539,6 @@ static ssize_t contention_seconds_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(contention_seconds);
 
-static ssize_t lockless_truncate_show(struct kobject *kobj,
-				      struct attribute *attr,
-				      char *buf)
-{
-	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kset.kobj);
-	struct osc_device *od = obd2osc_dev(obd);
-
-	return sprintf(buf, "%u\n", od->od_lockless_truncate);
-}
-
-static ssize_t lockless_truncate_store(struct kobject *kobj,
-				       struct attribute *attr,
-				       const char *buffer,
-				       size_t count)
-{
-	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kset.kobj);
-	struct osc_device *od = obd2osc_dev(obd);
-	bool val;
-	int rc;
-
-	rc = kstrtobool(buffer, &val);
-	if (rc)
-		return rc;
-
-	od->od_lockless_truncate = val;
-
-	return count;
-}
-LUSTRE_RW_ATTR(lockless_truncate);
-
 static ssize_t destroys_in_flight_show(struct kobject *kobj,
 				       struct attribute *attr,
 				       char *buf)
@@ -890,8 +858,6 @@ static int osc_stats_seq_show(struct seq_file *seq, void *v)
 		   stats->os_lockless_writes);
 	seq_printf(seq, "lockless_read_bytes\t\t%llu\n",
 		   stats->os_lockless_reads);
-	seq_printf(seq, "lockless_truncate\t\t%llu\n",
-		   stats->os_lockless_truncates);
 	return 0;
 }
 
@@ -928,7 +894,6 @@ void lproc_osc_attach_seqstat(struct obd_device *obd)
 	&lustre_attr_cur_dirty_grant_bytes.attr,
 	&lustre_attr_destroys_in_flight.attr,
 	&lustre_attr_grant_shrink_interval.attr,
-	&lustre_attr_lockless_truncate.attr,
 	&lustre_attr_max_dirty_mb.attr,
 	&lustre_attr_max_pages_per_rpc.attr,
 	&lustre_attr_max_rpcs_in_flight.attr,
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index f69f201..047ae00 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -703,16 +703,6 @@ void osc_io_setattr_end(const struct lu_env *env,
 		result = cbargs->opc_rc;
 		io->ci_result = cbargs->opc_rc;
 	}
-	if (result == 0) {
-		if (oio->oi_lockless) {
-			/* lockless truncate */
-			struct osc_device *osc = lu2osc_dev(obj->co_lu.lo_dev);
-
-			LASSERT(cl_io_is_trunc(io) || cl_io_is_fallocate(io));
-			/* XXX: Need a lock. */
-			osc->od_stats.os_lockless_truncates++;
-		}
-	}
 
 	if (cl_io_is_trunc(io)) {
 		u64 size = io->u.ci_setattr.sa_attr.lvb_size;
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 422f3e5..6d6d271 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -800,7 +800,6 @@ void osc_lock_to_lockless(const struct lu_env *env,
 	struct cl_io *io = oio->oi_cl.cis_io;
 	struct cl_object *obj = slice->cls_obj;
 	struct osc_object *oob = cl2osc(obj);
-	const struct osc_device *osd = lu2osc_dev(obj->co_lu.lo_dev);
 	struct obd_connect_data *ocd;
 
 	LASSERT(ols->ols_state == OLS_NEW ||
@@ -821,10 +820,7 @@ void osc_lock_to_lockless(const struct lu_env *env,
 					 OBD_CONNECT_SRVLOCK);
 		if (io->ci_lockreq == CILR_NEVER ||
 		    /* lockless IO */
-		    (ols->ols_locklessable && osc_object_is_contended(oob)) ||
-		    /* lockless truncate */
-		    (cl_io_is_trunc(io) && osd->od_lockless_truncate &&
-		     (ocd->ocd_connect_flags & OBD_CONNECT_TRUNCLOCK))) {
+		    (ols->ols_locklessable && osc_object_is_contended(oob))) {
 			ols->ols_locklessable = 1;
 			slice->cls_ops = ols->ols_lockless_ops;
 		}
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index cd1456c..4301bd4 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1108,8 +1108,6 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT_XATTR);
 	LASSERTF(OBD_CONNECT_LARGE_ACL == 0x200ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_LARGE_ACL);
-	LASSERTF(OBD_CONNECT_TRUNCLOCK == 0x400ULL, "found 0x%.16llxULL\n",
-		 OBD_CONNECT_TRUNCLOCK);
 	LASSERTF(OBD_CONNECT_TRANSNO == 0x800ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_TRANSNO);
 	LASSERTF(OBD_CONNECT_IBITS == 0x1000ULL, "found 0x%.16llxULL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 65948d8..77a64f2 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -719,7 +719,6 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT_ACL			 0x80ULL /*access control lists */
 #define OBD_CONNECT_XATTR		0x100ULL /*client use extended attr */
 #define OBD_CONNECT_LARGE_ACL		0x200ULL /* more than 32 ACL entries */
-#define OBD_CONNECT_TRUNCLOCK		0x400ULL /*locks on server for punch */
 #define OBD_CONNECT_TRANSNO		0x800ULL /*replay sends init transno */
 #define OBD_CONNECT_IBITS	       0x1000ULL /* not checked in 2.11+ */
 #define OBD_CONNECT_JOIN	       0x2000ULL /*files can be concatenated.
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
