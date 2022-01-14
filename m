Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 18E15C433EF
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:39:14 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id F18223AD7F0;
	Thu, 13 Jan 2022 17:38:48 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 94AEA3AD861
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:11 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E2AF2100F338;
 Thu, 13 Jan 2022 20:38:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E13ADA8103; Thu, 13 Jan 2022 20:38:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:37:56 -0500
Message-Id: <1642124283-10148-18-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 17/24] lustre: mdc: GET(X)ATTR to READPAGE
 portal
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

From: Andreas Dilger <adilger@whamcloud.com>

Send the MDS_GETATTR and MDS_GETXATTR RPCs to the
MDS_READPAGE_PORTAL instead of the default portal to avoid
deadlocks with other MDS_REINT RPCs that may block all of
the MDS service threads on that portal.

This deadlock occurs with MDS_GETXATTR when selinux is
enabled, because getxattr becomes part of lookup, so it
takes a reference on a lock used for lookup.  However, all
of the MDS service threads on the default portal can be
consumed by threads waiting for that lock, resulting in
a deadlock when the getxattr can't be processed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15245
Lustre-commit: 5552eba1451d47ce1 ("LU-15245 mdc: GET(X)ATTR to READPAGE portal")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45593
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_request.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 3284c01..1064d9f 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -224,6 +224,9 @@ static int mdc_getattr(struct obd_export *exp, struct md_op_data *op_data,
 		return rc;
 	}
 
+	/* LU-15245: avoid deadlock with modifying RPCs on MDS_REQUEST_PORTAL */
+	req->rq_request_portal = MDS_READPAGE_PORTAL;
+
 again:
 	mdc_pack_body(&req->rq_pill, &op_data->op_fid1, op_data->op_valid,
 		      op_data->op_mode, -1, 0);
@@ -402,6 +405,10 @@ static int mdc_xattr_common(struct obd_export *exp,
 	} else {
 		mdc_pack_body(&req->rq_pill, fid, valid, output_size,
 			      suppgid, flags);
+		/* Avoid deadlock with modifying RPCs on MDS_REQUEST_PORTAL.
+		 * See LU-15245.
+		 */
+		req->rq_request_portal = MDS_READPAGE_PORTAL;
 	}
 
 	if (xattr_name) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
