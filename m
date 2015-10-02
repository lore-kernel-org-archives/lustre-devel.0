From: kbuild test robot <lkp@intel.com>
Date: Sat, 3 Oct 2015 06:10:12 +0800
Subject: [lustre-devel] [PATCH] staging/lustre: Make
	nrs_policy_get_info_locked() static
In-Reply-To: <a2bf5c53b3d03cf64edb2865b3eb01d52caaa6fc.1443821399.git.rocco@devzen.net>
Message-ID: <201510030633.j7jTVT5b%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Rocco,

[auto build test results on v4.3-rc3 -- if it's inappropriate base, please ignore]

config: sparc64-allyesconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=sparc64 

All error/warnings (new ones prefixed by >>):

>> drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c:456:13: error: static declaration of 'nrs_policy_get_info_locked' follows non-static declaration
    static void nrs_policy_get_info_locked(struct ptlrpc_nrs_policy *policy,
                ^
   In file included from drivers/staging/lustre/lustre/ptlrpc/../include/lustre_lib.h:64:0,
                    from drivers/staging/lustre/lustre/ptlrpc/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c:40:
   drivers/staging/lustre/lustre/ptlrpc/../include/lustre_net.h:1542:6: note: previous declaration of 'nrs_policy_get_info_locked' was here
    void nrs_policy_get_info_locked(struct ptlrpc_nrs_policy *policy,
         ^

vim +/nrs_policy_get_info_locked +456 drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c

   450	 *
   451	 * Information is copied in \a info.
   452	 *
   453	 * \param[in] policy The policy
   454	 * \param[out] info  Holds returned status information
   455	 */
 > 456	static void nrs_policy_get_info_locked(struct ptlrpc_nrs_policy *policy,
   457					struct ptlrpc_nrs_pol_info *info)
   458	{
   459		LASSERT(policy != NULL);

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/octet-stream
Size: 43733 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151003/b72035b7/attachment-0001.obj>
