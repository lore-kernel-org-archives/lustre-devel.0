From: Andreas Dilger <adilger@dilger.ca>
Date: Tue, 24 May 2016 14:47:57 -0600
Subject: [lustre-devel] [PATCH] posix acls: Move namespace conversion
	into filesystem / xattr handlers
In-Reply-To: <20160524084724.GA8121@infradead.org>
References: <1464008989-3812-1-git-send-email-agruenba@redhat.com>
	<20160524084724.GA8121@infradead.org>
Message-ID: <E0CE5625-120A-4DA7-ADC8-648A7A01D1AB@dilger.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, Andreas Gruenbacher <agruenba-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Drokin <oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org Development" <lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org>

On May 24, 2016, at 2:47 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> On Mon, May 23, 2016 at 03:09:49PM +0200, Andreas Gruenbacher wrote:
>> I'm reasonably confident about the core and cifs changes in this patch.
>> The lustre code is pretty weird though, so could I please get a careful
>> review on the changes there?
> 
> Lustre is in the staging tree because it's an unrescuable piece of junk.
> Please just ignore it and move the proper parts of the kernel forward.

Don't be shy Christoph, tell us how you really feel about Lustre... :-)


Fortunately, that "piece of junk" is working fine and is running on most of
the supercomputers in the world (9 of the top 10, 70%+ of the top 100, ...)
with several sites having 50PB+ of storage, and 1TB/s+ to 20000+ clients,
in a single coherent POSIX filesystem.

It's true that the staging client isn't getting cleaned up as fast as
anyone likes, but that is because it is complex software in use at many
sites for many years and we can't just stop to completely rewrite the
code and hope it still works.  Even XFS took many years to get rid of the
IRIX wrapping layers, and still does a lot of things outside of the VFS/VM
(stats, memory allocation, IO submission, etc.) because the VFS/VM doesn't
work the way XFS wants it to (or vice versa).  This is not a slight against
XFS, just a sign that non-trivial filesystems take a long time to change
while maintaining existing functionality.  This is mainly a difference in
how code is added to the kernel today vs. how it was added back then.


Cheers, Andreas





-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 833 bytes
Desc: Message signed with OpenPGP using GPGMail
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160524/d950e230/attachment-0001.pgp>
