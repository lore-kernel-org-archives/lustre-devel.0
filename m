Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 2CA55C433FE
	for <lustre-devel@archiver.kernel.org>; Wed, 29 Dec 2021 14:52:03 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 90D9F3AD5CF;
	Wed, 29 Dec 2021 06:51:58 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3EF723AD371
 for <lustre-devel@lists.lustre.org>; Wed, 29 Dec 2021 06:51:31 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 89D8E1006F07;
 Wed, 29 Dec 2021 09:51:28 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8421ED9E71; Wed, 29 Dec 2021 09:51:28 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed, 29 Dec 2021 09:51:18 -0500
Message-Id: <1640789487-22279-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
References: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/13] lustre: mdc: add client tunable to
 disable LSOM update
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
Cc: Alexander Boyko <alexander.boyko@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alexander Boyko <alexander.boyko@hpe.com>

It seems that mdt_lsom_update() has a serious issue with a single
shared file because of its mdt-level mutex for every close request.
The patch adds mdc_lsom parameter to mdc, base on it state client
sends or not LSOM updates to MDT. By default LSOM is on.

lctl set_param mdc.*.mdc_lsom=[on|off]

For a configuration when LSOM is not used the patch helps
MDT with load avarage with a specific load when many threads
open/read/close for a single file.

HPE-bug-id: LUS-10604
WC-bug-id: https://jira.whamcloud.com/browse/LU-15252
Lustre-commit: 19172ed37851fdd57 ("LU-15252 mdc: add client tunable to disable LSOM update")
Signed-off-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-on: https://review.whamcloud.com/45619
Reviewed-by: Andrew Perepechko <andrew.perepechko@hpe.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h     |  3 ++-
 fs/lustre/mdc/lproc_mdc.c   | 29 +++++++++++++++++++++++++++++
 fs/lustre/mdc/mdc_request.c |  4 +++-
 3 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 58a5803..3aa5b37 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -208,7 +208,8 @@ struct client_obd {
 	/* checksumming for data sent over the network */
 	unsigned int		 cl_checksum:1,	/* 0 = disabled, 1 = enabled */
 				 cl_checksum_dump:1, /* same */
-				 cl_ocd_grant_param:1;
+				 cl_ocd_grant_param:1,
+				 cl_lsom_update:1; /* send LSOM updates */
 	/* supported checksum types that are worked out at connect time */
 	enum lustre_sec_part     cl_sp_me;
 	enum lustre_sec_part     cl_sp_to;
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index fe93ccd..3de6533 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -566,6 +566,33 @@ static ssize_t mdc_dom_min_repsize_seq_write(struct file *file,
 }
 LDEBUGFS_SEQ_FOPS(mdc_dom_min_repsize);
 
+static int mdc_lsom_seq_show(struct seq_file *m, void *v)
+{
+	struct obd_device *dev = m->private;
+
+	seq_printf(m, "%s\n", dev->u.cli.cl_lsom_update ? "On" : "Off");
+
+	return 0;
+}
+
+static ssize_t mdc_lsom_seq_write(struct file *file,
+				  const char __user *buffer,
+				  size_t count, loff_t *off)
+{
+	struct obd_device *dev;
+	bool val;
+	int rc;
+
+	dev =  ((struct seq_file *)file->private_data)->private;
+	rc = kstrtobool_from_user(buffer, count, &val);
+	if (rc)
+		return rc;
+
+	dev->u.cli.cl_lsom_update = val;
+	return count;
+}
+LDEBUGFS_SEQ_FOPS(mdc_lsom);
+
 LDEBUGFS_SEQ_FOPS_RO_TYPE(mdc, connect_flags);
 LDEBUGFS_SEQ_FOPS_RO_TYPE(mdc, server_uuid);
 LDEBUGFS_SEQ_FOPS_RO_TYPE(mdc, timeouts);
@@ -601,6 +628,8 @@ static ssize_t mdc_dom_min_repsize_seq_write(struct file *file,
 	  .fops	=	&mdc_stats_fops			},
 	{ .name	=	"mdc_dom_min_repsize",
 	  .fops	=	&mdc_dom_min_repsize_fops	},
+	{ .name =	"mdc_lsom",
+	  .fops =	&mdc_lsom_fops			},
 	{ NULL }
 };
 
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 818c542..9788bd3 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -952,7 +952,8 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 	req->rq_request_portal = MDS_READPAGE_PORTAL;
 	ptlrpc_at_set_req_timeout(req);
 
-	if (!(exp_connect_flags2(exp) & OBD_CONNECT2_LSOM))
+	if (!obd->u.cli.cl_lsom_update ||
+	    !(exp_connect_flags2(exp) & OBD_CONNECT2_LSOM))
 		op_data->op_xvalid &= ~(OP_XVALID_LAZYSIZE |
 					OP_XVALID_LAZYBLOCKS);
 
@@ -2842,6 +2843,7 @@ int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 		goto err_osc_cleanup;
 
 	obd->u.cli.cl_dom_min_inline_repsize = MDC_DOM_DEF_INLINE_REPSIZE;
+	obd->u.cli.cl_lsom_update = true;
 
 	ns_register_cancel(obd->obd_namespace, mdc_cancel_weight);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
