From: NeilBrown <neilb@suse.com>
Date: Mon, 22 Jul 2019 15:10:50 +1000
Subject: [lustre-devel] [PATCH 12/22] ext4: add htree lock implementation
In-Reply-To: <1563758631-29550-13-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-13-git-send-email-jsimmons@infradead.org>
Message-ID: <877e8apsbp.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jul 21 2019, James Simmons wrote:

> Used for parallel lookup

This needs more time for review than I have just now ...
I suspect the full EX,PW,PR,CW,CR locking is overkill, but
I won't know until I read the code (unlikely to happen this year).

Also, we need parallel lookups at the VFS level - I do have code for
that.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190722/4b36bb59/attachment-0001.sig>
