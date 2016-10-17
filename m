From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 18 Oct 2016 00:08:55 +0200
Subject: [lustre-devel] [PATCH 08/28] staging: lustre: restore
	initialization of return code
In-Reply-To: <20161017220342.1627073-1-arnd@arndb.de>
References: <20161017220342.1627073-1-arnd@arndb.de>
Message-ID: <20161017220903.1746743-2-arnd@arndb.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, "John L . Hammond" <john.hammond@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org

A recent rework removed the initialization of the successful return
code from lpfc_write_firmware:

drivers/scsi/lpfc/lpfc_init.c: In function 'lpfc_write_firmware':
drivers/scsi/lpfc/lpfc_init.c:10333:214: error: format '%ld' expects argument of type 'long int', but argument 9 has type 'size_t {aka const unsigned int}' [-Werror=format=]

This adds it back.

Fixes: e10a431b3fd0 ("staging: lustre: lov: move LSM to LOV layer")
Cc: John L. Hammond <john.hammond@intel.com>
Cc: Jinshan Xiong <jinshan.xiong@intel.com>
Cc: James Simmons <jsimmons@infradead.org>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/staging/lustre/lustre/lov/lov_pack.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index be6e985..0439f54 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -474,6 +474,8 @@ int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 	((struct lov_user_md *)lmmk)->lmm_stripe_count = lum.lmm_stripe_count;
 	if (copy_to_user(lump, lmmk, lmm_size))
 		rc = -EFAULT;
+	else
+		rc = 0;
 
 out_free:
 	kfree(lmmk);
-- 
2.9.0
