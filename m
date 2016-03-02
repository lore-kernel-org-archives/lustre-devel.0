From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 2 Mar 2016 15:22:51 -0800
Subject: [lustre-devel] [PATCH] staging: lustre: Support different
 ko2iblnd configs between systems
In-Reply-To: <1456956130-6110-22-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
	<1456956130-6110-22-git-send-email-jsimmons@infradead.org>
Message-ID: <20160302232251.GA24740@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jeremy Filizetti <jeremy.filizetti@gmail.com>

On Wed, Mar 02, 2016 at 05:02:04PM -0500, James Simmons wrote:
> From: Jeremy Filizetti <jeremy.filizetti@gmail.com>
> 
> This patch adds suppoort for ko2iblnd to have different values for
> peer_credits and map_on_demand between systems.

Your subject has no number for this patch, is it really patch 21 in the
series?

thanks,

greg k-h
