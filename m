From: NeilBrown <neilb@suse.com>
Date: Thu, 28 Jun 2018 11:26:50 +1000
Subject: [lustre-devel] [PATCH 00/24] lustre - more cleanups including
 module reduction.
In-Reply-To: <913847E3-EB34-4B9D-9314-0BCF59837AFC@cray.com>
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
 <913847E3-EB34-4B9D-9314-0BCF59837AFC@cray.com>
Message-ID: <87zhzf66qt.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Jun 27 2018, Cory Spitz wrote:

> Hello, Neil.
>
> Cray does indeed have another user of LNet.  While it is now GPL, I can't say if it will ever be in mainline.  However, even without it there is a case for LNet to live on its own as Andreas pointed out recently with http://lists.lustre.org/pipermail/lustre-devel-lustre.org/2018-June/007098.html.
>
> But, if you want to group everything together now, we can hopefully tease it apart again in the future.  If so, I think that it would be misleading to call a module lnet if it contained distributed locking functionality (ldlm).  How about lustre-common, lustre-core, or some such?
>

Do you have a link to this open-source thing that uses LNet?  Does it
have a name?  Is it the Zest thing that Andreas' email linked to?  Or
maybe it's Cray-DVS??  A link to a git tree would be very helpful.

(I'm not committed to any name before I understand what the encapsulated
functionality would be)

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180628/2a55161c/attachment.sig>
