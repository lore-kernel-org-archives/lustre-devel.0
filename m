Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id D12C9C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:32:35 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id ED30621FB59;
	Sun, 20 Mar 2022 06:31:57 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A02D421F3E8
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:19 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 6ED57EFC;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 6D72AAB; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:51 -0400
Message-Id: <1647783064-20688-38-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 37/50] lustre: osc: add OBD_IOC_GETATTR
 support for osc
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

From: "John L. Hammond" <jhammond@whamcloud.com>

Add a supporting OBD_IOC_GETATTR case to osc_iocontrol().

WC-bug-id: https://jira.whamcloud.com/browse/LU-15452
Lustre-commit: 4143c3bdec2a87319 ("LU-15452 utils: support lctl getattr for osc")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/46131
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index c442819..43cd6c5 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -3222,18 +3222,21 @@ static int osc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 					   data->ioc_inlbuf1, 0);
 		if (rc > 0)
 			rc = 0;
-		goto out;
+		break;
+	case OBD_IOC_GETATTR:
+		rc = obd_getattr(NULL, exp, &data->ioc_obdo1);
+		break;
 	case IOC_OSC_SET_ACTIVE:
 		rc = ptlrpc_set_import_active(obd->u.cli.cl_import,
 					      data->ioc_offset);
-		goto out;
+		break;
 	default:
 		CDEBUG(D_INODE, "%s: unrecognised ioctl %#x by %s\n",
 		       obd->obd_name, cmd, current->comm);
 		rc = -ENOTTY;
-		goto out;
+		break;
 	}
-out:
+
 	module_put(THIS_MODULE);
 	return rc;
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
