From: NeilBrown <neilb@suse.com>
Date: Mon, 22 Jul 2019 14:29:59 +1000
Subject: [lustre-devel] [PATCH 03/22] ext4: prealloc table optimization
In-Reply-To: <1563758631-29550-4-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-4-git-send-email-jsimmons@infradead.org>
Message-ID: <87r26ipu7s.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jul 21 2019, James Simmons wrote:

> Optimize prealloc table

"Optimize"???  What does that even mean here?

I notice that the patch removes a comment:

  /* XXX: should this table be tunable? */

and at least some of what the patch does is to make that table tunable.
There should be a patch which *only* makes that table tunable, with
hopefully a suggestion of why this is a good thing, and then anything
else need to go in a separate patch (with text telling me why this is
an improvement).

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190722/70240ba3/attachment.sig>
