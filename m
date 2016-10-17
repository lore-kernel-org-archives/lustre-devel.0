From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 18 Oct 2016 00:42:27 +0200
Subject: [lustre-devel] [PATCH 08/28 v2] staging: lustre: restore
	initialization of return code
In-Reply-To: <20161017220903.1746743-2-arnd@arndb.de>
References: <20161017220342.1627073-1-arnd@arndb.de>
	<20161017220903.1746743-2-arnd@arndb.de>
Message-ID: <17588627.UUHMZ6jH1R@wuerfel>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, "John L . Hammond" <john.hammond@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org

A recent rework dropped the initialization of the initialization of the
successful return code in lov_getstripe:

drivers/staging/lustre/lustre/lov/lov_pack.c: In function 'lov_getstripe':
drivers/staging/lustre/lustre/lov/lov_pack.c:426:9: error: 'rc' may be used uninitialized in this function [-Werror=maybe-uninitialized]
drivers/staging/lustre/lustre/lov/lov_pack.c:313:6: note: 'rc' was declared here

This adds it back.

Fixes: e10a431b3fd0 ("staging: lustre: lov: move LSM to LOV layer")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
v2: fix embarrassing incorrect changelog

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
