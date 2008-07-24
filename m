From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Thu, 24 Jul 2008 22:56:39 +0400
Subject: [Lustre-devel] statahead feature
In-Reply-To: <C4AE0990.686F%peter.braam@sun.com>
References: <C4AE0990.686F%peter.braam@sun.com>
Message-ID: <4888D067.204@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

it's actually very interesting point - how much of lustre internals we
should expose outside? I mean flexibility vs. complexity issue in context
of portable API.

thanks, Alex

Peter Braam wrote:
> I strongly agree with this.  A good way to verify if we have a favorable
> implementation is to see if it can be ported to other OS's.
> 
> Peter
> 
> 
> On 7/24/08 4:19 AM, "Alex Zhuravlev" <Alex.Zhuravlev@Sun.COM> wrote:
> 
>> Hi,
>>
>> due to some experiments with dcache related code we've been doing with shadow
>> and others, it became clear that statahead code is quite complicated. probably
>> for no reason. the most hard part to follow is interaction with dcache. the
>> feature does number of complex things and make other parts (like
>> ll_lookup_it())
>> harder to follow too.
>>
>> after amount of discussions with people we'd like to share our vision on the
>> feature and propose slightly different solution.
>>
>> we think statahead should do nothing with dcache. it's about inodes and
>> attributes
>> only. thus, it would be good to decouple it from dcache. the only thing
>> statahead
>> should do is:
>> 1) detect statahead is needed (policy, out of the message's scope)
>> 2) scan part of directory (probably using readdir(), skip RPCs)
>> 3) finds/creates inodes for found fids
>> 4) lock these inodes (notice we propose to use inodes as a serialization point
>>     so that lockless getattr can be used)
>> 5) issue getattr RPCs (probably lockless)
>> 6) unlock inodes upon getattr's completion
>>
>> then stat(2) is called, it first has to lookup fid by name. for this we can
>> use
>> pagecache just filled with MDS_READDIR. if directory isn't being modified at
>> the
>> time, then entries will be there and we can create dentries in the dcache.
>> they
>> will be valid till UPDATE lock is cancelled - no even LOOKUP lock is needed.
>>
>>
>> another possible thing for optimization is lockless getattr. given most of
>> supported
>> kernel don't pass intent to ->getattr(), it's possible that stat(2) needs two
>> RPCs:
>> one in ll_lookup_it() and another in ll_getattr_it() as lock is released
>> between them.
>> stat(2) gives no warranty about attributes, it gives a shot of them.
>> attributes can
>> change right before userspace application get them. so, why don't we introduce
>> some
>> simple mechanism making attributes valid for short time at least for process
>> executed
>> lookup. this could help statahead as well, we think.
>>
>> comments? suggestions?
>>
>> thanks, Alex
>>
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
> 
