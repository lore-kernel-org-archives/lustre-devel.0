From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Fri, 25 Jul 2008 09:17:04 +0400
Subject: [Lustre-devel] statahead feature
In-Reply-To: <37e3b1470807242204x6ab9037bif384e8a37595b6c6@mail.gmail.com>
References: <4888573F.4010506@sun.com> <488957EC.1040701@sun.com>
	<4889597A.6060109@sun.com>
	<37e3b1470807242204x6ab9037bif384e8a37595b6c6@mail.gmail.com>
Message-ID: <488961D0.9060709@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ragnar Kj?rstad wrote:
> On Thu, Jul 24, 2008 at 9:41 PM, Alex Zhuravlev <Alex.Zhuravlev@sun.com> wrote:
>> no, I don't think we need lock always: you just did getattr and fill inode
>> with fresh attributes, then you release lock, somebody changes attributes
>> on the server and only then userspace application gets attributes (already
>> non-fresh). so, what lock gives you in this case?
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

indeed. we can't use this trick in all the cases. I think it's a subject
of discussion what we consider a barrier, for regular stat(2) it can be
start of system call. for ls -l case it can be open(2). isn't this a
reasonable cost for significant performance improvement of ls -l ?

my understanding is that for NFS with readdir+ support, the barrier will
be open(2).

thanks for this good point, Alex
