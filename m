From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 30 Jun 2017 08:01:20 +0200
Subject: [lustre-devel] [PATCH v3] staging: lustre: lnet: remove dead
 code and crc32_le() wrapper
In-Reply-To: <1498794766-12298-1-git-send-email-dmitriy@oss-tech.org>
References: <1498793366-10539-1-git-send-email-dmitriy@oss-tech.org>
	<1498794766-12298-1-git-send-email-dmitriy@oss-tech.org>
Message-ID: <20170630060120.GA29779@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dmitriy Cherkasov <dmitriy@oss-tech.org>
Cc: devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, Jun 30, 2017 at 03:52:46AM +0000, Dmitriy Cherkasov wrote:
> After removing code which was premanently disabled with ifdefs, the
> function ksocknal_csum() becomes just a wrapper for crc32_le(). Remove
> this useless wrapper and instead call crc32_le() directly.
> 
> This also resolves the following checkpatch warning which was
> triggered by the dead code:
> 
> WARNING: space prohibited before semicolon
> 
> Signed-off-by: Dmitriy Cherkasov <dmitriy@oss-tech.org>
> ---
>  drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h     | 11 -----------
>  drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c | 14 +++++++-------
>  2 files changed, 7 insertions(+), 18 deletions(-)

What changed from previous versions of this patch?  You need to put that
information below the --- line, as documented.

v4? :)

thanks,

greg k-h
