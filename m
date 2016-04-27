From: Bruce Korb <bruce.korb@gmail.com>
Date: Wed, 27 Apr 2016 15:51:09 -0700
Subject: [lustre-devel] [PATCH 05/15] staging: lustre: ldlm: use
 accessor macros for l_flags
In-Reply-To: <1461795667-29035-6-git-send-email-jsimmons@infradead.org>
References: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
	<1461795667-29035-6-git-send-email-jsimmons@infradead.org>
Message-ID: <5721425D.5050606@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Wow!  I remember this stuff, even if from 3 years ago.  Feels like a 
lifetime.  Is this patch being applied to official Linux, hence this 
message?  Xyratex collapsed, shed a mess of employees and sold the 
remnant to Seagate.  Consequently, I don't really follow Lustre any 
more.  Sorry.

On 04/27/16 15:20, James Simmons wrote:
> From: Bruce Korb <bruce.korb@gmail.com>
>
> Convert most of the ldlm lock's l_flags references from direct
> bit twiddling to using bit specific macros.  A few multi-bit
> operations are left as an exercise for the reader.
>
> The changes are mostly in ldlm, but also in llite, osc and quota.
> Also add a multi-bit (mask) test.
>
> Signed-off-by: Bruce Korb <bruce.korb@gmail.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2906
> Reviewed-by: Keith Mannthey <Keith.Mannthey@intel.com>
> Reviewed-on: http://review.whamcloud.com/7963
> Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>   .../lustre/lustre/include/lustre_dlm_flags.h       |    3 +
