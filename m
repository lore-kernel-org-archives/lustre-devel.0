From: Oleg Drokin <green@linuxhacker.ru>
Date: Fri, 15 Jun 2018 20:59:43 -0400
Subject: [lustre-devel] [PATCH 08/24] lustre: use truncate_inode_page in
 place of truncate_complete_page
In-Reply-To: <87y3ffft80.fsf@notabene.neil.brown.name>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <152904669032.10587.11474850109829193046.stgit@noble>
 <alpine.LFD.2.21.1806160115430.15679@casper.infradead.org>
 <87y3ffft80.fsf@notabene.neil.brown.name>
Message-ID: <61C2F92E-8F88-49C6-83FB-F3013289265C@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Jun 15, 2018, at 8:52 PM, NeilBrown <neilb@suse.com> wrote:
> 
> On Sat, Jun 16 2018, James Simmons wrote:
> 
>>> Carrying a local truncate_complete_page() is not good
>>> for maintainability.  Linux now used truncate_inode_page,
>>> so use that instead.
>>> For correct use, we need to pass the mapping to mdc_release_page()
>>> rather than trusting page->mapping.
>> 
>> Nak: truncate_inode_page is not exported so it fails to build when lustre
>> is configured as a module.
> 
> Bother, nor it is.
> We could probably use truncate_inode_pages_range() but it isn't a
> perfect fit, which seems to suggest that lustre is trying to do
> something that no other filesystem finds the need to do.
> I'll dig deeper and work out what is really going on.

Lustre evicts pages from mapping when the lock that covers the pages
is canceled.
Normally this only applies to data pages, and I see this is in mdc which is for metadata.

For metadata the only pages we hold are readdir pages and the lock currently
covers entire dir so lock cancelation should not need this.

So looking at the code the other two users are readdir where we failed to populate page
somehow and now need to throw it out and then a collision event for hashes, it appears.
Both of these should apply to other filesystems I am sure.
