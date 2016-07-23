From: Joe Perches <joe@perches.com>
Date: Sat, 23 Jul 2016 10:31:12 -0700
Subject: [lustre-devel] [PATCH 12/15] staging/lustre: Add spaces
 preferred around that '{+, -, *, /, |, <<, >>, &}'
In-Reply-To: <1469255832-746785-13-git-send-email-green@linuxhacker.ru>
References: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
	<1469255832-746785-13-git-send-email-green@linuxhacker.ru>
Message-ID: <1469295072.1900.162.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <green@linuxhacker.ru>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Emoly Liu <emoly.liu@intel.com>

On Sat, 2016-07-23 at 02:37 -0400, Oleg Drokin wrote:
> From: Emoly Liu <emoly.liu@intel.com>

unrelated trivial notes:

> diff --git a/drivers/staging/lustre/lustre/obdecho/echo_internal.h b/drivers/staging/lustre/lustre/obdecho/echo_internal.h
[]
> @@ -33,9 +33,9 @@
> ?
> ?/* The persistent object (i.e. actually stores stuff!) */
> ?#define ECHO_PERSISTENT_OBJID????1ULL
> -#define ECHO_PERSISTENT_SIZE?????((__u64)(1<<20))
> +#define ECHO_PERSISTENT_SIZE?????((__u64)(1 << 20))

This is generally an error-prone pattern as the cast is
done after the shift.

Perhaps better is using a specific type

#define ECHO_PERSISTENT_SIZE		(1ULL << 20)

And lustre seems to use types with unnecessary __ prefixes.
