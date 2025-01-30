Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 4DBCEC0218A
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:43:30 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLj84RFSz22B8;
	Thu, 30 Jan 2025 06:18:20 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLdw0t7Xz1xpP
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:15:31 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 3DB18182370;
 Thu, 30 Jan 2025 09:11:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 3C4EE106BE17; Thu, 30 Jan 2025 09:11:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:11:13 -0500
Message-ID: <20250130141115.950749-24-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 23/25] lustre: remove obsolete
 OBD_FAIL_OSC_DIO_PAUSE fail_loc
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

From: Patrick Farrell <pfarrell@whamcloud.com>

The fail_loc used for testing was removed in Lustre 2.0.
The fail_loc tests for a bug which should be obvious - a
serious delay when doing DIO writes - and is definitely
fixed in current versions.  (Bugzilla 15950)

And without the fail_loc, the test isn't doing anything
interesting.  But the timer based aspect of it fails
occasionally due to hardware delays.  So let's just remove
the fail_loc.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13706
lustre-commit: 59d5bb1558b281d75 ("LU-13706 tests: remove test 119d")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50731
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 43b4684f418a..cee7e3164d66 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -327,7 +327,6 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_OSC_BRW_PREP_REQ2			0x40a
 /* #define OBD_FAIL_OSC_CONNECT_CKSUM	 0x40b Obsolete since 2.9 */
 #define OBD_FAIL_OSC_CKSUM_ADLER_ONLY			0x40c
-#define OBD_FAIL_OSC_DIO_PAUSE				0x40d
 #define OBD_FAIL_OSC_OBJECT_CONTENTION			0x40e
 #define OBD_FAIL_OSC_CP_CANCEL_RACE			0x40f
 #define OBD_FAIL_OSC_CP_ENQ_RACE			0x410
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
