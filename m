From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:39:35 -0400
Subject: [lustre-devel] [PATCH 35/43] staging/lustre/llite: Rename
	struct vvp_thread_info to ll_thread_info
In-Reply-To: <201603310719.xfzw46FQ%fengguang.wu@intel.com>
References: <201603310719.xfzw46FQ%fengguang.wu@intel.com>
Message-ID: <3FBADBB8-EF77-4555-8295-9290C902C267@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kbuild test robot <lkp@intel.com>
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kbuild-all@01.org, Lustre Development List <lustre-devel@lists.lustre.org>


On Mar 30, 2016, at 7:13 PM, kbuild test robot wrote:

> Hi John,
> 
> [auto build test ERROR on staging/staging-testing]
> [also build test ERROR on next-20160330]
> [cannot apply to v4.6-rc1]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]
> 
> url:    https://github.com/0day-ci/linux/commits/green-linuxhacker-ru/Lustre-IO-stack-simplifications-and-cleanups/20160331-005957
> config: i386-allyesconfig (attached as .config)
> reproduce:
>        # save the attached .config to linux build tree
>        make ARCH=i386 
> 
> Note: the linux-review/green-linuxhacker-ru/Lustre-IO-stack-simplifications-and-cleanups/20160331-005957 HEAD efae9a88212df477e27c32926e798ddb69dc96eb builds fine.
>      It only hurts bisectibility.
> 
> All errors (new ones prefixed by >>):
> 
>>> drivers/staging/lustre/lustre/llite/vvp_dev.c:87:17: error: 'vvp_thread_kmem' undeclared here (not in a function)
>      .ckd_cache = &vvp_thread_kmem,
>                    ^
>>> drivers/staging/lustre/lustre/llite/vvp_dev.c:89:23: error: invalid application of 'sizeof' to incomplete type 'struct vvp_thread_info'
>      .ckd_size  = sizeof(struct vvp_thread_info),
>                          ^

whoops, missed dropping this part after one of the countless rebases.
Resend time.
