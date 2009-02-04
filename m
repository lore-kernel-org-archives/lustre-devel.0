From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Wed, 04 Feb 2009 17:39:06 +0300
Subject: [Lustre-devel] Sub Tree lock ideas.
In-Reply-To: <8BA1986C-3E6F-4E46-9ADB-DE42554B7C8E@Sun.COM>
References: <7D9ABF96-6BD8-4F7A-A5AE-F08BF04854B2@sun.com>
	<18824.23654.85292.845625@gargle.gargle.HOWL>
	<E3024495-6E55-4628-A6B7-1D2617DF94AA@Sun.COM>
	<18824.38684.202432.406067@gargle.gargle.HOWL>
	<8BA1986C-3E6F-4E46-9ADB-DE42554B7C8E@Sun.COM>
Message-ID: <18825.43146.166182.680655@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Oleg Drokin writes:
 > Hello!
 > 
 > On Feb 3, 2009, at 2:12 PM, Nikita Danilov wrote:
 > >> When client B looks up /a during its path traversal, it will get a
 > >> lock cookie
 > >> of the STL lock and will start presenting it with further lookups.
 > >> If /a/b/c became a working dir of process B before STL on /a was
 > >> granted, then
 > >> /a/b/c has a normal lock for client B and STL does not cover that
 > >> subtree.
 > > Yes, this is the case I meant. So we have to track (and recover)  
 > > current
 > > directories for all client processes.
 > 
 > Yes.
 > We do this with locks.

Hm.. I don't think we currently keep locks on the working directories.

 > If lock is invalid, we are forced to back-traverse the path until we
 > meet any client-visible lock or rot of the filesystem.

I just thought about another interesting use case.

Imagine client C0 holding a lock on /a/b/f, and C1 holding a STL lock on
/D. Now client C2 does mv /a /D. C2 crosses STL boundary, gets notified
about STL, gets the cookie, etc. But now C1 is having a lock on /D/a/b/f
--- under an STL.

 > 
 > Bye,
 >      Oleg

Nikita.
