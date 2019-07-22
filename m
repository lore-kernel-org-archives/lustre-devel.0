From: NeilBrown <neilb@suse.com>
Date: Mon, 22 Jul 2019 14:34:02 +1000
Subject: [lustre-devel] [PATCH 04/22] ext4: export inode management
In-Reply-To: <1563758631-29550-5-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-5-git-send-email-jsimmons@infradead.org>
Message-ID: <87o91mpu11.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jul 21 2019, James Simmons wrote:

> Make ext4_delete_entry() exportable for osd-ldiskfs. Also add
> exportable ext4_create_inode().

Why can't lustre use vfs_unlink like everyone else?  And vfs_mknod()?
My hope is that what we land upstream will use generic interfaces only.
If there is something that osd needs to do that the generic interfaces
cannot support, then we need to look at how to add that to the generic
interface.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190722/3881f8b8/attachment.sig>
