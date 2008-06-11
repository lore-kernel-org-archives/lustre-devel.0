From: Peter Braam <Peter.Braam@Sun.COM>
Date: Wed, 11 Jun 2008 08:24:15 -0600
Subject: [Lustre-devel] Version based recovery
In-Reply-To: <op.uck72v1fatmt0c@goga>
Message-ID: <C4753C2F.5AA0%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Mike -

This deserves some pretty serious thinking and I should not be the only one
to discuss this with you, because it is so complex.

OK - so the thing to try to be very clear about is if after encountering a
gap the recovery can ever switch back to non-VBR recovery.

Also, it isn't clear what happens if the servers saw a few gaps, but power
down and back up.  It is possible that even when clients reconnect, they
don't know anymore that there were gaps, yet it can affect sequence number
recovery.  

If all clients and servers power off you can restart normal recovery.

This raises the question if there is a point in keeping sequence recovery if
we have version recovery, because one missing client appears to kick you
into VBR mode forever.  If you want to retain it, you'd have to record the
gaps and track how they are getting filled with VBR operations and may
close.

Regards,

Peter



On 6/11/08 8:05 AM, "Mikhail Pershin" <Mikhail.Pershin@Sun.COM> wrote:

> Thanks for review. I put short answers below and will update HLD with more
> details about questions you asked.
> 
> On Tue, 10 Jun 2008 21:51:23 +0400, Peter Braam <Peter.Braam@Sun.COM>
> wrote:
> 
>> 
>> 
>> I quickly reviewed the HLD and read Mike's response.  Here are a few
>> questions:
>> 
>> 1. Why do you wait for timeout+x after seeing a gap?  Why not x,timeout,
>> or
>> y?
> 
> this is wrong sentence. The server waits for RECOVERY_TIMEOUT seconds
> since last reconnect.
> 
>> 
>> 2. How to you avoid infinite accumulation of new exports?
>> 
> 
> new clients are not allowed to connect during recovery and number of
> existent exports is finite
> 
>> 3. If a VBR recovery operations happens, what transaction number is
>> assigned
>> to this?
> 
> the same as during original operation, i.e. transno from replay request.
> Since we introduce the per-export last_committed value (section 2.2.3 of
> HLD), the transno may be the same as old one.
> 
>> 
>> 4. Please discuss what happpens if multiple gaps are encountered?
>> 
> 
> when first gap is encountered (the client misses recovery) the server
> starts using the version checking for replays and all not connected
> clients are marked as 'delayed'. The number of recoverable clients is
> decreased so check_for_next_transno will not stop on gap because number of
> queued requests is equal to number of client in recovery. You right, this
> is missed use case in HLD
> 
>> 5. Can we draw some pictures of the original transaction sequence and how
>> its slots are refilled (in what order, with what new transaction number
>> etc)
>> if multiple clients are involved?
>> 
> 
> I will do that, sure
> 
>> 
>> I believe that you might have the right algorithms, but the explanations
>> in
>> the HLD are too short to be confident.
>> 
>> - Peter
>> 
>> 
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
> 
