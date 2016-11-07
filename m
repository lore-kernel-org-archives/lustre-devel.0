From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 7 Nov 2016 11:38:32 +0100
Subject: [lustre-devel] [PATCH v2] staging: lustre: mdc: manage number
 of modify RPCs in flight
In-Reply-To: <1478112412-8200-1-git-send-email-jsimmons@infradead.org>
References: <1478112412-8200-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20161107103832.GA19871@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Gregoire Pichon <gregoire.pichon@bull.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, Nov 02, 2016 at 02:46:52PM -0400, James Simmons wrote:
> From: Gregoire Pichon <gregoire.pichon@bull.net>
> 
> This patch is the main client part of a new feature that supports
> multiple modify metadata RPCs in parallel. Its goal is to improve
> metadata operations performance of a single client, while maintening
> the consistency of MDT reply reconstruction and MDT recovery
> mechanisms.
> 
> It allows to manage the number of modify RPCs in flight within
> the client obd structure and to assign a virtual index (the tag) to
> each modify RPC to help server side cleaning of reply data.
> 
> The mdc component uses this feature to send multiple modify RPCs
> in parallel.
> 
> Signed-off-by: Gregoire Pichon <gregoire.pichon@bull.net>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5319
> Reviewed-on: http://review.whamcloud.com/14374
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/fid/fid_request.c    |    4 -
>  drivers/staging/lustre/lustre/include/lustre_mdc.h |   24 +++
>  drivers/staging/lustre/lustre/include/obd.h        |    7 +-
>  drivers/staging/lustre/lustre/include/obd_class.h  |    6 +
>  drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |   37 +++++
>  drivers/staging/lustre/lustre/mdc/lproc_mdc.c      |   23 +++
>  drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   13 +-
>  drivers/staging/lustre/lustre/mdc/mdc_reint.c      |   23 +--
>  drivers/staging/lustre/lustre/mdc/mdc_request.c    |   50 ++-----
>  drivers/staging/lustre/lustre/obdclass/genops.c    |  171 +++++++++++++++++++-
>  10 files changed, 293 insertions(+), 65 deletions(-)

What changed from v1 of this patch?  You always need to put that below
the --- line so we can remember what is going on here...

Can you make a v3 with that information please?

thanks,

greg k-h
