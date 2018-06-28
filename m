From: Patrick Farrell <paf@cray.com>
Date: Thu, 28 Jun 2018 02:35:46 +0000
Subject: [lustre-devel] [PATCH 00/24] lustre - more cleanups including
 module reduction.
In-Reply-To: <87tvpn6592.fsf@notabene.neil.brown.name>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <alpine.LFD.2.21.1806210239190.3886@casper.infradead.org>
 <DM3PR1101MB1213DDB7FC857EE6B1444153CB760@DM3PR1101MB1213.namprd11.prod.outlook.com>
 <alpine.LFD.2.21.1806210354260.3886@casper.infradead.org>
 <3FD4D051-9C95-449D-8A23-D42B271E55B8@dilger.ca>
 <DM3PR1101MB121322E85FDE1E5310F6F4B7CB760@DM3PR1101MB1213.namprd11.prod.outlook.com>
 <87tvprah32.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806260206360.31196@casper.infradead.org>
 <DM3PR1101MB121358672276198B843DE5A7CB490@DM3PR1101MB1213.namprd11.prod.outlook.com>
 <87d0wd6i4m.fsf@notabene.neil.brown.name>
 <44633E99-07CB-4C40-967C-0B4FE206F29A@whamcloud.com>
 <DM3PR1101MB12132AC3E33E7D7C8FBE4536CB480@DM3PR1101MB1213.namprd11.prod.outlook.com>,
 <87tvpn6592.fsf@notabene.neil.brown.name>
Message-ID: <DM3PR1101MB12139B5B51BCE76A79DEC383CB4F0@DM3PR1101MB1213.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


I will ask about source and plans to publish it, Neil - I?m almost certain it has not been publicly released yet and I?m not actually sure the relicensing is really complete.  So I?d be shocked and possibly mildly concerned if you found the source online today.

Understood about the rest, and thanks!  I have no idea which DVS uses, and I understand that as an out of tree user, we are in the end responsible for it.  DVS has in fact had this relationship with the master branch for a long time - Andreas and company are accommodating about interface changes, but in the end, we are responsible for keeping in sync.

I would say about the acceptor and sock lnd: I believe Lustre assumes some IP transport is available for configuration, but does NOT necessarily use it for primary communication.  Fabrics - Like infiniband or Cray Aries - are more or less always configured to provide IP transport, to enable the panoply of tools and apps that rely on it.  But they perform better if their native protocols are used, which is of course what the other LNDs do.

________________________________
From: NeilBrown <neilb@suse.com>
Sent: Wednesday, June 27, 2018 8:59:05 PM
To: Patrick Farrell; Andreas Dilger; James Simmons
Cc: Oleg Drokin; Lustre Development List
Subject: Re: [lustre-devel] [PATCH 00/24] lustre - more cleanups including module reduction.

On Wed, Jun 27 2018, Patrick Farrell wrote:

> Neil,
>
> We do indeed have such functionality (it?s called DVS and it?s
> basically a high speed file system projection framework, ala NFS but
> faster), so the ability to build lnet separately is valuable to us.
> While it is being open sourced under the GPL, I don?t think there?s
> any intention to try to upstream it.  The current code isn?t even
> usable off of Cray systems as it depends on info from user space (that
> is provided, in the end, from Cray proprietary hardware) to keep its
> connection/routing tables up to date.  That?s supposedly in the
> pipeline to get fixed, but it?s still pretty far from generally
> usable.
>
> But we?d still really appreciate it if lnet stayed separate.  Don?t
> know if that?s enough for you - I know sometimes *small* stuff is done
> for out of tree users.  Hopefully this meets that standard.
>

Ahh - DVS.  That answers a question I just asked in another email.
My google-skills don't seem to be up to locating the source code though
:-(

While I wouldn't knowingly break an interface used by some out-of-tree
code without good reason, it is hard to avoid if you don't know what the
out-of-tree code does.  It can be very tempting to remove something that
isn't being used, but that can certainly hurt out-of-tree code
sometimes.

A particular example I'm exploring at present is the dual data paths in
LNet.  Or maybe it is dual types of Memory Descriptors.
There is 'kiov' which uses kernel-virtual addresses and 'iovec' which
uses page+offset.
The kiov option isn't used in the client code and it seems likely that
the server-side code could be converted to use iovec without problems.

I'd like to remove the kiov as I wouldn't be able to justify its
existence when submitting the client-only code upstream.  But I don't
want to remove the option of having an alternate MD type if it really is
significantly more efficient in some context.
If I know whether DVS used kiov or iovec - and in what way - that would
help me to know if I might break something, and to be able to assess the
cost.

In my mind, the "standard" that you mention is always about
practicality.   Code needs to be maintainable - easy to understand and
hard to break.  If the LNet interface is clean and well documented in
the kernel, then I don't see why we would not at least attempt to
preserve it.

Thanks,
NeilBrown
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180628/6750beca/attachment.html>
