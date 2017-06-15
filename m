From: James Simmons <jsimmons@infradead.org>
Date: Thu, 15 Jun 2017 17:06:30 +0100 (BST)
Subject: [lustre-devel] [PATCH 5/6] staging: lustre: lustre: several
 over 80 characters cleanups
In-Reply-To: <1497464128.18751.59.camel@perches.com>
References: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
	<1497452481-31124-6-git-send-email-jsimmons@infradead.org>
	<1497464128.18751.59.camel@perches.com>
Message-ID: <alpine.LFD.2.20.1706151704110.11322@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> On Wed, 2017-06-14 at 11:01 -0400, James Simmons wrote:
> > Cleanup many of the over 80 characters reported by checkpatch
> 
> Please don't let checkpatch get in the way of lustre
> readability.
> 
> lustre commonly uses very long identifiers.
> Long identifiers and 80 columns don't mix well.
> 
> It might be simpler to declare in some document that
> lustre uses lines of up to whatever length and require
> that checkpatch should be used with the --max-line-length
> option when run on lustre code.

Greg would you be okay with this? If we changed to a max-line-length to 
say 128 thay would mean very few checkpatch issues would remain.
