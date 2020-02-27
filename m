From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:45 -0500
Subject: [lustre-devel] [PATCH 177/622] lustre: obdclass: lu_dirent record
 length missing '0'
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-178-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

In lu_dirent packing, a '0' is appended after name, but it's not
counted in size calcuation, which may cause crash.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11753
Lustre-commit: 77f01308c509 ("LU-11753 obdclass: lu_dirent record length missing '0'")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33865
Reviewed-by: Stephan Thiell <sthiell@stanford.edu>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_idl.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 599fe86..4236a43 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -480,10 +480,11 @@ static inline size_t lu_dirent_calc_size(size_t namelen, __u16 attr)
 	if (attr & LUDA_TYPE) {
 		const size_t align = sizeof(struct luda_type) - 1;
 
-		size = (sizeof(struct lu_dirent) + namelen + align) & ~align;
+		size = (sizeof(struct lu_dirent) + namelen + 1 + align) &
+		       ~align;
 		size += sizeof(struct luda_type);
 	} else {
-		size = sizeof(struct lu_dirent) + namelen;
+		size = sizeof(struct lu_dirent) + namelen + 1;
 	}
 
 	return (size + 7) & ~7;
-- 
1.8.3.1
