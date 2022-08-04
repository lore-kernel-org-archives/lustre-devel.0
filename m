Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 55A0FC19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:40:11 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4LyryL6J2Gz23Ld;
	Wed,  3 Aug 2022 18:40:10 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4LyrwX54J0z23JV
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:36 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id CD2AC100B005;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id CAE2F8BBFC; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:38:00 -0400
Message-Id: <1659577097-19253-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/32] lustre: llite: dont restart directIO
 with IOCB_NOWAIT
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

It should handle FLR mirror retry and io_uring with IOCB_NOWAIT
flag differently.

int cl_io_loop(const struct lu_env *env, struct cl_io *io)
{
    ...
    if (result == -EAGAIN && io->ci_ndelay) {
        io->ci_need_restart = 1;
        result = 0;
    }
    ...
}

ssize_t
generic_file_read_iter(struct kiocb *iocb, struct iov_iter *iter)
{
    ...
    if (iocb->ki_flags & IOCB_NOWAIT) {
        if (filemap_range_has_page(mapping, iocb->ki_pos,
                                   iocb->ki_pos +
                                   count - 1))
                return -EAGAIN;
    ...
    }

In current code, it will restart I/O engine for read when get
-EAGAIN code.
However, for io_uring direct IO with IOCB_NOWAIT, if found that
there are cache pages in the current I/O range, it should return
-EAGAIN to the upper layer immediately. Otherwise, it will stuck
in an endless loop.

This patch also adds a tool "io_uring_probe" to check whether
the kernel supports io_uring fully.
The reason adding this check is because the rhel8.5 kernel has
backported io_uring:
cat /proc/kallsyms |grep io_uring
ffffffffa8510e10 W __x64_sys_io_uring_enter
ffffffffa8510e10 W __x64_sys_io_uring_register
ffffffffa8510e10 W __x64_sys_io_uring_setup
but the io_uring syscalls return -ENOSYS.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15399
Lustre-commit: 8db455c77265063a1 ("LU-15399 llite: dont restart directIO with IOCB_NOWAIT")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/46147
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h | 6 +++++-
 fs/lustre/llite/file.c        | 6 ++++++
 fs/lustre/obdclass/cl_io.c    | 2 +-
 3 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index c66e98c5..c717d03 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1960,7 +1960,11 @@ struct cl_io {
 	/**
 	 * Bypass quota check
 	 */
-	unsigned int		ci_noquota:1;
+	unsigned int		ci_noquota:1,
+	/**
+	 * io_uring direct IO with flags IOCB_NOWAIT.
+	 */
+				ci_iocb_nowait:1;
 	/**
 	 * How many times the read has retried before this one.
 	 * Set by the top level and consumed by the LOV.
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 0e71b3a..3aace07 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1587,6 +1587,12 @@ void ll_io_init(struct cl_io *io, const struct file *file, int write,
 					   IOCB_DSYNC));
 	}
 
+#ifdef IOCB_NOWAIT
+	io->ci_iocb_nowait = !!(args &&
+				(args->u.normal.via_iocb->ki_flags &
+				 IOCB_NOWAIT));
+#endif
+
 	io->ci_obj = ll_i2info(inode)->lli_clob;
 	io->ci_lockreq = CILR_MAYBE;
 	if (ll_file_nolock(file)) {
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index 4246e17..c388700 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -776,7 +776,7 @@ int cl_io_loop(const struct lu_env *env, struct cl_io *io)
 	if (rc && !result)
 		result = rc;
 
-	if (result == -EAGAIN && io->ci_ndelay) {
+	if (result == -EAGAIN && io->ci_ndelay && !io->ci_iocb_nowait) {
 		io->ci_need_restart = 1;
 		result = 0;
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
