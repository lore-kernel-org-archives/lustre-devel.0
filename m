Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 7934EC36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:07:20 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2m5342Dz1xSF;
	Fri, 21 Mar 2025 06:07:17 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2m34lJgz1whP
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:07:15 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm5-e204-208.ccs.ornl.gov [160.91.203.29])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 521DE17D1C2;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 4D1F7106BE16; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:06:44 -0400
Message-ID: <20250321130711.3257092-2-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 01/27] lustre: misc: cleanup #ifdef
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

With the porting of patches from the OpenSFS branch some if the
build conditionals have leaked in. This patch removes them.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h |  6 ------
 fs/lustre/obdclass/jobid.c       |  2 --
 fs/lustre/ptlrpc/wiretest.c      |  6 ------
 net/lnet/selftest/conctl.c       | 19 -------------------
 4 files changed, 33 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 746ef983edb8..ddcd88ed948d 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -536,19 +536,13 @@ static inline void obd_connect_set_name_enc(struct obd_connect_data *data)
 
 static inline bool obd_connect_has_enc_fid2path(struct obd_connect_data *data)
 {
-#ifdef HAVE_LUSTRE_CRYPTO
 	return data->ocd_connect_flags & OBD_CONNECT_FLAGS2 &&
 		data->ocd_connect_flags2 & OBD_CONNECT2_ENCRYPT_FID2PATH;
-#else
-	return false;
-#endif
 }
 
 static inline void obd_connect_set_enc_fid2path(struct obd_connect_data *data)
 {
-#ifdef HAVE_LUSTRE_CRYPTO
 	data->ocd_connect_flags2 |= OBD_CONNECT2_ENCRYPT_FID2PATH;
-#endif
 }
 
 /*
diff --git a/fs/lustre/obdclass/jobid.c b/fs/lustre/obdclass/jobid.c
index 77ea5b26bdf6..1ade7218131b 100644
--- a/fs/lustre/obdclass/jobid.c
+++ b/fs/lustre/obdclass/jobid.c
@@ -34,9 +34,7 @@
 #define DEBUG_SUBSYSTEM S_RPC
 #include <linux/ctype.h>
 #include <linux/user_namespace.h>
-#ifdef HAVE_UIDGID_HEADER
 #include <linux/uidgid.h>
-#endif
 #include <linux/utsname.h>
 
 #include <obd_support.h>
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index cc81d4d6717d..b3135d4a7990 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -4656,14 +4656,8 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct hsm_request, hr_data_len));
 	LASSERTF((int)sizeof(((struct hsm_request *)0)->hr_data_len) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct hsm_request *)0)->hr_data_len));
-#ifdef HAVE_SERVER_SUPPORT
-	LASSERTF(HSM_FORCE_ACTION == 0x00000001UL, "found 0x%.8xUL\n",
-		 (unsigned int)HSM_FORCE_ACTION);
-	LASSERTF(HSM_GHOST_COPY == 0x00000002UL, "found 0x%.8xUL\n",
-		 (unsigned int)HSM_GHOST_COPY);
 
 	/* Checks for struct hsm_user_request */
-#endif
 	LASSERTF((int)sizeof(struct hsm_user_request) == 24, "found %lld\n",
 		 (long long)(int)sizeof(struct hsm_user_request));
 	LASSERTF((int)offsetof(struct hsm_user_request, hur_request) == 0, "found %lld\n",
diff --git a/net/lnet/selftest/conctl.c b/net/lnet/selftest/conctl.c
index a7ec0d54fe02..f79368448d3e 100644
--- a/net/lnet/selftest/conctl.c
+++ b/net/lnet/selftest/conctl.c
@@ -1230,21 +1230,6 @@ static int lst_groups_show_dump(struct sk_buff *msg,
 	return rc;
 }
 
-#ifndef HAVE_NETLINK_CALLBACK_START
-static int lst_old_groups_show_dump(struct sk_buff *msg,
-				    struct netlink_callback *cb)
-{
-	if (!cb->args[0]) {
-		int rc = lst_groups_show_start(cb);
-
-		if (rc < 0)
-			return rc;
-	}
-
-	return lst_groups_show_dump(msg, cb);
-}
-#endif
-
 static const struct genl_multicast_group lst_mcast_grps[] = {
 	{ .name = "sessions",		},
 	{ .name	= "groups",		},
@@ -1258,12 +1243,8 @@ static const struct genl_ops lst_genl_ops[] = {
 	},
 	{
 		.cmd		= LNET_SELFTEST_CMD_GROUPS,
-#ifdef HAVE_NETLINK_CALLBACK_START
 		.start		= lst_groups_show_start,
 		.dumpit		= lst_groups_show_dump,
-#else
-		.dumpit		= lst_old_groups_show_dump,
-#endif
 		.done		= lst_groups_show_done,
 	},
 };
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
