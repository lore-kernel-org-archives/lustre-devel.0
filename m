From: Simmons, James A. <simmonsja@ornl.gov>
Date: Wed, 21 Oct 2015 15:34:55 +0000
Subject: [lustre-devel] [PATCH] staging/lustre: move IT_* definitions to
 lustre_idl.h
In-Reply-To: <D24D09E2.112FD8%andreas.dilger@intel.com>
References: <D24D09E2.112FD8%andreas.dilger@intel.com>
Message-ID: <4ba96de035f147d08e5570a9ef523677@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


>Put IT_* definitions into an enum, as they're sent over the wire,
>adjust calls, print statements, etc. to use the new enum.
>
>Signed-off-by: Ben Evans <bevans@cray.com>

>When you push patches upstream, please include the review tags from the
>original patch:
>
>Reviewed-on: http://review.whamcloud.com/16228

Also please add this to your commit message:

Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6746

>Reviewed-by: John L. Hammond <john.hammond@intel.com>
>Reviewed-by: James Simmons <uja.ornl@yahoo.com>
>Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
>
>
>The "Tested-by:" and "Change-Id:" tags should be dropped.
>
>The Reviewed-on: tag allows readers to get more information about this
>patch and helps us track which patches have been upstreamed and which have
>not.
>
>The Reviewed-by: tag allows the upstream reviewer to see who has already
>approved the patch.
