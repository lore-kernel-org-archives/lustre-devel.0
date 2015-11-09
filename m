From: kbuild test robot <lkp@intel.com>
Date: Tue, 10 Nov 2015 03:43:50 +0800
Subject: [lustre-devel] [PATCH] staging: lustre: acl: Remove
 lustre_posix_acl_xattr_free wrapper
In-Reply-To: <1447095257-21165-1-git-send-email-shivanib134@gmail.com>
Message-ID: <201511100309.kmJ2bdfD%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Shivani,

[auto build test WARNING on staging/staging-testing]
[also build test WARNING on v4.3 next-20151109]

url:    https://github.com/0day-ci/linux/commits/Shivani-Bhardwaj/staging-lustre-acl-Remove-lustre_posix_acl_xattr_free-wrapper/20151110-025757


coccinelle warnings: (new ones prefixed by >>)

>> drivers/staging/lustre/lustre/llite/xattr.c:199:2-7: WARNING: NULL check before freeing functions like kfree, debugfs_remove, debugfs_remove_recursive or usb_free_urb is not needed. Maybe consider reorganizing relevant code to avoid passing NULL values.

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
