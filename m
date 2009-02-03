From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Tue, 03 Feb 2009 14:05:19 -0500
Subject: [Lustre-devel] Sub Tree lock ideas.
In-Reply-To: <18824.23654.85292.845625@gargle.gargle.HOWL>
References: <7D9ABF96-6BD8-4F7A-A5AE-F08BF04854B2@sun.com>
	<18824.23654.85292.845625@gargle.gargle.HOWL>
Message-ID: <E3024495-6E55-4628-A6B7-1D2617DF94AA@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Feb 3, 2009, at 10:01 AM, Nikita Danilov wrote:
>>    For the case of a different client stepping into area covered by
>> STL lock, this client would get STL lock's cookie and will start
>> present it for all subsequent
>>    operations (also a special flag meaning that the client is not
>> operating within STL).
> How is it determined that a given point in a namespace is covered by  
> an
> STL lock? E.g., client A holds an STL on /a, and client B accesses
> /a/b/c/f (where /a/b/c is a working directory of some process on B)?
> This looks especially problematic in the CMD case.

When client B looks up /a during its path traversal, it will get a  
lock cookie
of the STL lock and will start presenting it with further lookups.
If /a/b/c became a working dir of process B before STL on /a was  
granted, then
/a/b/c has a normal lock for client B and STL does not cover that  
subtree.
Also see other discussion on this topic here, since in the end we  
might end up
not implementing entire STL idea.

Bye,
     Oleg
