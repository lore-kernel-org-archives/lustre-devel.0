From: Andreas Dilger <adilger@sun.com>
Date: Mon, 28 Jul 2008 16:02:58 -0600
Subject: [Lustre-devel] statahead feature
In-Reply-To: <37e3b1470807242204x6ab9037bif384e8a37595b6c6@mail.gmail.com>
References: <4888573F.4010506@sun.com> <488957EC.1040701@sun.com>
	<4889597A.6060109@sun.com>
	<37e3b1470807242204x6ab9037bif384e8a37595b6c6@mail.gmail.com>
Message-ID: <20080728220258.GE3342@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jul 24, 2008  22:04 -0700, Ragnar Kj?rstad wrote:
> On Thu, Jul 24, 2008 at 9:41 PM, Alex Zhuravlev <Alex.Zhuravlev@sun.com> wrote:
> > no, I don't think we need lock always: you just did getattr and fill inode
> > with fresh attributes, then you release lock, somebody changes attributes
> > on the server and only then userspace application gets attributes (already
> > non-fresh). so, what lock gives you in this case?
> 
> If I have an application that does:
> 1. Update stat data on one node.
> 2. Barrier
> 3. Read the same stat data on a different node
> 
> I should be guaranteed to get the correct data, right?
> So stat should return data that was valid either when the system call
> started, when it ended, or somewhere in between. (not data that was
> invalid even before the systemcall started)

That depends on what stat data was changed.  If it was e.g. atime then
there is no guarantee that the other node will get an updated copy.
If there is a file write that updates mtime then there is no guarantee
that other clients will get an updated mtime if they already have a file
lock.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
