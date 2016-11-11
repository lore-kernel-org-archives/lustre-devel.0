From: kbuild test robot <lkp@intel.com>
Date: Fri, 11 Nov 2016 12:35:29 +0800
Subject: [lustre-devel] [PATCH 05/35] staging: lustre: llog: fix wrong
 offset in llog_process_thread()
In-Reply-To: <1478799065-24841-6-git-send-email-jsimmons@infradead.org>
Message-ID: <201611111201.gguisz8v%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Mikhail,

[auto build test ERROR on staging/staging-testing]
[also build test ERROR on next-20161110]
[cannot apply to v4.9-rc4]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/James-Simmons/second-batch-of-missing-lustre-2-8-patches/20161111-021225
config: m68k-allmodconfig (attached as .config)
compiler: m68k-linux-gcc (GCC) 4.9.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=m68k 

All errors (new ones prefixed by >>):

>> ERROR: "__umoddi3" [drivers/staging/lustre/lustre/obdclass/obdclass.ko] undefined!

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/gzip
Size: 38321 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20161111/4b38ba54/attachment-0001.bin>
