From: Oleg Drokin <green@whamcloud.com>
Date: Mon, 22 Jul 2019 07:16:06 +0000
Subject: [lustre-devel] [PATCH 04/22] ext4: export inode management
In-Reply-To: <87o91mpu11.fsf@notabene.neil.brown.name>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-5-git-send-email-jsimmons@infradead.org>
 <87o91mpu11.fsf@notabene.neil.brown.name>
Message-ID: <700E5EAE-5BD9-4F40-95CF-3419F69070D3@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



> On Jul 22, 2019, at 12:34 AM, NeilBrown <neilb@suse.com> wrote:
> 
> On Sun, Jul 21 2019, James Simmons wrote:
> 
>> Make ext4_delete_entry() exportable for osd-ldiskfs. Also add
>> exportable ext4_create_inode().
> 
> Why can't lustre use vfs_unlink like everyone else?  And vfs_mknod()?
> My hope is that what we land upstream will use generic interfaces only.
> If there is something that osd needs to do that the generic interfaces
> cannot support, then we need to look at how to add that to the generic
> interface.

That?s probably going to be a tough thing to do. At times we need certain things
that are bad from vfs standpoint in general sense, but because we have various
outside guarantees from locking and such - we can still do them.

nothing precise comes to mind now, but I remember various games with
nlink count/moving and resurrecting such files.

We also have wider ?transaction boundaries?. Where say normal via-vfs transaction
is metadata only, we can request certain data (from ext4 perspective, but metadata
from Lustre) to be part of a particular transaction.
