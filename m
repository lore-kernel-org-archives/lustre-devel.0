From: Greg KH <gregkh@linuxfoundation.org>
Date: Mon, 8 Jun 2015 12:28:34 -0700
Subject: [lustre-devel] [PATCH] staging: lustre: cleanup not needed else
	clauses
In-Reply-To: <1433161131-25946-1-git-send-email-antonio.murdaca@gmail.com>
References: <1433161131-25946-1-git-send-email-antonio.murdaca@gmail.com>
Message-ID: <20150608192834.GA15483@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jun 01, 2015 at 02:18:51PM +0200, Antonio Murdaca wrote:
> cleanup checkpatch.pl warnings about not needed else
> clauses after a break or return
> 
> Signed-off-by: Antonio Murdaca <antonio.murdaca@gmail.com>
> ---
>  drivers/staging/lustre/lustre/fid/fid_request.c    |  5 ++-
>  .../staging/lustre/lustre/include/lprocfs_status.h |  3 +-
>  drivers/staging/lustre/lustre/lclient/lcommon_cl.c | 36 +++++++++++-----------
>  drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  3 +-
>  drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 11 ++++---
>  drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |  3 +-
>  drivers/staging/lustre/lustre/lov/lov_request.c    |  3 +-
>  drivers/staging/lustre/lustre/mdc/mdc_request.c    |  8 ++---
>  drivers/staging/lustre/lustre/obdclass/cl_object.c |  6 ++--
>  drivers/staging/lustre/lustre/obdclass/llog_cat.c  |  6 ++--
>  drivers/staging/lustre/lustre/osc/osc_lock.c       |  3 +-
>  drivers/staging/lustre/lustre/osc/osc_request.c    | 14 +++++----
>  drivers/staging/lustre/lustre/ptlrpc/pinger.c      |  8 ++---
>  13 files changed, 50 insertions(+), 59 deletions(-)

Doesn't apply to my latest tree :(
