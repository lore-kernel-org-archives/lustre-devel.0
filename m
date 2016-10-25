From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 25 Oct 2016 23:22:31 +0200
Subject: [lustre-devel] [PATCH v2 2/2] staging: lustre: restore
	initialization of return code
In-Reply-To: <20161025212310.2346367-1-arnd@arndb.de>
References: <20161025212310.2346367-1-arnd@arndb.de>
Message-ID: <20161025212310.2346367-2-arnd@arndb.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Patrick Farrell <paf@cray.com>, lustre-devel@lists.lustre.org, Bobi Jam <bobijam@hotmail.com>, James Simmons <uja.ornl@yahoo.com>, Olaf Weber <olaf@sgi.com>, James Simmons <jsimmons@infradead.org>, Jinshan Xiong <jinshan.xiong@intel.com>, "John L . Hammond" <john.hammond@intel.com>, Liang Zhen <liang.zhen@intel.com>, Arnd Bergmann <arnd@arndb.de>, Andreas Dilger <andreas.dilger@intel.com>, Bobi Jam <bobijam.xu@intel.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

A recent rework removed the initialization of the successful return
code from lov_getstripe:

drivers/staging/lustre/lustre/lov/lov_pack.c: In function 'lov_getstripe':
drivers/staging/lustre/lustre/lov/lov_pack.c:426:9: error: 'rc' may be used uninitialized in this function [-Werror=maybe-uninitialized]
drivers/staging/lustre/lustre/lov/lov_pack.c:313:6: note: 'rc' was declared here

This adds it back.

Fixes: e10a431b3fd0 ("staging: lustre: lov: move LSM to LOV layer")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/staging/lustre/lustre/lov/lov_pack.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 17bceadd66f8..ccc1fae35791 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -418,6 +418,8 @@ int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 	((struct lov_user_md *)lmmk)->lmm_stripe_count = lum.lmm_stripe_count;
 	if (copy_to_user(lump, lmmk, lmm_size))
 		rc = -EFAULT;
+	else
+		rc = 0;
 
 out_free:
 	kvfree(lmmk);
-- 
2.9.0
