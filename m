From: kbuild test robot <lkp@intel.com>
Date: Mon, 19 Sep 2016 13:43:05 +0800
Subject: [lustre-devel] [PATCH 112/124] staging: lustre: ptlrpc: remove
 unnecessary EXPORT_SYMBOL
In-Reply-To: <1474231143-4061-113-git-send-email-jsimmons@infradead.org>
Message-ID: <201609191359.ws7ROQGM%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi frank,

[auto build test ERROR on staging/staging-testing]
[cannot apply to v4.8-rc7 next-20160916]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
[Suggest to use git(>=2.9.0) format-patch --base=<commit> (or --base=auto for convenience) to record what (public, well-known) commit your patch series was built on]
[Check https://git-scm.com/docs/git-format-patch for more information]

url:    https://github.com/0day-ci/linux/commits/James-Simmons/missing-patches-from-Lustre-2-7-release/20160919-045619
config: s390-allyesconfig (attached as .config)
compiler: s390x-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=s390 

All errors (new ones prefixed by >>):

>> ERROR: "lustre_swab_lov_mds_md" [drivers/staging/lustre/lustre/lov/lov.ko] undefined!
>> ERROR: "lustre_swab_lov_mds_md" [drivers/staging/lustre/lustre/llite/lustre.ko] undefined!

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/gzip
Size: 42434 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160919/b5e693a8/attachment-0001.bin>
