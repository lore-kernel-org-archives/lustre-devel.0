From: NeilBrown <neilb@suse.com>
Date: Thu, 21 Mar 2019 12:49:45 +1100
Subject: [lustre-devel] [PATCH - OpenSFS lustre bug] LNET: socklnd: fix
 infinite loop in ksocknal_push()
Message-ID: <87tvfx6lom.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


If the list_for_each_entry() loop in ksocknal_push()
ever finds a match, then it will increment 'i', and the outer
loop will continue.  Presumably it will find the same match again
and increment i and continue again.

Once peer_off becomes larger than the number of matches
in a given chain, 'peer_ni' will be an invalid pointer, and
ksocknal_push_peer() will probably crash when called on it.

To abort the outer loop properly, we need to test if
"i <= peer_off", which indicates that all matching peers
have been found.

Signed-off-by: NeilBrown <neilb@suse.com>
---

This patch is against OpenSFS lustre, not my drivers/staging tree that
most of my patches are against.

This really looks like untested code, but it is not entirely possible
that I've missed something.

If you would like me to submit this through more "normal" channels, I'm
happy to learn what they are, and then do that.
I assume this would mean getting access to the lustre Gerrit instance.
I tried the "register" link, but that takes me to

https://review.whamcloud.com/login/%23%2Fc%2F33883

which isn't very helpful.

NeilBrown


 lnet/klnds/socklnd/socklnd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lnet/klnds/socklnd/socklnd.c b/lnet/klnds/socklnd/socklnd.c
index 7bd3b5288373..041380cbfb6a 100644
--- a/lnet/klnds/socklnd/socklnd.c
+++ b/lnet/klnds/socklnd/socklnd.c
@@ -1939,7 +1939,7 @@ ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 			}
 			read_unlock(&ksocknal_data.ksnd_global_lock);
 
-			if (i == 0) /* no match */
+			if (i <= peer_off) /* no match */
 				break;
 
 			rc = 0;
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190321/3d34778c/attachment.sig>
