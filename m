From: James Simmons <jsimmons@infradead.org>
Date: Mon, 28 Nov 2016 22:01:37 +0000 (GMT)
Subject: [lustre-devel] Failed to build a Lustre Storage Client on
 OpenVZ Kernel ! Is this a bug?
In-Reply-To: <CAAXb9MsyiG0Suwx2eWGqWZHZt_H6R60FWo8v-PxjR_nWfN0NyQ@mail.gmail.com>
References: <CAAXb9Ms-4+aDuS10g3Y4qbPiJyaP74Fk-Gh+4=7KaTLacvAZRA@mail.gmail.com>
	<alpine.LFD.2.20.1611070202430.21293@casper.infradead.org>
	<CAAXb9Mv81o3RywPWhspEOyrR0QWvtgQHQLJPPyNvi77n-c-M-g@mail.gmail.com>
	<CAAXb9Mvz-i0iCFsVJQ-Jv=F8eQHsxqLWfbK1ZHs3dTJSoMUAXw@mail.gmail.com>
	<CAAXb9MsyiG0Suwx2eWGqWZHZt_H6R60FWo8v-PxjR_nWfN0NyQ@mail.gmail.com>
Message-ID: <alpine.LFD.2.20.1611282200140.1059@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Dear James and?All,
> 
> Zipped file "config.log" is attached,?file in the former is too big (beyond the limit of 150 KB).
> 
> Thanks very much and sorry for the?redundancy!
> 
> Best Wishes!

I was on vacation last week so sorry for the delay. I think I know what 
the problem is. Can you try the attached patch and see if it works.
-------------- next part --------------
diff --git a/lustre/autoconf/lustre-core.m4 b/lustre/autoconf/lustre-core.m4
index 0578325..aac8dbd 100644
--- a/lustre/autoconf/lustre-core.m4
+++ b/lustre/autoconf/lustre-core.m4
@@ -1717,6 +1717,26 @@ vfs_rename_6args, [
 ]) # LC_VFS_RENAME_6ARGS
 
 #
+# LC_IOV_ITER_IOVEC
+#
+# 3.16 introduced iov_iter_iovec
+#
+AC_DEFUN([LC_IOV_ITER_IOVEC], [
+LB_CHECK_COMPILE([if Linux kernel has 'iov_iter_iovec'],
+iov_iter_iovec, [
+	#include <linux/uio.h>
+	#include <linux/fs.h>
+],[
+	struct iovec vec;
+
+	vec = iov_iter_iovec(NULL);
+], [
+	AC_DEFINE(HAVE_IOV_ITER_IOVEC, 1,
+		[kernel has iov_iter_iovec])
+])
+]) # LC_IOV_ITER_IOVEC
+
+#
 # LC_DIRECTIO_USE_ITER
 #
 # 3.16 kernel changes direct IO to use iov_iter
@@ -2356,6 +2376,7 @@ AC_DEFUN([LC_PROG_LINUX], [
 	LC_HAVE_TRUNCATE_IPAGES_FINAL
 
 	# 3.15
+	LC_IOV_ITER_IOVEC
 	LC_VFS_RENAME_6ARGS
 
 	# 3.16
diff --git a/lustre/llite/llite_internal.h b/lustre/llite/llite_internal.h
index 3f7dfed..0e1252b 100644
--- a/lustre/llite/llite_internal.h
+++ b/lustre/llite/llite_internal.h
@@ -1463,6 +1463,7 @@ static inline void iov_iter_reexpand(struct iov_iter *i, size_t count)
 	i->count = count;
 }
 
+#ifndef HAVE_IOV_ITER_IOVEC
 static inline struct iovec iov_iter_iovec(const struct iov_iter *iter)
 {
 	return (struct iovec) {
@@ -1471,6 +1472,7 @@ static inline struct iovec iov_iter_iovec(const struct iov_iter *iter)
 			       iter->iov->iov_len - iter->iov_offset),
 	};
 }
+#endif
 
 #define iov_for_each(iov, iter, start)					\
 	for (iter = (start);						\
