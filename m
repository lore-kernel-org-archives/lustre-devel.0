From: NeilBrown <neilb@suse.com>
Date: Wed, 07 Nov 2018 09:23:32 +1100
Subject: [lustre-devel] Apparent bug in LU-8130 ptlrpc: convert
 conn_hash to rhashtable / Linux-commit:
 ac2370ac2bc5215daf78546cd8d925510065bb7f
In-Reply-To: <3E0E82E2-0EF0-4F05-9C33-282002000D31@cray.com>
References: <3E0E82E2-0EF0-4F05-9C33-282002000D31@cray.com>
Message-ID: <87r2fxyhej.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Nov 06 2018, Patrick Farrell wrote:

> Neil, James,
>
> Sent this earlier, but with nasty formatting that got it rejected.  Whoops.
> ?
> It looks like the patch we landed as:
> LU-8130 ptlrpc: convert conn_hash to rhashtable
> ?
> Linux has a resizeable hashtable implementation in lib,
> so we should use that instead of having one in libcfs.
> ?
> This patch converts the ptlrpc conn_hash to use rhashtable.
> In the process we gain lockless lookup.
> ?
> As connections are never deleted until the hash table is destroyed,
> there is no need to count the reference in the hash table. There
> is also no need to enable automatic_shrinking.
> ?
> Linux-commit: ac2370ac2bc5215daf78546cd8d925510065bb7f
> ?
> Introduced a bug.? Ihara-san opened something to track it here:
> https://jira.whamcloud.com/browse/LU-11624
> ?
> It?s a null pointer in nid_hash(); there are some more details at that link.

That commit changed ptlrpc_connection_get() so that it can return NULL.

This is actually one of the really annoying things about rhashtable.  I
cannot convince the maintainers that sometimes you need guaranteed
success (which is quite possible with a hash table).  They come from the
networking community were they drop packets on errors all the time - no
big deal.

Anyway, all users of ptlrpc_connection_get() in the client code (in
drivers/staging) test the return value against NULL, so this was safe.

In SFS lustre, the call in target_handle_connect() assigned the
result to export->exp_connection without checking against NULL.
That leads to the oops.

ptlrpc_connection_get() will return NULL when
rhashtable_lookup_get_insert_fast() returns an error.
The errors are mostly weird internal implementation details leaking out
the API.  A retry, possibly after a short delay, will usually succeed.
(see https://lwn.net/Articles/751974/, section "Failure during insertion)
If this happens a lot, it might suggest that the hash function is poor.

Ahhhh... this was built against a 3.10 kernel.
Prior to 4.6, hash_64() was not so much "poor" as "appalling".
See https://lwn.net/Articles/687494/

For SFS we should avoid using hash_64() (at least before 4.6) and
instead use something like
  hash_32((foo>>32) ^ hash_32(foo & 0xFFFFFFFF))

NeilBrown

> ?
> We?re seeing it at Cray as well, when testing the current WhamCloud branch.
> ?
> Basically, when we fail over an MDS(/MDT) under load (ie with real activity on the file system) we hit this panic about 30-50% of the time right now.? I assume it?s possible on OSSes as well but we haven?t seen it there.
> ?
> I haven?t done any detailed investigation, but I thought I?d bring it to your attention.? Per Ihara-san in LU-11624, the crash does not happen without the commit listed above.
> ?
> ? Patrick
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181107/9aae45cc/attachment.sig>
