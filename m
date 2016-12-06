From: Oleg Drokin <oleg.drokin@intel.com>
Date: Tue, 6 Dec 2016 13:14:28 -0500
Subject: [lustre-devel] Remaining work needed for moving Lustre out of
	staging
In-Reply-To: <CAOg9mSTR8FZ3S3-aqdsxOVNso446sNUqtmtE8c3-OWZUh3eobw@mail.gmail.com>
References: <1E1B324A-F545-417D-9C35-550FA58665C7@intel.com>
	<20161203085550.GA5375@kroah.com>
	<0F617FFB-4BD0-4477-890B-2CDC56436DCC@intel.com>
	<20161206161524.GA5535@kroah.com>
	<7AF464A9-1D0F-48E9-B83C-66F983268473@intel.com>
	<CAOg9mSTR8FZ3S3-aqdsxOVNso446sNUqtmtE8c3-OWZUh3eobw@mail.gmail.com>
Message-ID: <606EDBC7-4555-42DD-85E7-66620E601C85@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Marshall <hubcap@omnibond.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, James Simmons <uja.ornl@gmail.com>, "lustre-devel@lists.lustre.org List" <lustre-devel@lists.lustre.org>


On Dec 6, 2016, at 1:07 PM, Mike Marshall wrote:

> > long error messages that we cannot split into a multiline thing anyway.
> 
> I split numerous Orangefs ones at substitution characters, which
> didn't break grepability. No one complained, and sure made
> stuff look nicer to me. You might be able to do that some places?

Checkpatch still complains about this I believe.

> 
> -Mike
> 
> On Tue, Dec 6, 2016 at 12:50 PM, Oleg Drokin <oleg.drokin@intel.com> wrote:
> 
> On Dec 6, 2016, at 11:15 AM, Greg KH wrote:
> 
> > On Tue, Dec 06, 2016 at 10:34:03AM -0500, Oleg Drokin wrote:
> >>
> >> On Dec 3, 2016, at 3:55 AM, gregkh at linuxfoundation.org wrote:
> >>
> >>> On Fri, Dec 02, 2016 at 09:53:08PM +0000, Dilger, Andreas wrote:
> >>>> Al,
> >>>> Greg recently raised the issue of what still needs to be done to
> >>>> move the Lustre code out of staging/ and into the fs/ tree.
> >>>>
> >>>> James has been doing a great job of cleaning up various checkpatch
> >>>> issues and keeping the code updated with the latest fixes, but we
> >>>> were wondering what you were aware of that needed to be cleaned
> >>>> up in Lustre?
> >>>
> >>> Is the whole "mixing kernel structures in userspace structures" all
> >>> resolved now?  For some reason I thought that you had kernel locks being
> >>> passed to userspace and then back into the kernel, but it's been a long
> >>> time since I last looked...
> >>
> >> While we certainly had our share of mixing user/kernelspace structures,
> >> I don't think we ever passed anything with locks around back and forth.
> >>
> >> I just did a brief check and I don't see anything glaring on this particular front.
> >>
> >>> If you feel you are ready for a "real" review, I'll be glad to go over
> >>> the code before the vfs people look at it, just let me know.  No need to
> >>> bother them if you still have basic things wrong that I can find?
> >>
> >> I think this would be beneficial at this stage.
> >
> > I see loads of checkpatch.pl warnings and a few errors, how about fixing
> > all of them up first?
> >
> 
> There are 16 errors,
> of them:
> 8 are false positives in  drivers/staging/lustre/lnet/libcfs/hash.c
> 1 false positive in drivers/staging/lustre/lnet/libcfs/tracefile.h
> 1 false positive in drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
> 1 I think false positive in drivers/staging/lustre/lustre/include/lustre/lustre_idl.h (PLDLMRES)
> 2 false positives in drivers/staging/lustre/lustre/include/lustre/lustre_user.h
> 
> an error I don't really understand, what does it want us to do here?
> ERROR: trailing statements should be on next line
> #196951: FILE: drivers/staging/lustre/lustre/mdc/mdc_request.c:1063:
> +                       for (end_dirent = ent; ent;
> +                            end_dirent = ent, ent = lu_dirent_next(ent));
> 
> leaving 2 real ones, one missing space in drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> and 1 spaces instead of tabs in drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
> 
> I'll have patches shortly for these.
> 
> On the warning front, we have 879 line over 80 characters, but a bunch
> of those are due to long error messages that we cannot split into a multiline thing anyway.
> 71 Prefer 'unsigned int' to bare use of 'unsigned' that is a relatively new one
> 22 new typedefs (all in lnet, I drove out all the lustre ones, so I guess I can tackle these too).
> a bunch of comment style problems
> a few "function definition argument ? should also have an identifier name" that
> seems to be a new one too, I don't remember seeing this before.
> 
> And a bunch of rarer ones for the total of 1243 (823 in just Lustre).
> Multiple classes of them are actually not easily fixable or false positives too.
> Do you really want all of these fixed too somehow?
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo at vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
