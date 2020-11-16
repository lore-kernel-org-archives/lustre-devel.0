From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:45 -0500
Subject: [lustre-devel] [PATCH 12/28] lustre: mdc: remote object support
 getattr from cache
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

For historical reason, IT_GETATTR lock revalidate matches
LOOKUP|UPDATE|PERM lock bits because for MDS < 2.4, permission is
protected by LOOKUP lock, but this will cause remote object not
able to match the cached lock because LOOKUP and UPDATE lock are
fetched separately.

Add sanity 803b, and rename 803 to 803a.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13437
Lustre-commit: 72a1ca996e3a35 ("LU-13437 mdc: remote object support getattr from cache")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40218
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_locks.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 72ee070..a82e8ca 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -1235,7 +1235,6 @@ int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 			 * by LOOKUP lock, so it needs to match all bits here.
 			 */
 			policy.l_inodebits.bits = MDS_INODELOCK_UPDATE |
-						  MDS_INODELOCK_LOOKUP |
 						  MDS_INODELOCK_PERM;
 			break;
 		case IT_READDIR:
-- 
1.8.3.1
