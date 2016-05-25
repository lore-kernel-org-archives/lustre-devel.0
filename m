From: Eric W. Biederman <ebiederm@xmission.com>
Date: Wed, 25 May 2016 18:30:45 -0500
Subject: [lustre-devel] [PATCH] posix acls: Move namespace conversion
	into filesystem / xattr handlers
In-Reply-To: <CAHc6FU5mTAM6cCP9S5CxrJ7PhZ-_3SxQeOLty1UgtVCu3ZVshw@mail.gmail.com>
	(Andreas Gruenbacher's message of "Tue, 24 May 2016 18:31:51 +0200")
References: <1464008989-3812-1-git-send-email-agruenba@redhat.com>
	<20160524153949.GA2830@dztty.fritz.box>
	<CAHc6FU5mTAM6cCP9S5CxrJ7PhZ-_3SxQeOLty1UgtVCu3ZVshw@mail.gmail.com>
Message-ID: <87h9dllnq2.fsf@x220.int.ebiederm.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Gruenbacher <agruenba-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Oleg Drokin <oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Andreas Dilger <andreas.dilger-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Lustre Developement <lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org>, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>

Andreas Gruenbacher <agruenba@redhat.com> writes:

> On Tue, May 24, 2016 at 5:41 PM, Djalal Harouni <tixxdz@gmail.com> wrote:
>> On Mon, May 23, 2016 at 03:09:49PM +0200, Andreas Gruenbacher wrote:
>>> Currently, getxattr() and setxattr() check for the xattr names
>>> "system.posix_acl_{access,default}" and perform in-place UID / GID
>>> namespace mappings in the xattr values. Filesystems then again check for
>>> the same xattr names to handle those attributes, almost always using the
>>> standard posix_acl_{access,default}_xattr_handler handlers.  This is
>>> unnecessary overhead; move the namespace conversion into the xattr
>>> handlers instead.
>>
>> Please, are you sure that the changes in posix_acl_xattr_get() and
>> posix_acl_xattr_set() are safe ? you are reading into current user
>> namespace, from a first view this is not safe unless I'm missing
>> something... they should map into init_user_ns...
>
> Yes, moving the namespace conversion from the VFS into those functions
> so that we don't have to check for those attributes and parse them
> twice is exactly the point of this patch.

In general I am in favor of cleaning up the xattr and acl code in the
kernel.  However I am not certain that your changes succeed in getting
us where we want to go.

My feel is that what we want to do is to update the cached acl when we
write it from userspace, to update the disk with the new acl when the
inode is sync'd to disk, and let the vfs handle the translation from
the cached posix acl to the vfs getxattr and setxattr system calls.
In the long term anything else is madness.

Currently posix acl reads and updates bypass the vfs acl cache for the
inode and that just looks wrong.


The reason that fixup happens in a separate pass from everything else
today is that when I was wrote posix_acl_fix_xattr_to_user and
posix_acl_xattr_from_user a number of filesystems had a very strange
structure that completely bypassed any code conversion routines and
made some strange assumptions.  I don't remember which filesystems those
were but it was neither lustre, nor cifs, nor nfs that were the problem
cases when I was looking.  I don't see your patch  addressing that
problem so either someone has already fixed those issues or they have
been overlooked.


There is a complication that is comming shortly (next merge window
unless major unfixable bugs show up between now and them).  There is a
new field s_user_ns that is being introduced for filesystems to record
their owner and their default translation rules to kuids.  That will
make the hard coded &init_user_ns values in your patch wrong.

>> Please Cc the user namespace maintainers before. Thank you!
>
> Eric, Andy, anyone else?

Serge Hallyn has a pending patch that adds a similar translation to
the security.capability xattr.  Which is one more case of where caching
and translation at the VFS layer are makes sense.

All of that said I am definitely in favor of cleaning up this area of
code.

Eric
