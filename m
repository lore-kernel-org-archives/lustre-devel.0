From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 13 Mar 2018 14:05:16 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: fid: avoid false-positive
 uninitialized variable warning
Message-ID: <20180313130532.4015402-1-arnd@arndb.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, NeilBrown <neilb@suse.com>, Arnd Bergmann <arnd@arndb.de>, lustre-devel@lists.lustre.org

One of Neil's recent cleanups apparently has led the code to get
to a state where gcc tracks the 'seqnr' variable just enough to
see that it is sometimes initialized in seq_client_alloc_seq(),
but not enough that it can prove this initialization to be reliable
before the use of that variable:

drivers/staging/lustre/lustre/fid/fid_request.c: In function 'seq_client_alloc_fid':
drivers/staging/lustre/lustre/fid/fid_request.c:245:22: error: 'seqnr' may be used uninitialized in this function [-Werror=maybe-uninitialized]

The code seems to be otherwise correct, and I could not come
up with a good way to simplify it further, so this adds a fake
initialization to shut up that warning.

Cc: NeilBrown <neilb@suse.com>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/staging/lustre/lustre/fid/fid_request.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index fa23423eb8b3..030680f37c79 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -174,6 +174,7 @@ static int seq_client_alloc_seq(const struct lu_env *env,
 		if (rc) {
 			CERROR("%s: Can't allocate new meta-sequence, rc %d\n",
 			       seq->lcs_name, rc);
+			*seqnr = U64_MAX;
 			return rc;
 		}
 		CDEBUG(D_INFO, "%s: New range - " DRANGE "\n",
-- 
2.9.0
