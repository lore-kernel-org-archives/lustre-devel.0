From: Greg KH <greg@kroah.com>
Date: Thu, 26 Jul 2018 16:12:27 +0200
Subject: [lustre-devel] [BUG] staging: lustre: Possible null function
 pointer in ctx_refresh_timeout()
In-Reply-To: <6920e093-ad62-56dc-6f58-36cf8d7ed3b4@gmail.com>
References: <6920e093-ad62-56dc-6f58-36cf8d7ed3b4@gmail.com>
Message-ID: <20180726141227.GA12445@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jia-Ju Bai <baijiaju1990@gmail.com>
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, paf@cray.com, namit@vmware.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Thu, Jul 26, 2018 at 10:02:22PM +0800, Jia-Ju Bai wrote:
> In Linux-4.16, drivers/staging/lustre/lustre/ptlrp/sec.c,

Please look at the 4.18-rc6 release for this file.

In short, nothing to worry about anymore :)

thanks,

greg k-h
