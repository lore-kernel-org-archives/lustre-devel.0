From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Thu, 13 Dec 2007 10:23:22 -0500
Subject: [Lustre-devel] read ahead
In-Reply-To: <200712131515.lBDFFrCa014152@cmf.nrl.navy.mil>
References: <200712131515.lBDFFrCa014152@cmf.nrl.navy.mil>
Message-ID: <6AD2FC07-6589-4194-B92E-9844847AECD3@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Dec 13, 2007, at 10:15 AM, chas williams - CONTRACTOR wrote:

>> Yes it is.
>> DIRECT IO by it's nature is "direct", i.e. it gets straight into
>> application buffers,
>> we are not to put any more data there than application said it can
>> accept.
> i agree with this interpretation of O_DIRECT.
>
>> And we are not allowed to cache any of that data (or to use any cache
>> to get
>> the data during reads) too.
> this seems a bit stricter than i would expect.  while i would expect
> O_DIRECT to bypass the kernel readahead mechanism, i think that  
> lustre's
> readahead is outside of the scope of O_DIRECT.

While technically nothing prevents us from reading some more stuff  
into client
cache (we cannot do any readahead into applications buffers for  
obvious reasons)
with readahead after genuine directio request, we cannot use the cache
for directio requests, so if next read request comes in directio mode,  
we MUST
bypass cache and the whole purpose of readahead is therefore defeated.

Bye,
     Oleg
