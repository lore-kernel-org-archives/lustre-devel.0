From: Mikhail Pershin <Mikhail.Pershin@Sun.COM>
Date: Sat, 04 Jul 2009 11:14:13 +0400
Subject: [Lustre-devel] Recovering opens by reconstruction
In-Reply-To: <20090704004850.GC15301@Sun.COM>
References: <20090702223944.GR15302@Sun.COM> <op.uwh9t2mnatmt0c@garden>
	<20090703215528.GY15302@Sun.COM> <20090704004850.GC15301@Sun.COM>
Message-ID: <op.uwi7pzmkatmt0c@garden>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, 04 Jul 2009 04:48:51 +0400, Nicolas Williams  
<Nicolas.Williams@sun.com> wrote:

> On Fri, Jul 03, 2009 at 04:55:28PM -0500, Nicolas Williams wrote:
>> On Fri, Jul 03, 2009 at 11:02:16PM +0400, Mikhail Pershin wrote:
>> > On Fri, 03 Jul 2009 02:39:45 +0400, Nicolas Williams
>> > <Nicolas.Williams@sun.com> wrote:
>> > >We're working on adding replay RPC signatures, so that clients may  
>> only
>> > >replay RPCs that have been seen by the server (thus signed).
>> >
>> > Could you explain that more? All replays have been seen by server  
>> just by
>> > definition because client got reply from server, so what is purpose of
>> > such signing?
>>
>> They've been seen, indeed, but when replayed not all the same
>> permissions checks may be done, so the server needs to know that the
>> replay is safe to process.  There's two ways to do that: never skip any
>> permissions checks when processing replayed RPCs, or have the server
>> sign replayable RPCs so the server can know validate any replays.  I've
>> not looked at a complete list of checks that are skipped on replays --
>> perhaps we should have such a list before we go down the replay
>> signature path.
>
> Oh, I forgot for a moment, but the other point of replay signatures is
> to prevent clients from causing other clients to be evicted.

Ah, I am interesting even more in some background about this idea. I  
thought this was needed as protection from malformed clients only but it  
looks more functional.

-- 
Mikhail Pershin
Staff Engineer
Lustre Group
Sun Microsystems, Inc.
