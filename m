From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:35 -0400
Subject: [lustre-devel] [PATCH 016/151] lustre: all: remove all Sun license
 and URL references
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The link to the GPL license at Sun is no longer there.
Also Sun Inc is gone so lets remove all references to
it in our source code.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8648
Lustre-commit: 72057a3af19e ("LU-8648 all: remove all Sun license and URL references")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: http://review.whamcloud.com/22800
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Frank Zago <fzago@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_lmv.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index c4f05d2..5e15c62 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -16,7 +16,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
-- 
1.8.3.1
