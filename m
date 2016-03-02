From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 2 Mar 2016 15:24:40 -0800
Subject: [lustre-devel] [PATCH 00/27] Third batch of LNet fixes
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20160302232440.GA14189@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, Mar 02, 2016 at 05:01:43PM -0500, James Simmons wrote:
> This patch set merges all the fixes for the klnd drivers, socklnd and
> o2iblnd, to what is currently used in production environments. Several
> more fixes for the LNet core are also included with this patch set.

I've applied the first 20, I never got patch 21 in the series, so please
rebase and resend the remaining ones, properly numbered :)

thanks,

greg k-h
