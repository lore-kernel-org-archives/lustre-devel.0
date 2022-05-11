Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8E0E6C433FE
	for <lustre-devel@archiver.kernel.org>; Wed, 11 May 2022 19:39:04 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B15DE21C990;
	Wed, 11 May 2022 12:39:01 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 60470216163
 for <lustre-devel@lists.lustre.org>; Wed, 11 May 2022 12:38:48 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 97B88ED6;
 Wed, 11 May 2022 15:38:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8E6E658952; Wed, 11 May 2022 15:38:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>, Sebastien Buisson <sbuisson@ddn.com>
Date: Wed, 11 May 2022 15:38:43 -0400
Message-Id: <1652297923-16141-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1652297923-16141-1-git-send-email-jsimmons@infradead.org>
References: <1652297923-16141-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 5/5] lustre: update version to 2.15.0
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

From: Oleg Drokin <green@whamcloud.com>

New tag 2.15.0

Signed-off-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_ver.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/lustre/lustre_ver.h b/include/uapi/linux/lustre/lustre_ver.h
index 5cba95e..a17edd6 100644
--- a/include/uapi/linux/lustre/lustre_ver.h
+++ b/include/uapi/linux/lustre/lustre_ver.h
@@ -2,10 +2,10 @@
 #define _LUSTRE_VER_H_
 
 #define LUSTRE_MAJOR 2
-#define LUSTRE_MINOR 14
-#define LUSTRE_PATCH 57
+#define LUSTRE_MINOR 15
+#define LUSTRE_PATCH 0
 #define LUSTRE_FIX 0
-#define LUSTRE_VERSION_STRING "2.14.57"
+#define LUSTRE_VERSION_STRING "2.15.0"
 
 #define OBD_OCD_VERSION(major, minor, patch, fix)			\
 	(((major) << 24) + ((minor) << 16) + ((patch) << 8) + (fix))
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
