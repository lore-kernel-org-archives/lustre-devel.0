From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Mon, 30 Mar 2009 10:52:17 -0400
Subject: [Lustre-devel] Async close RPC
In-Reply-To: <1238424141.24213.195.camel@pc.interlinx.bc.ca>
References: <29A3C6ED-8132-4896-92CB-3518036D84BB@Sun.COM>
	<1238424141.24213.195.camel@pc.interlinx.bc.ca>
Message-ID: <00BFC60E-B3D5-44A0-AF25-FF8D9440E6D2@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Mar 30, 2009, at 10:42 AM, Brian J. Murrell wrote:
>>    It recently struck me as how unfair many file creation tests are
>> to Lustre. The problem is only with tests because they portray Lustre
>>    creation rates lower than actual speed to be seen by application.
>> (same goes for opens, btw).
> The only thing I would add/say Oleg, is have you looked at the Hendrix
> CMD specific metadata tests?  I only mention this because from what I
> recall, we took advantage of every opportunity we could (within the
> requirements of the project) to show performance in the best light we
> could.  I'd imagine that those tests (and the corresponding Lustre  
> code_
> would have considered some of the same things you are considering.

Yes. As I said, I am aware CMD project tried this idea and found it to  
be
of no help. I am not deeply aware of the details, though.

> It may be however that some of the solutions were CMD specific and not
> really applicable to you, but perhaps in the least, looking at some of
> those tests (i.e. mdsrate was one key test) might prevent you from
> re-inventing tests.

I am not reinventing tests, I just want to make existing tests to show
more fair number when run on Lustre.

Bye,
     Oleg
