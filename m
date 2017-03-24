From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 24 Mar 2017 22:22:06 +0000
Subject: [lustre-devel] [PATCH 1/6] Autoconf option for
	rate-limiting	Quality of Service (RLQOS)
In-Reply-To: <99fe8fdaaaa5b6fd36c0782269bc45a580079696.1490122510.git.yanli@ascar.io>
References: <cover.1490122510.git.yanli@ascar.io>
	<99fe8fdaaaa5b6fd36c0782269bc45a580079696.1490122510.git.yanli@ascar.io>
Message-ID: <3FFFCE73-97FE-4A10-8AC6-47D835CC6B3C@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 21, 2017, at 13:43, Yan Li <yanli@ascar.io> wrote:
> 
> This patch enables rate-limiting quality of service (RLQOS) support as
> talked in the ASCAR paper [1]. The purpose of RLQOS is to provide a
> client-side rate limiting mechanism that controls max_rpcs_in_flight
> and minimal gap between brw RPC requests (called tau in the code and
> paper).
> 
> RLQOS can be enabled by passing --enable-rlqos to configure. It then
> can be controlled by tunables in procfs of each osc.

Hi Yan,
thanks for submitting the patch series.  Two high level comments on the
patches, since I haven't had a chance to review them in detail (though
I see Alexey has commented on some of them):
- What external tools (if any) are needed in order to use this functionality?
 Are these available for download, and is there documentation for using them?
- It is fine that you've submitted the patches here for discussion and to
 raise awareness of your work.  In order to get them landed you should submit
 the patches to Gerrit (see https://wiki.hpdd.intel.com/display/PUB/Using+Gerrit

I'll try to take a look at them when I get a chance.  This may also be of
interest to Li Xi and Qian at DDN, who have been working on server-side NRS.

Cheers, Andreas

> [1] http://storageconference.us/2015/Papers/14.Li.pdf
> 
> Signed-off-by: Yan Li <yanli@ascar.io>
> ---
> lustre/autoconf/lustre-core.m4 | 17 +++++++++++++++++
> lustre/include/Makefile.am     |  3 ++-
> 2 files changed, 19 insertions(+), 1 deletion(-)
> 
> diff --git a/lustre/autoconf/lustre-core.m4 b/lustre/autoconf/lustre-core.m4
> index 0578325..7f1828e 100644
> --- a/lustre/autoconf/lustre-core.m4
> +++ b/lustre/autoconf/lustre-core.m4
> @@ -369,6 +369,22 @@ AC_COMPILE_IFELSE([AC_LANG_SOURCE([
> AC_MSG_RESULT([$enable_ssk])
> ]) # LC_OPENSSL_SSK
> 
> +#
> +# LC_CONFIG_RLQOS
> +#
> +# Rate-limiting Quality of Service support
> +#
> +AC_DEFUN([LC_CONFIG_RLQOS], [
> +AC_MSG_CHECKING([whether to enable rate-limiting quality of service support])
> +AC_ARG_ENABLE([rlqos],
> +	AC_HELP_STRING([--enable-rlqos],
> +		[enable rate-limiting quality of service support]),
> +	[], [enable_rlqos="no"])
> +AC_MSG_RESULT([$enable_rlqos])
> +AS_IF([test "x$enable_rlqos" != xno],
> +	[AC_DEFINE(ENABLE_RLQOS, 1, [enable rate-limiting quality of service support])])
> +]) # LC_CONFIG_RLQOS
> +
> # LC_INODE_PERMISION_2ARGS
> #
> # up to v2.6.27 had a 3 arg version (inode, mask, nameidata)
> @@ -2241,6 +2257,7 @@ AC_DEFUN([LC_PROG_LINUX], [
> 	LC_GLIBC_SUPPORT_FHANDLES
> 	LC_CONFIG_GSS
> 	LC_OPENSSL_SSK
> +	LC_CONFIG_RLQOS
> 
> 	# 2.6.32
> 	LC_BLK_QUEUE_MAX_SEGMENTS
> diff --git a/lustre/include/Makefile.am b/lustre/include/Makefile.am
> index 9074ca4..6d72b6e 100644
> --- a/lustre/include/Makefile.am
> +++ b/lustre/include/Makefile.am
> @@ -98,4 +98,5 @@ EXTRA_DIST = \
> 	upcall_cache.h \
> 	lustre_kernelcomm.h \
> 	seq_range.h \
> -	uapi_kernelcomm.h
> +	uapi_kernelcomm.h \
> +	rlqos.h
> -- 
> 1.8.3.1
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
