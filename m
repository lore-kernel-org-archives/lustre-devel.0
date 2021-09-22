Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6C46C433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:55 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6FAD9610A1
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 6FAD9610A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8E49F21F280;
	Tue, 21 Sep 2021 19:21:54 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 247A921F238
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:13 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 36E07496;
 Tue, 21 Sep 2021 22:20:09 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 320D4FF4A3; Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:55 -0400
Message-Id: <1632277201-6920-19-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 18/24] lustre: llite: don't touch vma after
 filemap_fault
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
Cc: Alexander Boyko <alexander.boyko@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alexander Boyko <alexander.boyko@hpe.com>

In case of error filemap_fault unlock mutex vma->vm_mm->mmap_sem,
so touching vma is dangerous, it could be reused or freed.
The patch uses local file variable to skip vma.

HPE-bug-id: LUS-10240
WC-bug-id: https://jira.whamcloud.com/browse/LU-14021
Lustre-commit: 0f5d3c4b954da2f6b ("LU-14021 llite: don't touch vma after filemap_fault")
Signed-off-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-on: https://review.whamcloud.com/44558
Reviewed-by: Andrew Perepechko <andrew.perepechko@hpe.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_mmap.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index ebcb8d9..85a082c 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -38,9 +38,9 @@
 #include <linux/unistd.h>
 #include <linux/uaccess.h>
 #include <linux/delay.h>
-
 #include <linux/fs.h>
 #include <linux/pagemap.h>
+#include <linux/file.h>
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
@@ -317,6 +317,8 @@ static vm_fault_t __ll_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 	result = io->ci_result;
 	if (result == 0) {
+		struct file *vm_file = vma->vm_file;
+
 		vio = vvp_env_io(env);
 		vio->u.fault.ft_vma = vma;
 		vio->u.fault.ft_vmpage = NULL;
@@ -324,13 +326,15 @@ static vm_fault_t __ll_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		vio->u.fault.ft_flags = 0;
 		vio->u.fault.ft_flags_valid = false;
 
+		get_file(vm_file);
+
 		/* May call ll_readpage() */
-		ll_cl_add(vma->vm_file, env, io, LCC_MMAP);
+		ll_cl_add(vm_file, env, io, LCC_MMAP);
 
 		result = cl_io_loop(env, io);
 
-		ll_cl_remove(vma->vm_file, env);
-
+		ll_cl_remove(vm_file, env);
+		fput(vm_file);
 		/* ft_flags are only valid if we reached
 		 * the call to filemap_fault
 		 */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
