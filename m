Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC06BC43470
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:57 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 95593610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95593610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B693D32CD76;
	Wed, 14 Apr 2021 21:04:24 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 050AF32F67A
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:57 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id AD5EF100F364;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id ABF0C9188F; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:27 -0400
Message-Id: <1618459361-17909-36-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 35/49] lustre: obdclass: Protect
 cl_env_percpu[]
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

From: Etienne AUJAMES <eaujames@ddn.com>

cl_env_percpu is not protected against multi client mounts on the
same node: "keys_fill" could be called with the same cl_env_percpu
context by several mount processes (race on lu_context.lc_value).

This patch add a mutex for cl_env_percpu to proctect contexts
"refill".

WC-bug-id: https://jira.whamcloud.com/browse/LU-14110
Lustre-commit: 881551fbb733569 ("LU-14110 obdclass: Protect cl_env_percpu[]")
Signed-off-by: Etienne AUJAMES <eaujames@ddn.com>
Reviewed-on: https://review.whamcloud.com/40565
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h | 1 +
 fs/lustre/llite/llite_lib.c     | 2 ++
 fs/lustre/obdclass/cl_object.c  | 3 +++
 3 files changed, 6 insertions(+)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index b2f97f1..027667f 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -477,6 +477,7 @@
 #define OBD_FAIL_LLITE_PCC_ATTACH_PAUSE			0x1414
 #define OBD_FAIL_LLITE_SHORT_COMMIT			0x1415
 #define OBD_FAIL_LLITE_CREATE_FILE_PAUSE2		0x1416
+#define OBD_FAIL_LLITE_RACE_MOUNT			0x1417
 
 #define OBD_FAIL_FID_INDIR				0x1501
 #define OBD_FAIL_FID_INLMA				0x1502
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index e15962e..2f2d9f0 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1047,6 +1047,8 @@ int ll_fill_super(struct super_block *sb)
 
 	CDEBUG(D_VFSTRACE, "VFS Op: sb %p\n", sb);
 
+	OBD_RACE(OBD_FAIL_LLITE_RACE_MOUNT);
+
 	cfg = kzalloc(sizeof(*cfg), GFP_NOFS);
 	if (!cfg) {
 		err = -ENOMEM;
diff --git a/fs/lustre/obdclass/cl_object.c b/fs/lustre/obdclass/cl_object.c
index 86434f1..aa3d928 100644
--- a/fs/lustre/obdclass/cl_object.c
+++ b/fs/lustre/obdclass/cl_object.c
@@ -823,6 +823,7 @@ void cl_lvb2attr(struct cl_attr *attr, const struct ost_lvb *lvb)
 EXPORT_SYMBOL(cl_lvb2attr);
 
 static struct cl_env cl_env_percpu[NR_CPUS];
+static DEFINE_MUTEX(cl_env_percpu_mutex);
 
 static int cl_env_percpu_init(void)
 {
@@ -888,8 +889,10 @@ static void cl_env_percpu_refill(void)
 {
 	int i;
 
+	mutex_lock(&cl_env_percpu_mutex);
 	for_each_possible_cpu(i)
 		lu_env_refill(&cl_env_percpu[i].ce_lu);
+	mutex_unlock(&cl_env_percpu_mutex);
 }
 
 void cl_env_percpu_put(struct lu_env *env)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
