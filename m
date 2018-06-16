From: NeilBrown <neilb@suse.com>
Date: Sat, 16 Jun 2018 10:52:31 +1000
Subject: [lustre-devel] [PATCH 08/24] lustre: use truncate_inode_page in
 place of truncate_complete_page
In-Reply-To: <alpine.LFD.2.21.1806160115430.15679@casper.infradead.org>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <152904669032.10587.11474850109829193046.stgit@noble>
 <alpine.LFD.2.21.1806160115430.15679@casper.infradead.org>
Message-ID: <87y3ffft80.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, Jun 16 2018, James Simmons wrote:

>> Carrying a local truncate_complete_page() is not good
>> for maintainability.  Linux now used truncate_inode_page,
>> so use that instead.
>> For correct use, we need to pass the mapping to mdc_release_page()
>> rather than trusting page->mapping.
>
> Nak: truncate_inode_page is not exported so it fails to build when lustre
> is configured as a module.

Bother, nor it is.
We could probably use truncate_inode_pages_range() but it isn't a
perfect fit, which seems to suggest that lustre is trying to do
something that no other filesystem finds the need to do.
I'll dig deeper and work out what is really going on.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180616/0991e7c2/attachment.sig>
