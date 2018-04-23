From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 23 Apr 2018 15:13:59 +0200
Subject: [lustre-devel] [PATCH 3/6] staging: lustre: remove
 include/linux/libcfs/linux/linux-cpu.h
In-Reply-To: <alpine.LFD.2.21.1804160448410.16188@casper.infradead.org>
References: <152383910760.23409.2327082725637657049.stgit@noble>
 <152383935737.23409.2271901486597092772.stgit@noble>
 <alpine.LFD.2.21.1804160448410.16188@casper.infradead.org>
Message-ID: <20180423131359.GA11836@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: NeilBrown <neilb@suse.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Apr 16, 2018 at 04:52:55AM +0100, James Simmons wrote:
> 
> > This include file contains definitions used when CONFIG_SMP
> > is in effect.  Other includes contain corresponding definitions
> > for when it isn't.
> > This can be hard to follow, so move the definitions to the one place.
> > 
> > As HAVE_LIBCFS_CPT is defined precisely when CONFIG_SMP, we discard
> > that macro and just use CONFIG_SMP when needed.
> 
> Nak. The lustre SMP is broken and needed to badly be reworked. I have it 
> ready and can push it. I was waiting to see if I had to rebase it once
> the rc1 stuff but since their is a push to get everything out their I will
> push it.

A NAK on some future code that might show up someday is not how we work
at all, sorry.  That has caused other open source projects to die.
First patch submitted "wins".

And these are good patches.  Nothing wrong with them, they clean stuff
up, remove more lines than they added and that's the proper thing to do
here.  So I've applied the first 4, the last two didn't apply due to
changes from you that were accepted.  See, you benifit also from this :)

thanks,

greg k-h
