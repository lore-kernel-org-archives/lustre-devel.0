From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Thu, 26 May 2016 13:36:23 +0200
Subject: [lustre-devel] [PATCH] posix acls: Move namespace conversion
 into filesystem / xattr handlers
In-Reply-To: <87h9dllnq2.fsf@x220.int.ebiederm.org>
References: <1464008989-3812-1-git-send-email-agruenba@redhat.com>
	<20160524153949.GA2830@dztty.fritz.box>
	<CAHc6FU5mTAM6cCP9S5CxrJ7PhZ-_3SxQeOLty1UgtVCu3ZVshw@mail.gmail.com>
	<87h9dllnq2.fsf@x220.int.ebiederm.org>
Message-ID: <CAHc6FU60UYKDYe03x=EPRnbuZqy+pZNUe5x-F7pvMwbWyXNkBw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Djalal Harouni <tixxdz@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Steve French <sfrench@samba.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Lustre Developement <lustre-devel@lists.lustre.org>, linux-cifs@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, "Serge E. Hallyn" <serge@hallyn.com>

On Thu, May 26, 2016 at 1:30 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Andreas Gruenbacher <agruenba@redhat.com> writes:
>
>> On Tue, May 24, 2016 at 5:41 PM, Djalal Harouni <tixxdz@gmail.com> wrote:
>>> On Mon, May 23, 2016 at 03:09:49PM +0200, Andreas Gruenbacher wrote:
>>>> Currently, getxattr() and setxattr() check for the xattr names
>>>> "system.posix_acl_{access,default}" and perform in-place UID / GID
>>>> namespace mappings in the xattr values. Filesystems then again check for
>>>> the same xattr names to handle those attributes, almost always using the
>>>> standard posix_acl_{access,default}_xattr_handler handlers.  This is
>>>> unnecessary overhead; move the namespace conversion into the xattr
>>>> handlers instead.
>>>
>>> Please, are you sure that the changes in posix_acl_xattr_get() and
>>> posix_acl_xattr_set() are safe ? you are reading into current user
>>> namespace, from a first view this is not safe unless I'm missing
>>> something... they should map into init_user_ns...
>>
>> Yes, moving the namespace conversion from the VFS into those functions
>> so that we don't have to check for those attributes and parse them
>> twice is exactly the point of this patch.
>
> In general I am in favor of cleaning up the xattr and acl code in the
> kernel.  However I am not certain that your changes succeed in getting
> us where we want to go.
>
> My feel is that what we want to do is to update the cached acl when we
> write it from userspace, to update the disk with the new acl when the
> inode is sync'd to disk, and let the vfs handle the translation from
> the cached posix acl to the vfs getxattr and setxattr system calls.
> In the long term anything else is madness.
>
> Currently posix acl reads and updates bypass the vfs acl cache for the
> inode and that just looks wrong.

Not all filesystems cache acls in the inode (i_acl and i_default_acl), so there
has to be some way to "bypass the cache" if you want to put it that way.

All normal filesystems that cache ACLs locally implement the get_acl and
set_acl inode operations. They put posix_acl_access_xattr_handler
and posix_acl_default_xattr_handler into s_xattr and use the
generic_{get,set,remove}xattr inode operations to hook things up
appropriately. The xattr handlers convert to/from xattrs and struct posix_acl
and call the get_acl and set_acl inode operations. That's where the namespace
conversion is supposed to happen as well; this avoids special-casing
it in the VFS.

The only filesystems that don't do things that way are CIFS and Lustre. Doing
the appropriate namespace mapping in CIFS is easy (see this patch). So it's only
Lustre that's left with the original in-place xattr conversion.

Another pending cleanup (https://lwn.net/Articles/688390/) gets rid of the
{get,set,remove}xattr inode operations in favor of using s_xattr directly.

> The reason that fixup happens in a separate pass from everything else
> today is that when I wrote posix_acl_fix_xattr_to_user and
> posix_acl_xattr_from_user a number of filesystems had a very strange
> structure that completely bypassed any code conversion routines and
> made some strange assumptions.  I don't remember which filesystems those
> were but it was neither lustre, nor cifs, nor nfs that were the problem
> cases when I was looking.  I don't see your patch  addressing that
> problem so either someone has already fixed those issues or they have
> been overlooked.

There have been cleanups in this area before, so I assume things were
fixed. In any case, I didn't blindly hack this together, I've actually checked
all the filesystems.

> There is a complication that is comming shortly (next merge window
> unless major unfixable bugs show up between now and them).  There is a
> new field s_user_ns that is being introduced for filesystems to record
> their owner and their default translation rules to kuids.  That will
> make the hard coded &init_user_ns values in your patch wrong.

Okay, that conflict should be easy enough to resolve. Where's that code?

>>> Please Cc the user namespace maintainers before. Thank you!
>>
>> Eric, Andy, anyone else?
>
> Serge Hallyn has a pending patch that adds a similar translation to
> the security.capability xattr.  Which is one more case of where caching
> and translation at the VFS layer are makes sense.

No. Just like with this patch, that mapping really needs to go into the
appropriate xattr handler. Again, where's that code, please?

Thanks,
Andreas
