From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 24 May 2016 01:47:24 -0700
Subject: [lustre-devel] [PATCH] posix acls: Move namespace conversion
 into filesystem / xattr handlers
In-Reply-To: <1464008989-3812-1-git-send-email-agruenba@redhat.com>
References: <1464008989-3812-1-git-send-email-agruenba@redhat.com>
Message-ID: <20160524084724.GA8121@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Gruenbacher <agruenba-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Oleg Drokin <oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Andreas Dilger <andreas.dilger-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

On Mon, May 23, 2016 at 03:09:49PM +0200, Andreas Gruenbacher wrote:
> I'm reasonably confident about the core and cifs changes in this patch.
> The lustre code is pretty weird though, so could I please get a careful
> review on the changes there?

Lustre is in the staging tree because it's an unrescuable piece of junk.
Please just ignore it and move the proper parts of the kernel forward.
