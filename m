From: NeilBrown <neilb@suse.com>
Date: Thu, 28 Jun 2018 11:59:05 +1000
Subject: [lustre-devel] [PATCH 00/24] lustre - more cleanups including
 module reduction.
In-Reply-To: <DM3PR1101MB12132AC3E33E7D7C8FBE4536CB480@DM3PR1101MB1213.namprd11.prod.outlook.com>
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
 <DM3PR1101MB12132AC3E33E7D7C8FBE4536CB480@DM3PR1101MB1213.namprd11.prod.outlook.com>
Message-ID: <87tvpn6592.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

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
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180628/d261f326/attachment-0001.sig>
