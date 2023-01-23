Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 046B8C05027
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:09:42 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15JZ3t5yz2169;
	Mon, 23 Jan 2023 15:04:14 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15G41SzCz1yCH
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:02:04 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 3471D6CF;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 3259C58994; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:21 -0500
Message-Id: <1674514855-15399-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/42] lustre: pcc: use two bits to indicate
 pcc type for attach
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Qian Yingjin <qian@ddn.com>

PCC currenty supports two types: readwrite and readonly.
The attach data structure @lu_pcc_attach is using 32 bit value to
indicate the PCC type:
    struct lu_pcc_attach {
        __u32 pcca_type;
        __u32 pcca_id;
    };

In this patch, it changes to use 2 bits to represent the PCC type.
The left bits in @pcca_type can be used as flags for attach such
as a flag to indicate using the asynchronous attach via the
command "lfs pcc attach -A" for PCCRO.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16313
Lustre-commit: 6e90974b1f4ac24c5 ("LU-16313 pcc: use two bits to indicate pcc type for attach")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49160
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Feng Lei <flei@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_user.h | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index e97ccb0635ba..c2096ba1cdbe 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -2324,18 +2324,22 @@ struct lu_heat {
 };
 
 enum lu_pcc_type {
-	LU_PCC_NONE = 0,
-	LU_PCC_READWRITE,
+	LU_PCC_NONE		= 0x0,
+	LU_PCC_READWRITE	= 0x01,
+	LU_PCC_READONLY		= 0x02,
+	LU_PCC_TYPE_MASK	= LU_PCC_READWRITE | LU_PCC_READONLY,
 	LU_PCC_MAX
 };
 
 static inline const char *pcc_type2string(enum lu_pcc_type type)
 {
-	switch (type) {
+	switch (type & LU_PCC_TYPE_MASK) {
 	case LU_PCC_NONE:
 		return "none";
 	case LU_PCC_READWRITE:
 		return "readwrite";
+	case LU_PCC_READONLY:
+		return "readonly";
 	default:
 		return "fault";
 	}
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
