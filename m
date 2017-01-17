From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 17 Jan 2017 08:41:40 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: headers: potential UAPI
	headers
In-Reply-To: <alpine.LFD.2.20.1701162126170.27875@casper.infradead.org>
References: <1482167207-22800-1-git-send-email-jsimmons@infradead.org>
	<20170103141248.GA8695@kroah.com>
	<alpine.LFD.2.20.1701162126170.27875@casper.infradead.org>
Message-ID: <20170117074140.GA19328@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Jan 16, 2017 at 09:28:30PM +0000, James Simmons wrote:
> 
> > On Mon, Dec 19, 2016 at 12:06:47PM -0500, James Simmons wrote:
> > > Not for landing. This is the purposed UAPI headers
> > > with the removal of unlikely and debugging macros.
> > > This is just for feedback to see if this is acceptable
> > > for the upstream client.
> > > 
> > > Signed-off-by: James Simmons <jsimmons@infradead.org>
> > > ---
> > >  .../lustre/lustre/include/lustre/lustre_fid.h      | 353 +++++++++++++++++++++
> > >  .../lustre/lustre/include/lustre/lustre_ostid.h    | 233 ++++++++++++++
> > 
> > Can you make a lustre "uapi" directory so we can see which files you
> > really want to be UAPI and which you don't as time goes on?
> 
> Where do you want them placed? In uapi/linux/lustre or uapi/lustre. Does
> it matter to you? The below was to forth coming UAPI headers which from
> your response you seem okay with in general.

How many .h files are there going to be?  It's just a single filesystem,
shouldn't you just need a single file?  If so, how about
	drivers/staging/lustre/include/uapi/lustre.h
?

If you really need multiple .h files, put them all in the same uapi/
directory with a lustre_ prefix, you don't need a whole subdir just for
yourself, right?

thanks,

greg k-h
