From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sun, 9 Oct 2016 16:18:20 +0200
Subject: [lustre-devel] [PATCH 35/41] staging: lustre: hsm: Use file
 lease to implement migration
In-Reply-To: <1475461717-21631-36-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
	<1475461717-21631-36-git-send-email-jsimmons@infradead.org>
Message-ID: <20161009141820.GA10235@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Henri Doreau <henri.doreau@cea.fr>, Jinshan Xiong <jinshan.xiong@intel.com>

On Sun, Oct 02, 2016 at 10:28:31PM -0400, James Simmons wrote:
> From: Henri Doreau <henri.doreau@cea.fr>
> 
> Implement non-blocking migration based on exclusive open instead of
> group lock. Implemented exclusive close operation to atomically put
> a lease, swap two layouts and close a file. This allows race-free
> migrations.
> 
> Make the caller responsible for retrying on failure (EBUSY, EAGAIN)
> in non-blocking mode.
> 
> In blocking mode, allow applications to trigger layout swaps using a
> grouplock they already own, to prevent race conditions between the
> actual data copy and the layout swap. Updated lfs accordingly. File
> leases are also taken in blocking mode, so that lfs migrate can issue
> a warning if an application attempts to open a file that is being
> migrated and gets blocked.
> 
> Timestamps (atime/mtime) are set from userland, after the layout swap
> is performed, to prevent conflicts with the grouplock.
> 
> lli_trunc_sem is taken/released in the vvp_io layer, under the DLM
> lock. This re-ordering fixes the original issue between truncate and
> migrate.
> 
> Signed-off-by: Henri Doreau <henri.doreau@cea.fr>
> Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4840
> Reviewed-on: http://review.whamcloud.com/10013
> Reviewed-by: John L. Hammond <john.hammond@intel.com>
> Reviewed-by: frank zago <fzago@cray.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  .../lustre/lustre/include/lustre/lustre_idl.h      |    5 +-
>  .../lustre/lustre/include/lustre/lustre_user.h     |    1 +
>  .../lustre/lustre/include/lustre_req_layout.h      |    2 +-
>  drivers/staging/lustre/lustre/llite/file.c         |  231 ++++++++++++--------
>  drivers/staging/lustre/lustre/llite/llite_lib.c    |    4 -
>  drivers/staging/lustre/lustre/llite/vvp_io.c       |   82 +++++---
>  drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   34 ++--
>  drivers/staging/lustre/lustre/mdc/mdc_request.c    |    7 +-
>  drivers/staging/lustre/lustre/ptlrpc/layout.c      |   10 +-
>  9 files changed, 235 insertions(+), 141 deletions(-)

This patch also failed to apply :(
