From: NeilBrown <neilb@suse.com>
Date: Mon, 22 Jul 2019 14:52:37 +1000
Subject: [lustre-devel] [PATCH 08/22] ext4: kill off struct dx_root
In-Reply-To: <1563758631-29550-9-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-9-git-send-email-jsimmons@infradead.org>
Message-ID: <87ftmypt62.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jul 21 2019, James Simmons wrote:

> Use struct dx_root_info directly.

This looks like a style change.
Instead of a 'struct' that models the start of an on-disk directory
block, the location of some fields is done using calculations instead.

Why would we want to do that?  Might we want dx_root_info to be at a
different offset in the directory ??

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190722/63f18b48/attachment.sig>
