From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:57 -0400
Subject: [lustre-devel] [PATCH 44/80] staging: lustre: Remove static
	declaration in anonymous union
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-45-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "Christopher J. Morrone" <morrone2@llnl.gov>, James Simmons <jsimmons@infradead.org>

From: Christopher J. Morrone <morrone2@llnl.gov>

It is not permitted in C++ to have a static declaration inside
of an anonymous union. The g++ compiler will complaine with an
error like this:

 error: struct ost_id::<anonymous union>::ostid invalid; an
 anonymous union can only have non-static data members [-fpermissive]

This patch changes the code to use an unnamed struct in place of
"struct ostid" inside of the anonymous union. That name declaration
was completely unnecessary anyway, since it was not used anywhere else.

Signed-off-by: Christopher J. Morrone <morrone2@llnl.gov>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4987
Reviewed-on: http://review.whamcloud.com/10176
Reviewed-by: Robert Read <robert.read@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_user.h     |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 4b2553c..59d45de 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -167,7 +167,7 @@ struct lustre_mdt_attrs {
  */
 struct ost_id {
 	union {
-		struct ostid {
+		struct {
 			__u64	oi_id;
 			__u64	oi_seq;
 		} oi;
-- 
1.7.1
