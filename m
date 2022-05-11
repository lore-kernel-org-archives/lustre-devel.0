Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 98362C433F5
	for <lustre-devel@archiver.kernel.org>; Wed, 11 May 2022 19:38:53 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7914B21C93B;
	Wed, 11 May 2022 12:38:51 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8C37C216163
 for <lustre-devel@lists.lustre.org>; Wed, 11 May 2022 12:38:47 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 884C8ED3;
 Wed, 11 May 2022 15:38:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7C6AF5894B; Wed, 11 May 2022 15:38:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>, Sebastien Buisson <sbuisson@ddn.com>
Date: Wed, 11 May 2022 15:38:39 -0400
Message-Id: <1652297923-16141-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1652297923-16141-1-git-send-email-jsimmons@infradead.org>
References: <1652297923-16141-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 1/5] lustre: uapi: fallocate interop for 2.14
 clients
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
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Arshad Hussain <arshad.hussain@aeoncomputing.com>

fallocate() start and end are passed in o_size and o_blocks
on the wire.  Clients 2.15.0 and newer should always set
the OBD_MD_FLSIZE and OBD_MD_FLBLOCKS valid flags, but some
older client versions did not.  We permit older clients to
not set these flags, checking their version by proxy using
the missing OBD_CONNECT_TRUNCLOCK to imply 2.14.0 or older.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15748
Lustre-commit: 79053592966792a21 ("LU-15748 osc: fallocate interop for 2.14 clients")
Signed-off-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-on: https://review.whamcloud.com/47098
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_idl.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 753df16..37db3ee 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -691,6 +691,9 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT_ACL			 0x80ULL /*access control lists */
 #define OBD_CONNECT_XATTR		0x100ULL /*client use extended attr */
 #define OBD_CONNECT_LARGE_ACL		0x200ULL /* more than 32 ACL entries */
+/* was OBD_CONNECT_TRUNCLOCK		0x400ULL *locks on server for punch */
+/* temporary reuse until 2.21.53 to indicate pre-2.15 client, see LU-15478 */
+#define OBD_CONNECT_OLD_FALLOC		0x400ULL /* missing o_valid flags */
 #define OBD_CONNECT_TRANSNO		0x800ULL /*replay sends init transno */
 #define OBD_CONNECT_IBITS	       0x1000ULL /* not checked in 2.11+ */
 #define OBD_CONNECT_BARRIER	       0x2000ULL /* write barrier. Resevered to
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
