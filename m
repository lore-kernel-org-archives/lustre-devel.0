From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 1 Jun 2018 10:12:11 +0200
Subject: [lustre-devel] [PATCH v2 6/6] staging: lustre: mdc: use large
 xattr buffers for old servers
In-Reply-To: <AE3B1D00-46A8-42FA-9025-2E680C185294@intel.com>
References: <1527603705-30450-1-git-send-email-jsimmons@infradead.org>
 <1527603705-30450-7-git-send-email-jsimmons@infradead.org>
 <20180531165426.GA23414@kroah.com>
 <AE3B1D00-46A8-42FA-9025-2E680C185294@intel.com>
Message-ID: <20180601081211.GD12809@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, "Hammond, John" <john.hammond@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, May 31, 2018 at 05:30:24PM +0000, Dilger, Andreas wrote:
> On May 31, 2018, at 18:54, Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
> > 
> > On Tue, May 29, 2018 at 10:21:45AM -0400, James Simmons wrote:
> >> From: "John L. Hammond" <john.hammond@intel.com>
> >> 
> >> Pre 2.10.1 MDTs will crash when they receive a listxattr (MDS_GETXATTR
> >> with OBD_MD_FLXATTRLS) RPC for an orphan or dead object. So for
> >> clients connected to these older MDTs, try to avoid sending listxattr
> >> RPCs by making the bulk getxattr (MDS_GETXATTR with OBD_MD_FLXATTRALL)
> >> more likely to succeed and thereby reducing the chances of falling
> >> back to listxattr.
> >> 
> >> +#if LUSTRE_VERSION_CODE < OBD_OCD_VERSION(3, 0, 53, 0)
> > 
> > Why are you adding pointless version checks to mainline?  Please don't
> > add new ones of these, you need to be working on removing the existing
> > ones.
> 
> These are not Linux kernel version checks, but rather Lustre release version
> checks.  This allows us to remove workarounds like this in the future when
> they are no longer needed, rather than accumulating cruft forever.  It's like
> the separation of NFSv2 vs NFSv3 vs NFSv4.

As Neil said, this is not like NFS at all.  Those are well-defined
Kconfig options that are used to compile whole new files and
include/exclude different functions entirely.

It is not used to check in the middle of code flow if something should,
or should not, happen.

As Neil also said, if you really have to do this, put it behind
functions that you properly define in a .h file, do not put #if code in
a .c file if at all possible (yeah, nfs does not do this everywhere, but
it is much better than the random checks you all have today in the
lustre code.)

So as-is, I am not taking this patch, sorry, it needs to be reworked.

greg k-h
