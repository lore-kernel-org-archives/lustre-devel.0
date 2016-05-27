From: Eric W. Biederman <ebiederm@xmission.com>
Date: Fri, 27 May 2016 13:07:09 -0500
Subject: [lustre-devel] [PATCH] posix acls: Move namespace conversion
	into filesystem / xattr handlers
In-Reply-To: <CAHc6FU60UYKDYe03x=EPRnbuZqy+pZNUe5x-F7pvMwbWyXNkBw@mail.gmail.com>
	(Andreas Gruenbacher's message of "Thu, 26 May 2016 13:36:23 +0200")
References: <1464008989-3812-1-git-send-email-agruenba@redhat.com>
	<20160524153949.GA2830@dztty.fritz.box>
	<CAHc6FU5mTAM6cCP9S5CxrJ7PhZ-_3SxQeOLty1UgtVCu3ZVshw@mail.gmail.com>
	<87h9dllnq2.fsf@x220.int.ebiederm.org>
	<CAHc6FU60UYKDYe03x=EPRnbuZqy+pZNUe5x-F7pvMwbWyXNkBw@mail.gmail.com>
Message-ID: <87bn3ridde.fsf@x220.int.ebiederm.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Gruenbacher <agruenba-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Oleg Drokin <oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Andreas Dilger <andreas.dilger-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Lustre Developement <lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org>, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>

Andreas Gruenbacher <agruenba@redhat.com> writes:

> On Thu, May 26, 2016 at 1:30 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>> Andreas Gruenbacher <agruenba@redhat.com> writes:
>>
>>> On Tue, May 24, 2016 at 5:41 PM, Djalal Harouni <tixxdz@gmail.com> wrote:
>>>> On Mon, May 23, 2016 at 03:09:49PM +0200, Andreas Gruenbacher wrote:
>>>>> Currently, getxattr() and setxattr() check for the xattr names
>>>>> "system.posix_acl_{access,default}" and perform in-place UID / GID
>>>>> namespace mappings in the xattr values. Filesystems then again check for
>>>>> the same xattr names to handle those attributes, almost always using the
>>>>> standard posix_acl_{access,default}_xattr_handler handlers.  This is
>>>>> unnecessary overhead; move the namespace conversion into the xattr
>>>>> handlers instead.
>>>>
>>>> Please, are you sure that the changes in posix_acl_xattr_get() and
>>>> posix_acl_xattr_set() are safe ? you are reading into current user
>>>> namespace, from a first view this is not safe unless I'm missing
>>>> something... they should map into init_user_ns...
>>>
>>> Yes, moving the namespace conversion from the VFS into those functions
>>> so that we don't have to check for those attributes and parse them
>>> twice is exactly the point of this patch.
>>
>> In general I am in favor of cleaning up the xattr and acl code in the
>> kernel.  However I am not certain that your changes succeed in getting
>> us where we want to go.
>>
>> My feel is that what we want to do is to update the cached acl when we
>> write it from userspace, to update the disk with the new acl when the
>> inode is sync'd to disk, and let the vfs handle the translation from
>> the cached posix acl to the vfs getxattr and setxattr system calls.
>> In the long term anything else is madness.
>>
>> Currently posix acl reads and updates bypass the vfs acl cache for the
>> inode and that just looks wrong.
>
> Not all filesystems cache acls in the inode (i_acl and i_default_acl), so there
> has to be some way to "bypass the cache" if you want to put it that way.
>
> All normal filesystems that cache ACLs locally implement the get_acl and
> set_acl inode operations. They put posix_acl_access_xattr_handler
> and posix_acl_default_xattr_handler into s_xattr and use the
> generic_{get,set,remove}xattr inode operations to hook things up
> appropriately. The xattr handlers convert to/from xattrs and struct posix_acl
> and call the get_acl and set_acl inode operations. That's where the namespace
> conversion is supposed to happen as well; this avoids special-casing
> it in the VFS.

The acl support does look like what I would expect this code to look
like.  Unfortunately some fileystems still (as of 4.6) write xattrs
directly to disk.

> The only filesystems that don't do things that way are CIFS and Lustre. Doing
> the appropriate namespace mapping in CIFS is easy (see this patch). So it's only
> Lustre that's left with the original in-place xattr conversion.

You know I really wish this was the case.  And perhaps I need to look to
see what has just been merged in the merge window.  There are clearly
some xattr changes post 4.6 that I am not seeing.

As of 4.6.0 writing xattrs from a user namespace is broken by this
change.

> There have been cleanups in this area before, so I assume things were
> fixed. In any case, I didn't blindly hack this together, I've actually checked
> all the filesystems.

You know that scares me.  Because I just started looking and the first
oddball case I checked was broken.
>
>> There is a complication that is comming shortly (next merge window
>> unless major unfixable bugs show up between now and them).  There is a
>> new field s_user_ns that is being introduced for filesystems to record
>> their owner and their default translation rules to kuids.  That will
>> make the hard coded &init_user_ns values in your patch wrong.
>
> Okay, that conflict should be easy enough to resolve. Where's that code?
>
>>>> Please Cc the user namespace maintainers before. Thank you!
>>>
>>> Eric, Andy, anyone else?
>>
>> Serge Hallyn has a pending patch that adds a similar translation to
>> the security.capability xattr.  Which is one more case of where caching
>> and translation at the VFS layer are makes sense.
>
> No. Just like with this patch, that mapping really needs to go into the
> appropriate xattr handler. Again, where's that code, please?

I will start looking at what is in Linus's tree.  But unless it happens
to address my concerns, I am not even going to consider the notion that
things should be in an ``xattr handler''.

There are very good reasons why that conversion does not, nor should not
happen inside of filesystem specific code.

Eric
