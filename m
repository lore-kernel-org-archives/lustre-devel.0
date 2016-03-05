From: kbuild test robot <lkp@intel.com>
Date: Sat, 5 Mar 2016 15:53:26 +0800
Subject: [lustre-devel] [PATCH 01/10] staging: lustre: LNet drop rule
	implementation
In-Reply-To: <1457143790-19422-2-git-send-email-jsimmons@infradead.org>
Message-ID: <201603051532.2s0oJWa5%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Liang,

[auto build test ERROR on staging/staging-testing]
[also build test ERROR on v4.5-rc6 next-20160304]
[if your patch is applied to the wrong git tree, please drop us a note to help improving the system]

url:    https://github.com/0day-ci/linux/commits/James-Simmons/Last-batch-of-fixes-for-LNet/20160305-101431
config: m68k-allyesconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=m68k 

All errors (new ones prefixed by >>):

>> ERROR: "__umoddi3" [drivers/staging/lustre/lnet/lnet/lnet.ko] undefined!

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/octet-stream
Size: 35803 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160305/5447f5c7/attachment-0001.obj>
