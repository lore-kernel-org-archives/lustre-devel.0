From: Arnd Bergmann <arnd@arndb.de>
Date: Sat, 03 Oct 2015 00:13:33 +0200
Subject: [lustre-devel] [PATCH] staging/lustre: Make
	nrs_policy_get_info_locked() static
In-Reply-To: <201510030633.j7jTVT5b%fengguang.wu@intel.com>
References: <201510030633.j7jTVT5b%fengguang.wu@intel.com>
Message-ID: <5223334.NTtjKnhML6@wuerfel>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Saturday 03 October 2015 06:10:12 kbuild test robot wrote:
> >> drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c:456:13: error: static declaration of 'nrs_policy_get_info_locked' follows non-static declaration
>     static void nrs_policy_get_info_locked(struct ptlrpc_nrs_policy *policy,
>                 ^
>    In file included from drivers/staging/lustre/lustre/ptlrpc/../include/lustre_lib.h:64:0,
>                     from drivers/staging/lustre/lustre/ptlrpc/../include/obd.h:52,
>                     from drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c:40:
>    drivers/staging/lustre/lustre/ptlrpc/../include/lustre_net.h:1542:6: note: previous declaration of 'nrs_policy_get_info_locked' was here
>     void nrs_policy_get_info_locked(struct ptlrpc_nrs_policy *policy,
>          ^
> 

fwiw, the patch should be fine on staging-testing, just not on mainline at the moment.

	Arnd
