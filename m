Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 181BEC02199
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:37:16 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWwH5B7vz1y56;
	Fri, 07 Feb 2025 16:30:55 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWw55VNjz1xTv
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:45 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm2-e204-208.ccs.ornl.gov [160.91.203.3])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 160E418232E;
 Fri,  7 Feb 2025 19:30:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 13D3B106BE16; Fri,  7 Feb 2025 19:30:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:19 -0500
Message-ID: <20250208003027.180076-14-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250208003027.180076-1-jsimmons@infradead.org>
References: <20250208003027.180076-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 13/21] lustre: llite: make lsm_sem nested for
 ll_update_dir_depth
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
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Lai Siyao <lai.siyao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Lockdep is reporting:

chmod/16751 is trying to acquire lock:
 (&lli->lli_lsm_sem){++++}-{3:3}, at: ll_update_dir_depth+0x8b/0x280

but task is already holding lock:
 (&lli->lli_lsm_sem){++++}-{3:3}, at: ll_update_dir_depth+0x7b/0x280

other info that might help us debug this:
Possible unsafe locking scenario:

       CPU0
       ----
lock(&lli->lli_lsm_sem);
lock(&lli->lli_lsm_sem);

*** DEADLOCK ***

May be due to missing lock nesting notation

Lockdep sees acquiring more than one lock of the same lock class
as a potential dead lock. The execption is if the locks are used
for objects that belong to a hierarchy. For our case of the
lsm_sem we do have a hierarchy since a lsm for a child directory
is related to the parent directory lsm that is being protected
as well. Create new lock classes for the lsm_sem with proper
ordering.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16807
Lustre-commit: fe44198b7fb710fce ("LU-16807 llite: make lsm_sem nested for ll_update_dir_depth")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51192
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
---
 fs/lustre/llite/llite_lib.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index afb231ecd70b..99b2982fa322 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2832,6 +2832,11 @@ int ll_dir_default_lmv_inherit(struct inode *dir, struct inode *inode)
 	return rc;
 }
 
+enum lsm_sem_class {
+	LSM_SEM_PARENT,
+	LSM_SEM_CHILD,
+};
+
 /**
  * Update directory depth and default LMV
  *
@@ -2858,8 +2863,8 @@ void ll_update_dir_depth_dmv(struct inode *dir, struct dentry *de)
 	lli->lli_dir_depth = plli->lli_dir_depth + 1;
 	if (lli->lli_default_lsm_md && lli->lli_default_lmv_set) {
 		if (plli->lli_default_lsm_md) {
-			down_read(&plli->lli_lsm_sem);
-			down_read(&lli->lli_lsm_sem);
+			down_read_nested(&plli->lli_lsm_sem, LSM_SEM_PARENT);
+			down_read_nested(&lli->lli_lsm_sem, LSM_SEM_CHILD);
 			if (lsm_md_inherited(plli->lli_default_lsm_md,
 					     lli->lli_default_lsm_md))
 				lli->lli_inherit_depth =
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
