From: Oleg Drokin <green@linuxhacker.ru>
Date: Tue, 14 Jun 2016 20:44:16 -0400
Subject: [lustre-devel] [PATCH 3/5] staging/lustre/lov: Fix gpl URL in
	lov_pool.c
In-Reply-To: <1465951458-847547-1-git-send-email-green@linuxhacker.ru>
References: <1465951458-847547-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1465951458-847547-4-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

There's no longer a matching sun.com URL, so refer to
gnu.org copy.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/lov/lov_pool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 75660c5..4c2d217 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -14,8 +14,8 @@
  * in the LICENSE file that accompanied this code).
  *
  * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see [sun.com URL with a
- * copy of GPLv2].
+ * version 2 along with this program; If not, see
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
-- 
2.7.4
