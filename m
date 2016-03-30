From: kbuild test robot <lkp@intel.com>
Date: Thu, 31 Mar 2016 07:13:24 +0800
Subject: [lustre-devel] [PATCH 35/43] staging/lustre/llite: Rename
 struct vvp_thread_info to ll_thread_info
In-Reply-To: <1459356495-2794775-36-git-send-email-green@linuxhacker.ru>
Message-ID: <201603310719.xfzw46FQ%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi John,

[auto build test ERROR on staging/staging-testing]
[also build test ERROR on next-20160330]
[cannot apply to v4.6-rc1]
[if your patch is applied to the wrong git tree, please drop us a note to help improving the system]

url:    https://github.com/0day-ci/linux/commits/green-linuxhacker-ru/Lustre-IO-stack-simplifications-and-cleanups/20160331-005957
config: i386-allyesconfig (attached as .config)
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

Note: the linux-review/green-linuxhacker-ru/Lustre-IO-stack-simplifications-and-cleanups/20160331-005957 HEAD efae9a88212df477e27c32926e798ddb69dc96eb builds fine.
      It only hurts bisectibility.

All errors (new ones prefixed by >>):

>> drivers/staging/lustre/lustre/llite/vvp_dev.c:87:17: error: 'vvp_thread_kmem' undeclared here (not in a function)
      .ckd_cache = &vvp_thread_kmem,
                    ^
>> drivers/staging/lustre/lustre/llite/vvp_dev.c:89:23: error: invalid application of 'sizeof' to incomplete type 'struct vvp_thread_info'
      .ckd_size  = sizeof(struct vvp_thread_info),
                          ^

vim +/vvp_thread_kmem +87 drivers/staging/lustre/lustre/llite/vvp_dev.c

89e894356 John L. Hammond 2016-03-30  81  	{
1cca6dab1 John L. Hammond 2016-03-30  82  		.ckd_cache = &vvp_req_kmem,
1cca6dab1 John L. Hammond 2016-03-30  83  		.ckd_name  = "vvp_req_kmem",
1cca6dab1 John L. Hammond 2016-03-30  84  		.ckd_size  = sizeof(struct vvp_req),
1cca6dab1 John L. Hammond 2016-03-30  85  	},
1cca6dab1 John L. Hammond 2016-03-30  86  	{
d7e09d039 Peng Tao        2013-05-02 @87  		.ckd_cache = &vvp_thread_kmem,
d7e09d039 Peng Tao        2013-05-02  88  		.ckd_name  = "vvp_thread_kmem",
d7e09d039 Peng Tao        2013-05-02 @89  		.ckd_size  = sizeof(struct vvp_thread_info),
d7e09d039 Peng Tao        2013-05-02  90  	},
d7e09d039 Peng Tao        2013-05-02  91  	{
d7e09d039 Peng Tao        2013-05-02  92  		.ckd_cache = &vvp_session_kmem,

:::::: The code at line 87 was first introduced by commit
:::::: d7e09d0397e84eefbabfd9cb353221f3c6448d83 staging: add Lustre file system client support

:::::: TO: Peng Tao <bergwolf@gmail.com>
:::::: CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/octet-stream
Size: 53766 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160331/682ea5ea/attachment-0001.obj>
