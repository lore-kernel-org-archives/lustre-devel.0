Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 80E03C05027
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:22:54 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15Nh19DHz1yG2;
	Mon, 23 Jan 2023 15:07:48 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15N93hzlz227F
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:07:21 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 88759A1C;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 84E5758995; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:41 -0500
Message-Id: <1674514855-15399-29-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 28/42] lustre: obdclass: prefer T10 checksum
 if the target supports it
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
Cc: Li Dongyang <dongyangli@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Li Dongyang <dongyangli@ddn.com>

If the target actually has T10PI support, we prefer to use that
T10 checksum even it's not the fastest on the client, given
checksum_type is not explicitly set.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14912
Lustre-commit: 5e9059e08aec6fb36 ("LU-14912 obdclass: prefer T10 checksum if the target supports it")
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/44657
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Tested-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_cksum.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/lustre/include/obd_cksum.h b/fs/lustre/include/obd_cksum.h
index 36443fd5a156..052635d5d5b0 100644
--- a/fs/lustre/include/obd_cksum.h
+++ b/fs/lustre/include/obd_cksum.h
@@ -118,6 +118,13 @@ enum cksum_types obd_cksum_type_select(const char *obd_name,
 	if (preferred & cksum_types)
 		return preferred;
 
+	/*
+	 * Server reporting a single T10 checksum type
+	 * means the target actually supports T10-PI.
+	 */
+	if (hweight32(cksum_types & OBD_CKSUM_T10_ALL) == 1)
+		return cksum_types & OBD_CKSUM_T10_ALL;
+
 	flag = obd_cksum_type_pack(obd_name, cksum_types);
 
 	return obd_cksum_type_unpack(flag);
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
