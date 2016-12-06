From: Andreas Dilger <adilger@dilger.ca>
Date: Tue, 6 Dec 2016 11:05:48 -0700
Subject: [lustre-devel] Remaining work needed for moving Lustre out of
	staging
In-Reply-To: <7AF464A9-1D0F-48E9-B83C-66F983268473@intel.com>
References: <1E1B324A-F545-417D-9C35-550FA58665C7@intel.com>
	<20161203085550.GA5375@kroah.com>
	<0F617FFB-4BD0-4477-890B-2CDC56436DCC@intel.com>
	<20161206161524.GA5535@kroah.com>
	<7AF464A9-1D0F-48E9-B83C-66F983268473@intel.com>
Message-ID: <EDDB386E-5258-4BF4-93A6-BF2D365756F4@dilger.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "lustre-devel@lists.lustre.org List" <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

On Dec 6, 2016, at 10:50 AM, Oleg Drokin <oleg.drokin@intel.com> wrote:
> 
> On Dec 6, 2016, at 11:15 AM, Greg KH wrote:
>> I see loads of checkpatch.pl warnings and a few errors, how about fixing
>> all of them up first?
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

I think James already has a patch series getting rid of typedefs from LNet?

> a bunch of comment style problems
> a few "function definition argument ? should also have an identifier name" that
> seems to be a new one too, I don't remember seeing this before.
> 
> And a bunch of rarer ones for the total of 1243 (823 in just Lustre).
> Multiple classes of them are actually not easily fixable or false positives too.
> Do you really want all of these fixed too somehow?


Cheers, Andreas





-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 833 bytes
Desc: Message signed with OpenPGP using GPGMail
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20161206/3f0d95e5/attachment.pgp>
