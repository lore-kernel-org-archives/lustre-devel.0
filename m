From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:16 -0500
Subject: [lustre-devel] [PATCH v2 33/84] staging/lustre: S_DIRSYNC is always
	defined in kernel
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-34-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

No need to check for it.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index b5f8453..ad77d33 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2013,9 +2013,7 @@ static inline int ll_ext_to_inode_flags(int flags)
 	return (((flags & LUSTRE_SYNC_FL)      ? S_SYNC      : 0) |
 		((flags & LUSTRE_NOATIME_FL)   ? S_NOATIME   : 0) |
 		((flags & LUSTRE_APPEND_FL)    ? S_APPEND    : 0) |
-#if defined(S_DIRSYNC)
 		((flags & LUSTRE_DIRSYNC_FL)   ? S_DIRSYNC   : 0) |
-#endif
 		((flags & LUSTRE_IMMUTABLE_FL) ? S_IMMUTABLE : 0));
 }
 
@@ -2024,9 +2022,7 @@ static inline int ll_inode_to_ext_flags(int iflags)
 	return (((iflags & S_SYNC)      ? LUSTRE_SYNC_FL      : 0) |
 		((iflags & S_NOATIME)   ? LUSTRE_NOATIME_FL   : 0) |
 		((iflags & S_APPEND)    ? LUSTRE_APPEND_FL    : 0) |
-#if defined(S_DIRSYNC)
 		((iflags & S_DIRSYNC)   ? LUSTRE_DIRSYNC_FL   : 0) |
-#endif
 		((iflags & S_IMMUTABLE) ? LUSTRE_IMMUTABLE_FL : 0));
 }
 
-- 
2.1.0
