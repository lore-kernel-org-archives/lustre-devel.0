From: kbuild test robot <lkp@intel.com>
Date: Thu, 21 Dec 2017 17:40:52 +0800
Subject: [lustre-devel] [PATCH 03/15] staging: lustre: replace simple
 cases of LIBCFS_ALLOC with kzalloc.
In-Reply-To: <151355799030.6200.8100283223734974485.stgit@noble>
References: <151355799030.6200.8100283223734974485.stgit@noble>
Message-ID: <201712211744.mY2ILpU6%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi NeilBrown,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on staging/staging-testing]
[also build test WARNING on next-20171221]
[cannot apply to v4.15-rc4]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/NeilBrown/staging-lustre-convert-most-LIBCFS-ALLOC-to-k-malloc/20171220-113029


coccinelle warnings: (new ones prefixed by >>)

>> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c:886:2-7: WARNING: NULL check before freeing functions like kfree, debugfs_remove, debugfs_remove_recursive or usb_free_urb is not needed. Maybe consider reorganizing relevant code to avoid passing NULL values.

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
