From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 27 Sep 2016 13:01:02 +0200
Subject: [lustre-devel] [PATCH 01/37] staging: lustre: llite: add
 missing LMV_MAGIC_V1 case
In-Reply-To: <1474901450-28730-1-git-send-email-jsimmons@infradead.org>
References: <1474901450-28730-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20160927110102.GA16196@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, wang di <di.wang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Sep 26, 2016 at 10:50:50AM -0400, James Simmons wrote:
> From: wang di <di.wang@intel.com>
> 
> The port to upstream dropped handling the LMV_MAGIC_V1
> case for ll_dir_getstripe. This adds it back.
> 
> Signed-off-by: wang di <di.wang@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
> Reviewed-on: http://review.whamcloud.com/7228
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> Reviewed-by: John L. Hammond <john.hammond@intel.com>
> Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/llite/dir.c           | 4 ++++
>  drivers/staging/lustre/lustre/ptlrpc/pack_generic.c | 1 +
>  2 files changed, 5 insertions(+)

I got this single patch, what about the other 36 patches you are saying
this is a series of?

thanks,

greg k-h
