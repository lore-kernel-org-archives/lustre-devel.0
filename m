Return-Path: <SRS0=0agL=O7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFE7BC433F5
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:28 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AC92360E78
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org AC92360E78
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D3393380F92;
	Mon, 11 Oct 2021 10:41:13 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 952CB380AE8
 for <lustre-devel@lists.lustre.org>; Mon, 11 Oct 2021 10:40:58 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id D5831481;
 Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D4001A9502; Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 11 Oct 2021 13:40:48 -0400
Message-Id: <1633974049-26490-20-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
References: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 19/20] lustre: mdc: update max_easize on
 reconnect
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
Cc: Sergey Cheremencev <sergey.cheremencev@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Sergey Cheremencev <sergey.cheremencev@hpe.com>

If MDS was restarted to enable ea_inode, clients should get new
max_easize value. However, cl_max_mds_easize is not updated. This may
cause lfs getstripe to fail if file has huge stripe number
(2000 for example):

*** Error in `lfs': free(): invalid pointer: 0x0000000000de09d0 ***
======= Backtrace: =========
/lib64/libc.so.6(+0x81299)[0x7f0623c03299]
/lib64/libc.so.6(closedir+0xd)[0x7f0623c42ddd]
/lib/liblustreapi.so.1(+0xa557)[0x7f06248b5557]
/lib/liblustreapi.so.1(+0xad74)[0x7f06248b5d74]
lfs[0x4105b3]
/lib/liblustreapi.so.1(Parser_execarg+0x51)[0x7f06248c88e1]
lfs[0x40448e]
/lib64/libc.so.6(__libc_start_main+0xf5)[0x7f0623ba4555]
lfs[0x4044fc]

HPE-bug-id: LUS-9478
WC-bug-id: https://jira.whamcloud.com/browse/LU-15040
Lustre-commit: 5f15be0edea5c2d31 ("LU-15040 mdc: update max_easize on reconnect")
Reviewed-on: https://es-gerrit.dev.cray.com/158100
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Nikitas Angelinas <nangelinas@cray.com>
Tested-by: Elena Gryaznova <c17455@cray.com>
Signed-off-by: Sergey Cheremencev <sergey.cheremencev@hpe.com>
Reviewed-on: https://review.whamcloud.com/45073
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_request.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 8b94f6c..626f493 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -2720,6 +2720,7 @@ static int mdc_import_event(struct obd_device *obd, struct obd_import *imp,
 		if (OCD_HAS_FLAG(ocd, GRANT))
 			osc_init_grant(cli, ocd);
 
+		md_init_ea_size(obd->obd_self_export, ocd->ocd_max_easize, 0);
 		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_OCD);
 		break;
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
