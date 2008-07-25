From: =?ISO-8859-1?Q?Ragnar_Kj=F8rstad?= <rk@ragnarkjorstad.com>
Date: Thu, 24 Jul 2008 22:04:53 -0700
Subject: [Lustre-devel] statahead feature
In-Reply-To: <4889597A.6060109@sun.com>
References: <4888573F.4010506@sun.com> <488957EC.1040701@sun.com>
	<4889597A.6060109@sun.com>
Message-ID: <37e3b1470807242204x6ab9037bif384e8a37595b6c6@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jul 24, 2008 at 9:41 PM, Alex Zhuravlev <Alex.Zhuravlev@sun.com> wrote:
> no, I don't think we need lock always: you just did getattr and fill inode
> with fresh attributes, then you release lock, somebody changes attributes
> on the server and only then userspace application gets attributes (already
> non-fresh). so, what lock gives you in this case?

If I have an application that does:
1. Update stat data on one node.
2. Barrier
3. Read the same stat data on a different node

I should be guaranteed to get the correct data, right?
So stat should return data that was valid either when the system call
started, when it ended, or somewhere in between. (not data that was
invalid even before the systemcall started)


-- 
Ragnar Kj?rstad
