From: Patrick Farrell <paf@cray.com>
Date: Mon, 17 Oct 2016 22:23:00 +0000
Subject: [lustre-devel] [PATCH 08/28] staging: lustre:
	restore	initialization of return code
In-Reply-To: <20161017220903.1746743-2-arnd@arndb.de>
References: <20161017220342.1627073-1-arnd@arndb.de>,
	<20161017220903.1746743-2-arnd@arndb.de>
Message-ID: <CY4PR11MB1751050A7C7AF840E94DDE60CBD00@CY4PR11MB1751.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Arnd,


The description and the actual patch don't seem to match up.  Am I missing something?

________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Arnd Bergmann <arnd@arndb.de>
Sent: Monday, October 17, 2016 5:08:55 PM
To: Oleg Drokin
Cc: devel at driverdev.osuosl.org; Arnd Bergmann; Greg Kroah-Hartman; linux-kernel at vger.kernel.org; Linus Torvalds; lustre-devel at lists.lustre.org
Subject: [lustre-devel] [PATCH 08/28] staging: lustre: restore initialization of return code

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
+       else
+               rc = 0;

 out_free:
         kfree(lmmk);
--
2.9.0

_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20161017/de8edd6e/attachment.htm>
