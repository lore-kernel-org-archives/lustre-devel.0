From: Mikhail Pershin <Mikhail.Pershin@Sun.COM>
Date: Sat, 04 Jul 2009 11:10:41 +0400
Subject: [Lustre-devel] Recovering opens by reconstruction
In-Reply-To: <20090703215528.GY15302@Sun.COM>
References: <20090702223944.GR15302@Sun.COM> <op.uwh9t2mnatmt0c@garden>
	<20090703215528.GY15302@Sun.COM>
Message-ID: <op.uwi7j3uaatmt0c@garden>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, 04 Jul 2009 01:55:28 +0400, Nicolas Williams  
<Nicolas.Williams@sun.com> wrote:

> On Fri, Jul 03, 2009 at 11:02:16PM +0400, Mikhail Pershin wrote:
>
> They've been seen, indeed, but when replayed not all the same
> permissions checks may be done, so the server needs to know that the
> replay is safe to process.  There's two ways to do that: never skip any
> permissions checks when processing replayed RPCs, or have the server
> sign replayable RPCs so the server can know validate any replays.  I've
> not looked at a complete list of checks that are skipped on replays --
> perhaps we should have such a list before we go down the replay
> signature path.

OK, so it is not about fake/malformed client only, that is interesting, is  
there any preliminary arch/hld document describing that? I am interesting  
in more backgrounds if any

> In my proposal open state recovery for opens associated with completed
> transactions would always be done by generating new anonymous open by
> FID RPCs (not replayed ones).

Well, I see no difference yet. Currently all open 'replays' are passed  
right to open_by_fid(), open file and create mfd structure for it, so it  
is the same on server side at least. Did I miss something?

>> >Open recovery must precede uncommitted transaction recovery so as to
>> >ensure that open state is re-established before unlinks can be replayed
>> >that would cause the file to be destroyed.
>>
>> That requires the server shouldn't start replays from all clients until
>> 'open recovery' is finished from all of them. In fact there is another
>
> Correct.

That is more regression than benefit, having such kind of 'barrier' during  
recovery leads to longer recovery with not balanced server load. There are  
couple improvements on the way already to make recovery of each client  
more independent from others if possible, e.g. the transaction-based  
recovery can be replaced with version-based only. So adding new barriers  
is not good case in this terms

>> solution for open-unlink problem that was implemented in 1.8. During
>> recovery the unlink replay doesn't delete file but makes it orphan even  
>> if
>> open count is 0. After recovery orphans are cleaned up already, so open
>> replay after unlink will find orphan and open it.
>
> That idea did cross my mind.  The MDS would have to keep a list of such
> unlinks so it can drop their open count if they truly aren't open.  That
> seems like a extra work that the MDS shouldn't have to do.

There is already such mechanism on MDS to handle open-unlink cases. MDS  
keeps orphaned files while they are opened and deletes all non-reopened  
after recovery. We can just use this mechanism during recovery moving  
unlinked files to orphans. It work so already in 1.8 and should be even  
simpler in 2.0 due to FIDs. There are extra checks only, no need to keep  
extra list or so. I think this is preferable way to go because we avoid  
'barriers' in recovery mentioned above

-- 
Mikhail Pershin
Staff Engineer
Lustre Group
Sun Microsystems, Inc.
