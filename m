From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Tue, 03 Feb 2009 14:25:07 -0500
Subject: [Lustre-devel] Sub Tree lock ideas.
In-Reply-To: <18824.38684.202432.406067@gargle.gargle.HOWL>
References: <7D9ABF96-6BD8-4F7A-A5AE-F08BF04854B2@sun.com>
	<18824.23654.85292.845625@gargle.gargle.HOWL>
	<E3024495-6E55-4628-A6B7-1D2617DF94AA@Sun.COM>
	<18824.38684.202432.406067@gargle.gargle.HOWL>
Message-ID: <8BA1986C-3E6F-4E46-9ADB-DE42554B7C8E@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Feb 3, 2009, at 2:12 PM, Nikita Danilov wrote:
>> When client B looks up /a during its path traversal, it will get a
>> lock cookie
>> of the STL lock and will start presenting it with further lookups.
>> If /a/b/c became a working dir of process B before STL on /a was
>> granted, then
>> /a/b/c has a normal lock for client B and STL does not cover that
>> subtree.
> Yes, this is the case I meant. So we have to track (and recover)  
> current
> directories for all client processes.

Yes.
We do this with locks.
If lock is invalid, we are forced to back-traverse the path until we
meet any client-visible lock or rot of the filesystem.

Bye,
     Oleg
