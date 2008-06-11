From: Mikhail Pershin <Mikhail.Pershin@Sun.COM>
Date: Wed, 11 Jun 2008 18:05:09 +0400
Subject: [Lustre-devel] Version based recovery
In-Reply-To: <C4741B3B.5A37%peter.braam@sun.com>
References: <C4741B3B.5A37%peter.braam@sun.com>
Message-ID: <op.uck72v1fatmt0c@goga>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Thanks for review. I put short answers below and will update HLD with more  
details about questions you asked.

On Tue, 10 Jun 2008 21:51:23 +0400, Peter Braam <Peter.Braam@Sun.COM>  
wrote:

>
>
> I quickly reviewed the HLD and read Mike's response.  Here are a few
> questions:
>
> 1. Why do you wait for timeout+x after seeing a gap?  Why not x,timeout,  
> or
> y?

this is wrong sentence. The server waits for RECOVERY_TIMEOUT seconds  
since last reconnect.

>
> 2. How to you avoid infinite accumulation of new exports?
>

new clients are not allowed to connect during recovery and number of  
existent exports is finite

> 3. If a VBR recovery operations happens, what transaction number is  
> assigned
> to this?

the same as during original operation, i.e. transno from replay request.  
Since we introduce the per-export last_committed value (section 2.2.3 of  
HLD), the transno may be the same as old one.

>
> 4. Please discuss what happpens if multiple gaps are encountered?
>

when first gap is encountered (the client misses recovery) the server  
starts using the version checking for replays and all not connected  
clients are marked as 'delayed'. The number of recoverable clients is  
decreased so check_for_next_transno will not stop on gap because number of  
queued requests is equal to number of client in recovery. You right, this  
is missed use case in HLD

> 5. Can we draw some pictures of the original transaction sequence and how
> its slots are refilled (in what order, with what new transaction number  
> etc)
> if multiple clients are involved?
>

I will do that, sure

>
> I believe that you might have the right algorithms, but the explanations  
> in
> the HLD are too short to be confident.
>
> - Peter
>
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel



-- 
Mikhail Pershin
Staff Engineer
Lustre Group
Sun Microsystems, Inc.
