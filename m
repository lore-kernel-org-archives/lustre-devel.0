Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 58AB3C433FE
	for <lustre-devel@archiver.kernel.org>; Sun, 12 Dec 2021 15:08:13 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DDB1921F493;
	Sun, 12 Dec 2021 07:08:10 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C64E521CBC4
 for <lustre-devel@lists.lustre.org>; Sun, 12 Dec 2021 07:08:06 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B139810084B2;
 Sun, 12 Dec 2021 10:08:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A3389E07E3; Sun, 12 Dec 2021 10:08:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 12 Dec 2021 10:07:52 -0500
Message-Id: <1639321683-22909-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
References: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/12] lustre: llite: do not take mod rpc
 slot for getxattr
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
Cc: Vladimir Saveliev <vlaidimir.saveliev@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Vladimir Saveliev <vlaidimir.saveliev@hpe.com>

The following scenario may lead to client eviction:
clientA                clientB                  MDS
threadA1: write to file F1, get
and hold DoM MDC LDLM lock L1:
   ->cl_io_loop()
    ->cl_io_lock()
     :
     ->mdc_lock_granted()
      ->lock->l_writers++
     [hold ref until write done]

threadA2-A8: create files F2-F8:
   ->ll_file_open()
    ->mdc_enqueue_base()
     ->ldlm_cli_enqueue()
      ->ptlrpc_get_mod_rpc_slot()
      ->ptlrpc_queue_wait()
      [hold RPC slot until create done]

                                                OST(s) in recovery.
                                                MDS waiting on OST(s) to
                                                precreate new objects.

threadA1:
    -> cl_io_start()
     -> __generic_file_aio_write()
      -> file_remove_suid()
       -> ll_xattr_cache_refill()
        -> mdc_xattr_common()
         -> ptlrpc_get_mod_rpc_slot()
         [blocked waiting for RPC slot]

                        threadB1: write file F1,
                    enqueue DoM MDC lock L1

                                                MDS sends blocking AST
                                                to clientA for lock L1

ldlm_threadA3: cannot cancel busy lock L1:
   -> ldlm_handle_bl_callback()
   ["Lock L1 referenced, will be cancelled later"]

                                                MDS evicts clientA for
                                                not cancelling lock L1

threadA1: never completes write:
  ->cl_io_end()
   ->cl_io_unlock()
    ->osc_lock_cancel()
     ->lock->l_writers--;

The fix is to add IT_GETXATTR to list of operations which do not
need mod rpc slot.

Tests to illustrate the issue is added.

wait_for_function(): total sleep time (wait) is to be equal to max
when 1 is returned.

HPE-bug-id: LUS-7271
WC-bug-id: https://jira.whamcloud.com/browse/LU-12347
Lustre-commit: eb64594e4473af85 ("LU-12347 llite: do not take mod rpc slot for getxattr")
Signed-off-by: Vladimir Saveliev <vlaidimir.saveliev@hpe.com>
Reviewed-on: https://review.whamcloud.com/44151
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Andrew Perepechko <andrew.perepechko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h | 1 +
 fs/lustre/llite/xattr_cache.c   | 2 ++
 fs/lustre/mdc/mdc_locks.c       | 2 +-
 3 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 540e1e0..d57c25c 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -484,6 +484,7 @@
 #define OBD_FAIL_LLITE_RACE_MOUNT			0x1417
 #define OBD_FAIL_LLITE_PAGE_ALLOC			0x1418
 #define OBD_FAIL_LLITE_OPEN_DELAY			0x1419
+#define OBD_FAIL_LLITE_XATTR_PAUSE			0x1420
 
 #define OBD_FAIL_FID_INDIR				0x1501
 #define OBD_FAIL_FID_INLMA				0x1502
diff --git a/fs/lustre/llite/xattr_cache.c b/fs/lustre/llite/xattr_cache.c
index b044c89..7c1f5b7 100644
--- a/fs/lustre/llite/xattr_cache.c
+++ b/fs/lustre/llite/xattr_cache.c
@@ -396,6 +396,8 @@ static int ll_xattr_cache_refill(struct inode *inode)
 	u32 *xsizes;
 	int rc, i;
 
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LLITE_XATTR_PAUSE, cfs_fail_val ?: 2);
+
 	rc = ll_xattr_find_get_lock(inode, &oit, &req);
 	if (rc)
 		goto err_req;
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 66f0039..2c344d7 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -886,7 +886,7 @@ static inline bool mdc_skip_mod_rpc_slot(const struct lookup_intent *it)
 {
 	if (it &&
 	    (it->it_op == IT_GETATTR || it->it_op == IT_LOOKUP ||
-	     it->it_op == IT_READDIR ||
+	     it->it_op == IT_READDIR || it->it_op == IT_GETXATTR ||
 	     (it->it_op == IT_LAYOUT && !(it->it_flags & MDS_FMODE_WRITE))))
 		return true;
 	return false;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
