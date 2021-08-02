Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C65AC4338F
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:38 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 209F860F36
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 209F860F36
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1854E352DA7;
	Mon,  2 Aug 2021 12:51:27 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E3BFE352C04
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:50:59 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 801A71008054;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7EAE6C2F4C; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:39 -0400
Message-Id: <1627933851-7603-20-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 19/25] lustre: osc: Remove client contention
 support
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

Lockless buffered i/o and contention detection don't work,
lockless bufferd i/o is unfixable and contention detection
is broken enough that it will have to be rewritten.

Let's remove both.  This patch starts the removal by
pulling the client side support.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14838
Lustre-commit: 5ad00e36eca11a14 ("LU-14838 osc: Remove client contention support")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44205
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |  1 -
 fs/lustre/mdc/lproc_mdc.c      | 41 -----------------------------------------
 fs/lustre/mdc/mdc_dev.c        | 15 +--------------
 fs/lustre/osc/lproc_osc.c      | 33 ---------------------------------
 fs/lustre/osc/osc_lock.c       | 19 ++-----------------
 fs/lustre/osc/osc_object.c     | 22 ----------------------
 6 files changed, 3 insertions(+), 128 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 3a2d8bc..8a62eb2 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -658,7 +658,6 @@ int osc_attr_update(const struct lu_env *env, struct cl_object *obj,
 int osc_object_glimpse(const struct lu_env *env, const struct cl_object *obj,
 		       struct ost_lvb *lvb);
 int osc_object_invalidate(const struct lu_env *env, struct osc_object *osc);
-int osc_object_is_contended(struct osc_object *obj);
 int osc_object_find_cbdata(const struct lu_env *env, struct cl_object *obj,
 			   ldlm_iterator_t iter, void *data);
 int osc_object_prune(const struct lu_env *env, struct cl_object *obj);
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index b3ace37..d13a6b7 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -268,45 +268,6 @@ static int mdc_cached_mb_seq_show(struct seq_file *m, void *v)
 }
 LDEBUGFS_SEQ_FOPS(mdc_cached_mb);
 
-static int mdc_contention_seconds_seq_show(struct seq_file *m, void *v)
-{
-	struct obd_device *obd = m->private;
-	struct osc_device *od  = obd2osc_dev(obd);
-
-	seq_printf(m, "%lld\n", od->od_contention_time);
-	return 0;
-}
-
-static ssize_t mdc_contention_seconds_seq_write(struct file *file,
-						const char __user *buffer,
-						size_t count, loff_t *off)
-{
-	struct seq_file *sfl = file->private_data;
-	struct obd_device *obd = sfl->private;
-	struct osc_device *od  = obd2osc_dev(obd);
-	int rc;
-	char kernbuf[128];
-	s64 val;
-
-	if (count >= sizeof(kernbuf))
-		return -EINVAL;
-
-	if (copy_from_user(kernbuf, buffer, count))
-		return -EFAULT;
-	kernbuf[count] = 0;
-
-	rc = kstrtos64(kernbuf, count, &val);
-	if (rc)
-		return rc;
-	if (val < 0 || val > INT_MAX)
-		return -ERANGE;
-
-	od->od_contention_time = val;
-
-	return count;
-}
-LDEBUGFS_SEQ_FOPS(mdc_contention_seconds);
-
 static int mdc_unstable_stats_seq_show(struct seq_file *m, void *v)
 {
 	struct obd_device *obd = m->private;
@@ -628,8 +589,6 @@ static ssize_t mdc_dom_min_repsize_seq_write(struct file *file,
 	  .fops	=	&mdc_checksum_type_fops		},
 	{ .name	=	"timeouts",
 	  .fops	=	&mdc_timeouts_fops		},
-	{ .name	=	"contention_seconds",
-	  .fops	=	&mdc_contention_seconds_fops	},
 	{ .name	=	"import",
 	  .fops	=	&mdc_import_fops		},
 	{ .name	=	"state",
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 1c28f80..ce4148d 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -536,18 +536,7 @@ static int mdc_lock_upcall(void *cookie, struct lustre_handle *lockh,
 		mdc_lock_granted(env, oscl, lockh);
 
 	/* Error handling, some errors are tolerable. */
-	if (oscl->ols_locklessable && rc == -EUSERS) {
-		/* This is a tolerable error, turn this lock into
-		 * lockless lock.
-		 */
-		osc_object_set_contended(cl2osc(slice->cls_obj));
-		LASSERT(slice->cls_ops != oscl->ols_lockless_ops);
-
-		/* Change this lock to ldlmlock-less lock. */
-		osc_lock_to_lockless(env, oscl, 1);
-		oscl->ols_state = OLS_GRANTED;
-		rc = 0;
-	} else if (oscl->ols_glimpse && rc == -ENAVAIL) {
+	if (oscl->ols_glimpse && rc == -ENAVAIL) {
 		LASSERT(oscl->ols_flags & LDLM_FL_LVB_READY);
 		mdc_lock_lvb_update(env, cl2osc(slice->cls_obj),
 				    NULL, &oscl->ols_lvb);
@@ -972,8 +961,6 @@ int mdc_lock_init(const struct lu_env *env, struct cl_object *obj,
 
 	if (!(enqflags & CEF_MUST))
 		osc_lock_to_lockless(env, ols, (enqflags & CEF_NEVER));
-	if (ols->ols_locklessable && !(enqflags & CEF_DISCARD_DATA))
-		ols->ols_flags |= LDLM_FL_DENY_ON_CONTENTION;
 
 	if (io->ci_type == CIT_WRITE || cl_io_is_mkwrite(io))
 		osc_lock_set_writer(env, io, obj, ols);
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index bfc5df1..f9878e0 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -507,38 +507,6 @@ static ssize_t checksum_dump_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(checksum_dump);
 
-static ssize_t contention_seconds_show(struct kobject *kobj,
-				       struct attribute *attr,
-				       char *buf)
-{
-	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kset.kobj);
-	struct osc_device *od = obd2osc_dev(obd);
-
-	return sprintf(buf, "%lld\n", od->od_contention_time);
-}
-
-static ssize_t contention_seconds_store(struct kobject *kobj,
-					struct attribute *attr,
-					const char *buffer,
-					size_t count)
-{
-	struct obd_device *obd = container_of(kobj, struct obd_device,
-					      obd_kset.kobj);
-	struct osc_device *od = obd2osc_dev(obd);
-	unsigned int val;
-	int rc;
-
-	rc = kstrtouint(buffer, 10, &val);
-	if (rc)
-		return rc;
-
-	od->od_contention_time = val;
-
-	return count;
-}
-LUSTRE_RW_ATTR(contention_seconds);
-
 static ssize_t destroys_in_flight_show(struct kobject *kobj,
 				       struct attribute *attr,
 				       char *buf)
@@ -887,7 +855,6 @@ void lproc_osc_attach_seqstat(struct obd_device *obd)
 	&lustre_attr_active.attr,
 	&lustre_attr_checksums.attr,
 	&lustre_attr_checksum_dump.attr,
-	&lustre_attr_contention_seconds.attr,
 	&lustre_attr_cur_dirty_bytes.attr,
 	&lustre_attr_cur_grant_bytes.attr,
 	&lustre_attr_cur_lost_grant_bytes.attr,
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 6d6d271..f6faed7 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -287,18 +287,7 @@ static int osc_lock_upcall(void *cookie, struct lustre_handle *lockh,
 		osc_lock_granted(env, oscl, lockh);
 
 	/* Error handling, some errors are tolerable. */
-	if (oscl->ols_locklessable && rc == -EUSERS) {
-		/* This is a tolerable error, turn this lock into
-		 * lockless lock.
-		 */
-		osc_object_set_contended(cl2osc(slice->cls_obj));
-		LASSERT(slice->cls_ops != oscl->ols_lockless_ops);
-
-		/* Change this lock to ldlmlock-less lock. */
-		osc_lock_to_lockless(env, oscl, 1);
-		oscl->ols_state = OLS_GRANTED;
-		rc = 0;
-	} else if (oscl->ols_glimpse && rc == -ENAVAIL) {
+	if (oscl->ols_glimpse && rc == -ENAVAIL) {
 		LASSERT(oscl->ols_flags & LDLM_FL_LVB_READY);
 		osc_lock_lvb_update(env, cl2osc(slice->cls_obj),
 				    NULL, &oscl->ols_lvb);
@@ -818,9 +807,7 @@ void osc_lock_to_lockless(const struct lu_env *env,
 					(io->ci_lockreq == CILR_MAYBE) &&
 					(ocd->ocd_connect_flags &
 					 OBD_CONNECT_SRVLOCK);
-		if (io->ci_lockreq == CILR_NEVER ||
-		    /* lockless IO */
-		    (ols->ols_locklessable && osc_object_is_contended(oob))) {
+		if (io->ci_lockreq == CILR_NEVER) {
 			ols->ols_locklessable = 1;
 			slice->cls_ops = ols->ols_lockless_ops;
 		}
@@ -1242,8 +1229,6 @@ int osc_lock_init(const struct lu_env *env,
 	if (!(enqflags & CEF_MUST))
 		/* try to convert this lock to a lockless lock */
 		osc_lock_to_lockless(env, oscl, (enqflags & CEF_NEVER));
-	if (oscl->ols_locklessable && !(enqflags & CEF_DISCARD_DATA))
-		oscl->ols_flags |= LDLM_FL_DENY_ON_CONTENTION;
 
 	if (io->ci_type == CIT_WRITE || cl_io_is_mkwrite(io))
 		osc_lock_set_writer(env, io, obj, oscl);
diff --git a/fs/lustre/osc/osc_object.c b/fs/lustre/osc/osc_object.c
index 0dd926a..517ce5c 100644
--- a/fs/lustre/osc/osc_object.c
+++ b/fs/lustre/osc/osc_object.c
@@ -332,28 +332,6 @@ static int osc_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	return rc;
 }
 
-int osc_object_is_contended(struct osc_object *obj)
-{
-	struct osc_device *dev = lu2osc_dev(obj->oo_cl.co_lu.lo_dev);
-	time64_t osc_contention_time = dev->od_contention_time;
-	ktime_t retry_time;
-
-	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_OBJECT_CONTENTION))
-		return 1;
-
-	if (!obj->oo_contended)
-		return 0;
-
-	retry_time = ktime_add_ns(obj->oo_contention_time,
-				  osc_contention_time * NSEC_PER_SEC);
-	if (ktime_after(ktime_get(), retry_time)) {
-		osc_object_clear_contended(obj);
-		return 0;
-	}
-	return 1;
-}
-EXPORT_SYMBOL(osc_object_is_contended);
-
 /**
  * Implementation of struct cl_object_operations::coo_req_attr_set() for osc
  * layer. osc is responsible for struct obdo::o_id and struct obdo::o_seq
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
