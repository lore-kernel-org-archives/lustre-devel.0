From: Alex Lyashkov <Alexey.Lyashkov@Sun.COM>
Date: Wed, 18 Jun 2008 20:12:21 +0300
Subject: [Lustre-devel] security_inode_unlink in obdfilter.
Message-ID: <1213809141.3681.35.camel@bear.shadowland>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello list,

Is anybody know - why filter use this function in filter_vfs_unlink?
From my point view this only add Selinux checks for OST objects, but ost
not set any selinux context for object and this do nothing.
I see only one possible variant for usage are log events via audit log.
Is we really need this?

-- 
Alex Lyashkov <Alexey.lyashkov@sun.com>
Lustre Group, Sun Microsystems
