From: kbuild test robot <lkp@intel.com>
Date: Fri, 22 Jul 2016 22:38:59 +0800
Subject: [lustre-devel] [PATCH 30/58] staging: lustre: create striped
	directory
In-Reply-To: <1469155491-15265-31-git-send-email-jsimmons@infradead.org>
Message-ID: <201607222223.bachI0GU%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

[auto build test ERROR on staging/staging-testing]
[also build test ERROR on next-20160722]
[cannot apply to v4.7-rc7]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/James-Simmons/staging-lustre-bug-fixes-from-lustre-2-5-56-58/20160722-145652
config: i386-allyesconfig (attached as .config)
compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

>> ERROR: "__umoddi3" [drivers/staging/lustre/lustre/lmv/lmv.ko] undefined!

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/octet-stream
Size: 54414 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160722/5feb02b8/attachment-0001.obj>
