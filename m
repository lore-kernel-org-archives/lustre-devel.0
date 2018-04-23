From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 23 Apr 2018 15:03:17 +0200
Subject: [lustre-devel] [PATCH 1/6] staging: lustre: move stack-check
 macros to libcfs_debug.h
In-Reply-To: <87a7u1s1fi.fsf@notabene.neil.brown.name>
References: <152383910760.23409.2327082725637657049.stgit@noble>
 <152383935730.23409.6748888065027051683.stgit@noble>
 <alpine.LFD.2.21.1804160438220.16188@casper.infradead.org>
 <87a7u1s1fi.fsf@notabene.neil.brown.name>
Message-ID: <20180423130317.GA17153@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: James Simmons <jsimmons@infradead.org>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, Apr 18, 2018 at 12:17:37PM +1000, NeilBrown wrote:
> On Mon, Apr 16 2018, James Simmons wrote:
> 
> >> CDEBUG_STACK() and CHECK_STACK() are macros to help with
> >> debugging, so move them from
> >>    drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
> >> to
> >>    drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
> >> 
> >> This seems a more fitting location, and is a step towards
> >> removing linux/libcfs.h and simplifying the include file structure.
> >
> > Nak. Currently the lustre client always enables debugging but that
> > shouldn't be the case. What we do need is the able to turn off the 
> > crazy debugging stuff. In the development branch of lustre it is
> > done with CDEBUG_ENABLED. We need something like that in Kconfig
> > much like we have CONFIG_LUSTRE_DEBUG_EXPENSIVE_CHECK. Since we like
> > to be able to turn that off this should be moved to just after
> > LIBCFS_DEBUG_MSG_DATA_DECL. Then from CHECK_STACK down to CWARN()
> > it can be build out. When CDEBUG_ENABLED is disabled CDEBUG_LIMIT
> > would be empty.
> 
> So why, exactly, is this an argument to justify a NAK?
> Are you just saying  that the code I moved into libcfs_debug.h should be
> moved to somewhere a bit later in the file?
> That can easily be done when it is needed.  It isn't needed now so why
> insist on it?
> 
> Each patch should do one thing and make clear forward progress.  This
> patch gets rid of an unnecessary file and brings related code together.
> I think that qualifies.

I agree, this just deletes an unused file, it changes no functionality
at all.  Now applied.

greg k-h
