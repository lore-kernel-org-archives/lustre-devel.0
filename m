From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:21 -0400
Subject: [lustre-devel] [PATCH 44/45] lustre: dne: improve temp file name
 check
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-45-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Previously if all but two characters in file name suffix are digit,
it's not treated as temp file, as is too strict if suffix length is
short, e.g. 6. Change it to allow one character, and this non-digit
character should not be the starting character.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13481
Lustre-commit: 51e5749683838 ("LU-13481 dne: improve temp file name check")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38539
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 718fdb8..6886177 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1309,7 +1309,8 @@ static inline bool lu_name_is_temp_file(const char *name, int namelen,
 	 * About 0.07% of randomly-generated names will slip through,
 	 * but this avoids 99.93% of cross-MDT renames for those files.
 	 */
-	if (digit >= suffixlen - 2 || upper == suffixlen || lower == suffixlen)
+	if ((digit >= suffixlen - 1 && !isdigit(name[namelen - suffixlen])) ||
+	    upper == suffixlen || lower == suffixlen)
 		return false;
 
 	return true;
-- 
1.8.3.1
