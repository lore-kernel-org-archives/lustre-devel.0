From: Oleg Drokin <green@linuxhacker.ru>
Date: Tue, 14 Jun 2016 20:44:17 -0400
Subject: [lustre-devel] [PATCH 4/5] staging/lustre: Remove stray line from
	selftest/selftest.h
In-Reply-To: <1465951458-847547-1-git-send-email-green@linuxhacker.ru>
References: <1465951458-847547-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1465951458-847547-5-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

The 'copy of GPLv2]' is an ending from template that's no longer needed,
so remove it to avoid any extra confusion.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lnet/selftest/selftest.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 8f47082..b10fce6 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -16,7 +16,6 @@
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
  * http://http://www.gnu.org/licenses/gpl-2.0.html
- * copy of GPLv2].
  *
  * GPL HEADER END
  */
-- 
2.7.4
