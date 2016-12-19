From: James Simmons <jsimmons@infradead.org>
Date: Mon, 19 Dec 2016 17:02:43 +0000 (GMT)
Subject: [lustre-devel] [PATCH v2 5/5] staging: lustre: headers: use
 proper byteorder functions in lustre_idl.h
In-Reply-To: <20161213010700.GA21619@kroah.com>
References: <1481393161-22623-1-git-send-email-jsimmons@infradead.org>
	<1481393161-22623-6-git-send-email-jsimmons@infradead.org>
	<20161210181649.GB8477@kroah.com>
	<alpine.LFD.2.20.1612121952371.29051@casper.infradead.org>
	<73FD0668-EDE9-4757-98ED-8A15CE5DA17C@intel.com>
	<20161213010700.GA21619@kroah.com>
Message-ID: <alpine.LFD.2.20.1612191638580.25173@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Dilger, Andreas" <andreas.dilger@intel.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, James Simmons <uja.ornl@yahoo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>


> On Tue, Dec 13, 2016 at 12:55:01AM +0000, Dilger, Andreas wrote:
> > On Dec 12, 2016, at 13:00, James Simmons <jsimmons@infradead.org> wrote:
> > > 
> > > 
> > >> On Sat, Dec 10, 2016 at 01:06:01PM -0500, James Simmons wrote:
> > >>> In order for lustre_idl.h to be usable for both user
> > >>> land and kernel space it has to use the proper
> > >>> byteorder functions.
> > >> 
> > >> Why would userspace need/want all of these inline functions?  A uapi
> > >> header file should just have a the structures that are passed
> > >> user/kernel and any needed ioctls.  Why would they ever care about
> > >> strange byte flip functions and a ton of inline functions?
> > >> 
> > >> I don't think this is needed, of if it is, I really don't want to see
> > >> your crazy userspace code...
> > > 
> > > Sigh. More cleanups were done based on the idea this was okay. The
> > > reason this was does was when you look at the headers in
> > > include/uapi/linux you see a huge number of headers containing a bunch
> > > of inline function. To an outside project looking to merge their work
> > > into the kernel they would think this is okay. Hopefully all those
> > > broken headers will be cleaned up in the near future.
> > > Alright I will look to fixing up our tools to handle this requirement. 
> > 
> > These accessor functions are used by both the kernel and userspace
> > tools, and keeping them in the lustre_idl.h header avoids duplication
> > of code.  Similar usage exists in other filesystem related uapi headers
> > (e.g. auto_fs4.h, bcache.h, btrfs_tree.h, nilfs2_ondisk.h, swab.h, etc.).
> > 
> > That said, if there is an objection to keeping these macros/inline funcs
> > in the uapi headers, they still need to exist in the kernel and should
> > be kept in the lustre/include/lustre directory and we'll keep a separate
> > copy of the macros for userspace.
> 
> "simple" accessors/setters are fine, but these start to get complex, you
> are using unlikely, and debug macros and lots of other fun stuff.  Do
> all other filesystems also do complex stuff like ostid_to_fid()?

So the rejection of the byteorder patch was more due to the state of 
headers than the patch itself. I do have other patches with the cleanup
of debugging macros etc but I was submitting the change one change at a
time. I will post what cleanups I was looking to do for  lustre_ostid.h 
and lustre_fid.h UAPI headers. This way you can give feedback on what is 
okay and what has to change.
