From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sat, 10 Dec 2016 19:14:33 +0100
Subject: [lustre-devel] [PATCH v2 3/5] staging: lustre: headers: sort
 headers affected by obdo move
In-Reply-To: <1481393161-22623-4-git-send-email-jsimmons@infradead.org>
References: <1481393161-22623-1-git-send-email-jsimmons@infradead.org>
	<1481393161-22623-4-git-send-email-jsimmons@infradead.org>
Message-ID: <20161210181433.GA8477@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Ben Evans <bevans@cray.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sat, Dec 10, 2016 at 01:05:59PM -0500, James Simmons wrote:
> From: Ben Evans <bevans@cray.com>
> 
> It was found if you sort the headers alphabetically
> that it reduced patch conflicts. This patch sorts
> the headers alphabetically and also place linux
> header first, then uapi header and finally the
> lustre kernel headers.

I still don't agree, when did you last have a patch conflict with this
file in the .h section?  And exactly how hard was it to fix it up?

I'm all for cleanups, but really, this is useless.  And I said so the
last time you sent it...

greg k-h
