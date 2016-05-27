From: Eric W. Biederman <ebiederm@xmission.com>
Date: Fri, 27 May 2016 13:26:10 -0500
Subject: [lustre-devel] [PATCH] posix acls: Move namespace conversion
	into filesystem / xattr handlers
In-Reply-To: <87bn3ridde.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 27 May 2016 13:07:09 -0500")
References: <1464008989-3812-1-git-send-email-agruenba@redhat.com>
	<20160524153949.GA2830@dztty.fritz.box>
	<CAHc6FU5mTAM6cCP9S5CxrJ7PhZ-_3SxQeOLty1UgtVCu3ZVshw@mail.gmail.com>
	<87h9dllnq2.fsf@x220.int.ebiederm.org>
	<CAHc6FU60UYKDYe03x=EPRnbuZqy+pZNUe5x-F7pvMwbWyXNkBw@mail.gmail.com>
	<87bn3ridde.fsf@x220.int.ebiederm.org>
Message-ID: <87y46vfjct.fsf@x220.int.ebiederm.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Djalal Harouni <tixxdz@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Steve French <sfrench@samba.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Lustre Developement <lustre-devel@lists.lustre.org>, linux-cifs@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, "Serge E. Hallyn" <serge@hallyn.com>

ebiederm at xmission.com (Eric W. Biederman) writes:
>>
>> No. Just like with this patch, that mapping really needs to go into the
>> appropriate xattr handler. Again, where's that code, please?
>
> I will start looking at what is in Linus's tree.  But unless it happens
> to address my concerns, I am not even going to consider the notion that
> things should be in an ``xattr handler''.
>
> There are very good reasons why that conversion does not, nor should not
> happen inside of filesystem specific code.

Ok.  I have looked.

The cleanups in Linus' tree seem worthwhile.  The notion that mapping
needs to go into a non-generic xattr handler is broken.

If everything can always use a single set of acl handlers for posix acls
then I will be happy to consider something like your patch.

Fundamentally for vfs and security module supported attributes what a user
writes in setxattr needs to be disconnected from what actually gets
written to disk.

Things evolve and userspace breaks if we don't handle the compatibility
between old and new in the kernel.

Eric
