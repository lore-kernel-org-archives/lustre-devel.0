From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Sat, 12 May 2018 08:33:05 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: Fix an error handling path
 in 'client_common_fill_super()'
Message-ID: <20180512063305.7339-1-christophe.jaillet@wanadoo.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, neilb@suse.com, aastha.gupta4104@gmail.com, santhameena13@gmail.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org, Christophe JAILLET <christophe.jaillet@wanadoo.fr>

According to error handling path before and after this one, we should go
to 'out_md_fid' here, instead of 'out_md', if 'obd_connect()' fails.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
The last goto 'out_lock_cn_cb' looks spurious but is correct.
In case of error, 'd_make_root()' performs a 'iput()', so skipping it in
the error handling path lokks fine to me.
---
 drivers/staging/lustre/lustre/llite/llite_lib.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 60dbe888e336..83eb2da2c9ad 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -400,11 +400,11 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 		LCONSOLE_ERROR_MSG(0x150,
 				   "An OST (dt %s) is performing recovery, of which this client is not a part.  Please wait for recovery to complete, abort, or time out.\n",
 				   dt);
-		goto out_md;
+		goto out_md_fid;
 	} else if (err) {
 		CERROR("%s: Cannot connect to %s: rc = %d\n",
 		       sbi->ll_dt_exp->exp_obd->obd_name, dt, err);
-		goto out_md;
+		goto out_md_fid;
 	}
 
 	sbi->ll_dt_exp->exp_connect_data = *data;
-- 
2.17.0
