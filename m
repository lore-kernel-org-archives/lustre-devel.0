From: NeilBrown <neilb@suse.com>
Date: Thu, 08 Nov 2018 12:15:16 +1100
Subject: [lustre-devel] Apparent bug in LU-8130 ptlrpc: convert
 conn_hash to rhashtable / Linux-commit:
 ac2370ac2bc5215daf78546cd8d925510065bb7f
In-Reply-To: <alpine.LFD.2.21.1811071922400.3887@casper.infradead.org>
References: <3E0E82E2-0EF0-4F05-9C33-282002000D31@cray.com>
 <87r2fxyhej.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1811071922400.3887@casper.infradead.org>
Message-ID: <87y3a4wesb.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Nov 07 2018, James Simmons wrote:

>> > Neil, James,
>> >
>> > Sent this earlier, but with nasty formatting that got it rejected.  Whoops.
>> > ?
>> > It looks like the patch we landed as:
>> > LU-8130 ptlrpc: convert conn_hash to rhashtable
>> > ?
>> > Linux has a resizeable hashtable implementation in lib,
>> > so we should use that instead of having one in libcfs.
>> > ?
>> > This patch converts the ptlrpc conn_hash to use rhashtable.
>> > In the process we gain lockless lookup.
>> > ?
>> > As connections are never deleted until the hash table is destroyed,
>> > there is no need to count the reference in the hash table. There
>> > is also no need to enable automatic_shrinking.
>> > ?
>> > Linux-commit: ac2370ac2bc5215daf78546cd8d925510065bb7f
>> > ?
>> > Introduced a bug.? Ihara-san opened something to track it here:
>> > https://jira.whamcloud.com/browse/LU-11624
>> > ?
>> > It?s a null pointer in nid_hash(); there are some more details at that link.
>> 
>> That commit changed ptlrpc_connection_get() so that it can return NULL.
>> 
>> This is actually one of the really annoying things about rhashtable.  I
>> cannot convince the maintainers that sometimes you need guaranteed
>> success (which is quite possible with a hash table).  They come from the
>> networking community were they drop packets on errors all the time - no
>> big deal.
>> 
>> Anyway, all users of ptlrpc_connection_get() in the client code (in
>> drivers/staging) test the return value against NULL, so this was safe.
>> 
>> In SFS lustre, the call in target_handle_connect() assigned the
>> result to export->exp_connection without checking against NULL.
>> That leads to the oops.
>> 
>> ptlrpc_connection_get() will return NULL when
>> rhashtable_lookup_get_insert_fast() returns an error.
>> The errors are mostly weird internal implementation details leaking out
>> the API.  A retry, possibly after a short delay, will usually succeed.
>> (see https://lwn.net/Articles/751974/, section "Failure during insertion)
>> If this happens a lot, it might suggest that the hash function is poor.
>> 
>> Ahhhh... this was built against a 3.10 kernel.
>> Prior to 4.6, hash_64() was not so much "poor" as "appalling".
>> See https://lwn.net/Articles/687494/
>> 
>> For SFS we should avoid using hash_64() (at least before 4.6) and
>> instead use something like
>>   hash_32((foo>>32) ^ hash_32(foo & 0xFFFFFFFF))
>
> The libcfs hash is not much better :-( 
>
> I have a purposed fix. Let me know if its correct. Thank you.
>
> From 32df018c1af8fdbc833c537aafeea081ab3d8d7e Mon Sep 17 00:00:00 2001
> From: James Simmons <uja.ornl@yahoo.com>
> Date: Wed, 7 Nov 2018 14:06:37 -0500
> Subject: [PATCH] LU-11624 ptlrpc: handle no ptlrpc connection case
>
> With the move of ptlrpc connections hash to rhashtable it is now
> possible for ptlrpc_connection_get() to return NULL. The reason
> this can happen is due to conditions. One is that the hash has no
                           ^two ??

Actually there are three.  -EBUSY is also possible, and is the one that
might be caused by a bad hash function.

I would retry on both -ENOMEM and -EBUSY.
Maybe give a warning if -EBUSY.

Otherwise it looks OK.

Thanks,
NeilBrown


> more free slots which results in an E2BIG error. By default the
> maximum size for rhashtables is 2^31 so this is very unlikely
> going to happen. The second case returns a -ENOMEM which can
> happen when the bucket can be resized. For this case test the
> return value of rhashtable_lookup_get_insert_fast() and if it is
> -ENOMEM try again inserting the new connection into the hash
> table. Just as an extra level of protection against a failed
> connection attempt in target_handle_connect() exit out with
> -ENOTCONN.
>
> Change-Id: I0537564ba544ed06be42ba243606a884a1290f20
> Signed-off-by: James Simmons <uja.ornl@yahoo.com>
> ---
>  lustre/ldlm/ldlm_lib.c     | 3 +++
>  lustre/ptlrpc/connection.c | 6 +++++-
>  2 files changed, 8 insertions(+), 1 deletion(-)
>
> diff --git a/lustre/ldlm/ldlm_lib.c b/lustre/ldlm/ldlm_lib.c
> index de66aa3..463c6c6 100644
> --- a/lustre/ldlm/ldlm_lib.c
> +++ b/lustre/ldlm/ldlm_lib.c
> @@ -1349,6 +1349,9 @@ dont_check_exports:
>  	export->exp_connection = ptlrpc_connection_get(req->rq_peer,
>  						       req->rq_self,
>  						       &cluuid);
> +	if (!export->exp_connection)
> +		GOTO(out, rc = -ENOTCONN);
> +
>  	if (hlist_unhashed(&export->exp_nid_hash))
>  		cfs_hash_add(export->exp_obd->obd_nid_hash,
>  			     &export->exp_connection->c_peer.nid,
> diff --git a/lustre/ptlrpc/connection.c b/lustre/ptlrpc/connection.c
> index 21a24a2..045b3ee 100644
> --- a/lustre/ptlrpc/connection.c
> +++ b/lustre/ptlrpc/connection.c
> @@ -103,13 +103,17 @@ ptlrpc_connection_get(struct lnet_process_id peer, lnet_nid_t self,
>  	 * connection.	The object which exists in the hash will be
>  	 * returned,otherwise NULL is returned on success.
>  	 */
> +try_again:
>  	conn2 = rhashtable_lookup_get_insert_fast(&conn_hash, &conn->c_hash,
>  						  conn_hash_params);
>  	if (conn2) {
>  		/* insertion failed */
>  		OBD_FREE_PTR(conn);
> -		if (IS_ERR(conn2))
> +		if (IS_ERR(conn2)) {
> +			if (PTR_ERR(conn2) == -ENOMEM)
> +				goto try_again;
>  			return NULL;
> +		}
>  		conn = conn2;
>  		ptlrpc_connection_addref(conn);
>  	}
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181108/f426fd66/attachment.sig>
