Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 4778DC433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 12 Dec 2021 15:08:21 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 154B421CB7E;
	Sun, 12 Dec 2021 07:08:14 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3208421CBFF
 for <lustre-devel@lists.lustre.org>; Sun, 12 Dec 2021 07:08:08 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id BF19010084DD;
 Sun, 12 Dec 2021 10:08:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id AF3F6E080E; Sun, 12 Dec 2021 10:08:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 12 Dec 2021 10:07:56 -0500
Message-Id: <1639321683-22909-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
References: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/12] lnet: Allow specifying a source NID
 for lnetctl ping
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
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

Add a new --source option for lnetctl ping command. This allows the
user to specify a local NI from which to send the ping. This also
ensures that the specified destination NID is also used. Otherwise,
pings to multi-rail peers may end up going to a different peer NI
based on the multi-rail selection algorithm. The ability to specify
a source NI, and thus fix the destination NI, is a great help in
troubleshooting communication issues between multi-rail peers.

Add test to exercise lnetctl ping --source option.

HPE-bug-id: LUS-10296
WC-bug-id: https://jira.whamcloud.com/browse/LU-14939
Lustre-commit: 48ef9982c474a02c4 ("LU-14939 lnet: Allow specifying a source NID for lnetctl ping")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/44727
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Andriy Skulysh <andriy.skulysh@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lnet/lnet-dlc.h |  1 +
 net/lnet/lnet/api-ni.c             | 29 ++++++++++++++++++++++-------
 2 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/include/uapi/linux/lnet/lnet-dlc.h b/include/uapi/linux/lnet/lnet-dlc.h
index 2ca70eb..415968a 100644
--- a/include/uapi/linux/lnet/lnet-dlc.h
+++ b/include/uapi/linux/lnet/lnet-dlc.h
@@ -132,6 +132,7 @@ struct lnet_ioctl_ping_data {
 	__u32 mr_info;
 	struct lnet_process_id ping_id;
 	struct lnet_process_id __user *ping_buf;
+	lnet_nid_t ping_src;
 };
 
 struct lnet_ioctl_config_data {
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 3ed3f0b..550f035 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -205,8 +205,9 @@ static void lnet_set_lnd_timeout(void)
  */
 static atomic_t lnet_dlc_seq_no = ATOMIC_INIT(0);
 
-static int lnet_ping(struct lnet_process_id id, signed long timeout,
-		     struct lnet_process_id __user *ids, int n_ids);
+static int lnet_ping(struct lnet_process_id id, lnet_nid_t src_nid,
+		     signed long timeout, struct lnet_process_id __user *ids,
+		     int n_ids);
 
 static int lnet_discover(struct lnet_process_id id, u32 force,
 			 struct lnet_process_id __user *ids, int n_ids);
@@ -4267,7 +4268,7 @@ u32 lnet_get_dlc_seq_locked(void)
 		else
 			timeout = msecs_to_jiffies(data->ioc_u32[1]);
 
-		rc = lnet_ping(id, timeout, data->ioc_pbuf1,
+		rc = lnet_ping(id, LNET_NID_ANY, timeout, data->ioc_pbuf1,
 			       data->ioc_plen1 / sizeof(struct lnet_process_id));
 
 		if (rc < 0)
@@ -4281,6 +4282,19 @@ u32 lnet_get_dlc_seq_locked(void)
 		struct lnet_ioctl_ping_data *ping = arg;
 		struct lnet_peer *lp;
 		signed long timeout;
+		lnet_nid_t src_nid = LNET_NID_ANY;
+
+		/* Check if the supplied ping data supports source nid
+		 * NB: This check is sufficient if lnet_ioctl_ping_data has
+		 * additional fields added, but if they are re-ordered or
+		 * fields removed then this will break. It is expected that
+		 * these ioctls will be replaced with netlink implementation, so
+		 * it is probably not worth coming up with a more robust version
+		 * compatibility scheme.
+		 */
+		if (ping->ping_hdr.ioc_len >=
+		    sizeof(struct lnet_ioctl_ping_data))
+			src_nid = ping->ping_src;
 
 		/* If timeout is negative then set default of 3 minutes */
 		if (((s32)ping->op_param) <= 0 ||
@@ -4289,7 +4303,7 @@ u32 lnet_get_dlc_seq_locked(void)
 		else
 			timeout = msecs_to_jiffies(ping->op_param);
 
-		rc = lnet_ping(ping->ping_id, timeout,
+		rc = lnet_ping(ping->ping_id, src_nid, timeout,
 			       ping->ping_buf,
 			       ping->ping_count);
 		if (rc < 0)
@@ -4526,8 +4540,9 @@ struct ping_data {
 		complete(&pd->completion);
 }
 
-static int lnet_ping(struct lnet_process_id id, signed long timeout,
-		     struct lnet_process_id __user *ids, int n_ids)
+static int lnet_ping(struct lnet_process_id id, lnet_nid_t src_nid,
+		     signed long timeout, struct lnet_process_id __user *ids,
+		     int n_ids)
 {
 	struct lnet_md md = { NULL };
 	struct ping_data pd = { 0 };
@@ -4572,7 +4587,7 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
 		goto fail_ping_buffer_decref;
 	}
 
-	rc = LNetGet(LNET_NID_ANY, pd.mdh, id,
+	rc = LNetGet(src_nid, pd.mdh, id,
 		     LNET_RESERVED_PORTAL,
 		     LNET_PROTO_PING_MATCHBITS, 0, false);
 	if (rc) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
