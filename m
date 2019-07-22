From: NeilBrown <neilb@suse.com>
Date: Mon, 22 Jul 2019 14:45:49 +1000
Subject: [lustre-devel] [PATCH 07/22] ext4: update .. for hash indexed
 directory
In-Reply-To: <1563758631-29550-8-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-8-git-send-email-jsimmons@infradead.org>
Message-ID: <87imrupthe.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jul 21 2019, James Simmons wrote:

> Handle special .. case.

This seems to be for adding ".." to a directory.
That happens at "mkdir".  When else would you want to do that?
Is this an on-line fsck-repair thing?

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190722/3d20ff15/attachment.sig>
