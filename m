Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 40A4BC433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:31:42 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id ED84721FA3F;
	Sun, 20 Mar 2022 06:31:28 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9F6B921E098
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:14 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 2875EEE6;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 26E8CD87DE; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:33 -0400
Message-Id: <1647783064-20688-20-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 19/50] lnet: convert LNetGetID to return an
 large-addr pid
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

From: Mr NeilBrown <neilb@suse.de>

LNetGetID now returns a 'struct processid' containing an
large-address nid.

Various places still convert it to a 4-byte-addr nid for use.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: a42e0f6471bf5aad3 ("LU-10391 lnet: convert LNetGetID to return an large-addr pid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43607
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c |  7 ++++---
 fs/lustre/lmv/lmv_obd.c     | 12 ++++++------
 include/linux/lnet/api.h    |  2 +-
 net/lnet/lnet/api-ni.c      | 27 ++++++++++++++-------------
 net/lnet/selftest/console.c |  4 ++--
 5 files changed, 27 insertions(+), 25 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 1121652..4c91a78 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -3400,7 +3400,7 @@ ssize_t ll_copy_user_md(const struct lov_user_md __user *md,
 void ll_compute_rootsquash_state(struct ll_sb_info *sbi)
 {
 	struct root_squash_info *squash = &sbi->ll_squash;
-	struct lnet_process_id id;
+	struct lnet_processid id;
 	bool matched;
 	int i;
 
@@ -3416,9 +3416,10 @@ void ll_compute_rootsquash_state(struct ll_sb_info *sbi)
 		i = 0;
 
 		while (LNetGetId(i++, &id) != -ENOENT) {
-			if (id.nid == LNET_NID_LO_0)
+			if (nid_is_lo0(&id.nid))
 				continue;
-			if (cfs_match_nid(id.nid, &squash->rsi_nosquash_nids)) {
+			if (cfs_match_nid(lnet_nid_to_nid4(&id.nid),
+					  &squash->rsi_nosquash_nids)) {
 				matched = true;
 				break;
 			}
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 5fd00d3..5b43cfd 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1084,7 +1084,7 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 {
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_desc *desc;
-	struct lnet_process_id lnet_id;
+	struct lnet_processid lnet_id;
 	int i = 0;
 	int rc;
 
@@ -1116,8 +1116,8 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	 * can distribute subdirs evenly from the beginning.
 	 */
 	while (LNetGetId(i++, &lnet_id) != -ENOENT) {
-		if (lnet_id.nid != LNET_NID_LO_0) {
-			lmv->lmv_qos_rr_index = (u32)lnet_id.nid;
+		if (!nid_is_lo0(&lnet_id.nid)) {
+			lmv->lmv_qos_rr_index = ntohl(lnet_id.nid.nid_addr[0]);
 			break;
 		}
 	}
@@ -1205,16 +1205,16 @@ static int lmv_select_statfs_mdt(struct lmv_obd *lmv, u32 flags)
 
 	/* choose initial MDT for this client */
 	for (i = 0;; i++) {
-		struct lnet_process_id lnet_id;
+		struct lnet_processid lnet_id;
 
 		if (LNetGetId(i, &lnet_id) == -ENOENT)
 			break;
 
-		if (lnet_id.nid != LNET_NID_LO_0) {
+		if (!nid_is_lo0(&lnet_id.nid)) {
 			/* We dont need a full 64-bit modulus, just enough
 			 * to distribute the requests across MDTs evenly.
 			 */
-			lmv->lmv_statfs_start = (u32)lnet_id.nid %
+			lmv->lmv_statfs_start = nidhash(&lnet_id.nid) %
 						lmv->lmv_mdt_count;
 			break;
 		}
diff --git a/include/linux/lnet/api.h b/include/linux/lnet/api.h
index ee0a9a6..6d8e915 100644
--- a/include/linux/lnet/api.h
+++ b/include/linux/lnet/api.h
@@ -75,7 +75,7 @@
  * \see LNetMEAttach
  * @{
  */
-int LNetGetId(unsigned int index, struct lnet_process_id *id);
+int LNetGetId(unsigned int index, struct lnet_processid *id);
 int LNetDist(lnet_nid_t nid, lnet_nid_t *srcnid, u32 *order);
 lnet_nid_t LNetPrimaryNID(lnet_nid_t nid);
 
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 2221b19..d7ada85 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -205,7 +205,7 @@ static void lnet_set_lnd_timeout(void)
  */
 static atomic_t lnet_dlc_seq_no = ATOMIC_INIT(0);
 
-static int lnet_ping(struct lnet_process_id id, lnet_nid_t src_nid,
+static int lnet_ping(struct lnet_process_id id, struct lnet_nid *src_nid,
 		     signed long timeout, struct lnet_process_id __user *ids,
 		     int n_ids);
 
@@ -3865,7 +3865,8 @@ u32 lnet_get_dlc_seq_locked(void)
 {
 	struct libcfs_ioctl_data *data = arg;
 	struct lnet_ioctl_config_data *config;
-	struct lnet_process_id id = { 0 };
+	struct lnet_process_id id4 = {};
+	struct lnet_processid id = {};
 	struct lnet_ni *ni;
 	struct lnet_nid nid;
 	int rc;
@@ -3877,7 +3878,7 @@ u32 lnet_get_dlc_seq_locked(void)
 	switch (cmd) {
 	case IOC_LIBCFS_GET_NI:
 		rc = LNetGetId(data->ioc_count, &id);
-		data->ioc_nid = id.nid;
+		data->ioc_nid = lnet_nid_to_nid4(&id.nid);
 		return rc;
 
 	case IOC_LIBCFS_FAIL_NID:
@@ -4258,8 +4259,8 @@ u32 lnet_get_dlc_seq_locked(void)
 	case IOC_LIBCFS_PING: {
 		signed long timeout;
 
-		id.nid = data->ioc_nid;
-		id.pid = data->ioc_u32[0];
+		id4.nid = data->ioc_nid;
+		id4.pid = data->ioc_u32[0];
 
 		/* If timeout is negative then set default of 3 minutes */
 		if (((s32)data->ioc_u32[1] <= 0) ||
@@ -4268,7 +4269,7 @@ u32 lnet_get_dlc_seq_locked(void)
 		else
 			timeout = msecs_to_jiffies(data->ioc_u32[1]);
 
-		rc = lnet_ping(id, LNET_NID_ANY, timeout, data->ioc_pbuf1,
+		rc = lnet_ping(id4, &LNET_ANY_NID, timeout, data->ioc_pbuf1,
 			       data->ioc_plen1 / sizeof(struct lnet_process_id));
 
 		if (rc < 0)
@@ -4280,9 +4281,9 @@ u32 lnet_get_dlc_seq_locked(void)
 
 	case IOC_LIBCFS_PING_PEER: {
 		struct lnet_ioctl_ping_data *ping = arg;
+		struct lnet_nid src_nid = LNET_ANY_NID;
 		struct lnet_peer *lp;
 		signed long timeout;
-		lnet_nid_t src_nid = LNET_NID_ANY;
 
 		/* Check if the supplied ping data supports source nid
 		 * NB: This check is sufficient if lnet_ioctl_ping_data has
@@ -4294,7 +4295,7 @@ u32 lnet_get_dlc_seq_locked(void)
 		 */
 		if (ping->ping_hdr.ioc_len >=
 		    sizeof(struct lnet_ioctl_ping_data))
-			src_nid = ping->ping_src;
+			lnet_nid4_to_nid(ping->ping_src, &src_nid);
 
 		/* If timeout is negative then set default of 3 minutes */
 		if (((s32)ping->op_param) <= 0 ||
@@ -4303,7 +4304,7 @@ u32 lnet_get_dlc_seq_locked(void)
 		else
 			timeout = msecs_to_jiffies(ping->op_param);
 
-		rc = lnet_ping(ping->ping_id, src_nid, timeout,
+		rc = lnet_ping(ping->ping_id, &src_nid, timeout,
 			       ping->ping_buf,
 			       ping->ping_count);
 		if (rc < 0)
@@ -4482,7 +4483,7 @@ void LNetDebugPeer(struct lnet_processid *id)
  *		-ENOENT If no interface has been found.
  */
 int
-LNetGetId(unsigned int index, struct lnet_process_id *id)
+LNetGetId(unsigned int index, struct lnet_processid *id)
 {
 	struct lnet_ni *ni;
 	struct lnet_net *net;
@@ -4501,7 +4502,7 @@ void LNetDebugPeer(struct lnet_processid *id)
 			if (index-- != 0)
 				continue;
 
-			id->nid = lnet_nid_to_nid4(&ni->ni_nid);
+			id->nid = ni->ni_nid;
 			id->pid = the_lnet.ln_pid;
 			rc = 0;
 			break;
@@ -4540,7 +4541,7 @@ struct ping_data {
 		complete(&pd->completion);
 }
 
-static int lnet_ping(struct lnet_process_id id, lnet_nid_t src_nid,
+static int lnet_ping(struct lnet_process_id id, struct lnet_nid *src_nid,
 		     signed long timeout, struct lnet_process_id __user *ids,
 		     int n_ids)
 {
@@ -4587,7 +4588,7 @@ static int lnet_ping(struct lnet_process_id id, lnet_nid_t src_nid,
 		goto fail_ping_buffer_decref;
 	}
 
-	rc = LNetGet(src_nid, pd.mdh, id,
+	rc = LNetGet(lnet_nid_to_nid4(src_nid), pd.mdh, id,
 		     LNET_RESERVED_PORTAL,
 		     LNET_PROTO_PING_MATCHBITS, 0, false);
 	if (rc) {
diff --git a/net/lnet/selftest/console.c b/net/lnet/selftest/console.c
index 38b169f..85e9300 100644
--- a/net/lnet/selftest/console.c
+++ b/net/lnet/selftest/console.c
@@ -1688,12 +1688,12 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 static void
 lstcon_new_session_id(struct lst_sid *sid)
 {
-	struct lnet_process_id id;
+	struct lnet_processid id;
 
 	LASSERT(console_session.ses_state == LST_SESSION_NONE);
 
 	LNetGetId(1, &id);
-	sid->ses_nid = id.nid;
+	sid->ses_nid = lnet_nid_to_nid4(&id.nid);
 	sid->ses_stamp = div_u64(ktime_get_ns(), NSEC_PER_MSEC);
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
