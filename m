From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 18 Aug 2017 20:41:45 -0700
Subject: [lustre-devel] [PATCH] staging: lustre: uapi: properly include
	lustre_errno.h
In-Reply-To: <1503111854-29944-1-git-send-email-jsimmons@infradead.org>
References: <1503111854-29944-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20170819034145.GB4144@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, Aug 18, 2017 at 11:04:14PM -0400, James Simmons wrote:
> The path for lustre_errno.h was not updated to the new path
> for errno.c. Also the header lustre_net.h uses code found in
> lustre_errno.h but doesn't include the header directly. It
> is easy to forget to add the header lustre_errno.h before
> including lustre_net.h so it is just easier to include
> lustre_errno.h in lustre_net.h. This should resolve the
> build issues seen on the ia64 platform.
> 
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/include/lustre_net.h | 1 +
>  drivers/staging/lustre/lustre/ptlrpc/errno.c       | 2 +-
>  2 files changed, 2 insertions(+), 1 deletion(-)

Merge this into the correct patch and send both patch series again
please.

thanks,

greg k-h
