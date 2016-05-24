From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 24 May 2016 18:31:51 +0200
Subject: [lustre-devel] [PATCH] posix acls: Move namespace conversion
 into filesystem / xattr handlers
In-Reply-To: <20160524153949.GA2830@dztty.fritz.box>
References: <1464008989-3812-1-git-send-email-agruenba@redhat.com>
	<20160524153949.GA2830@dztty.fritz.box>
Message-ID: <CAHc6FU5mTAM6cCP9S5CxrJ7PhZ-_3SxQeOLty1UgtVCu3ZVshw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Djalal Harouni <tixxdz@gmail.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Steve French <sfrench@samba.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Lustre Developement <lustre-devel@lists.lustre.org>, linux-cifs@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>

On Tue, May 24, 2016 at 5:41 PM, Djalal Harouni <tixxdz@gmail.com> wrote:
> On Mon, May 23, 2016 at 03:09:49PM +0200, Andreas Gruenbacher wrote:
>> Currently, getxattr() and setxattr() check for the xattr names
>> "system.posix_acl_{access,default}" and perform in-place UID / GID
>> namespace mappings in the xattr values. Filesystems then again check for
>> the same xattr names to handle those attributes, almost always using the
>> standard posix_acl_{access,default}_xattr_handler handlers.  This is
>> unnecessary overhead; move the namespace conversion into the xattr
>> handlers instead.
>
> Please, are you sure that the changes in posix_acl_xattr_get() and
> posix_acl_xattr_set() are safe ? you are reading into current user
> namespace, from a first view this is not safe unless I'm missing
> something... they should map into init_user_ns...

Yes, moving the namespace conversion from the VFS into those functions
so that we don't have to check for those attributes and parse them
twice is exactly the point of this patch.

> Please Cc the user namespace maintainers before. Thank you!

Eric, Andy, anyone else?

Thanks,
Andreas
