From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 6 Dec 2016 10:32:55 +0100
Subject: [lustre-devel] [PATCH 2/6] staging: lustre: headers: sort
 headers affected by swab move
In-Reply-To: <1480707650-24089-3-git-send-email-jsimmons@infradead.org>
References: <1480707650-24089-1-git-send-email-jsimmons@infradead.org>
	<1480707650-24089-3-git-send-email-jsimmons@infradead.org>
Message-ID: <20161206093255.GA28615@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Ben Evans <bevans@cray.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, Dec 02, 2016 at 02:40:46PM -0500, James Simmons wrote:
> From: Ben Evans <bevans@cray.com>
> 
> It was found if you sort the headers alphabetically
> that it reduced patch conflicts. This patch sorts
> the headers alphabetically and also place linux
> header first, then uapi header and finally the
> lustre kernel headers.

I really doesn't matter what order you put them in, patch conflicts
should still happen at the same frequency :)

But I'll take it if it makes people happy...

thanks,

greg k-h
