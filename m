From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Thu, 14 Feb 2008 11:56:21 -0800
Subject: [Lustre-devel] Global generic database
In-Reply-To: <47B456CC.6090400@sun.com>
References: <47B335B6.5010703@sun.com> <47B456CC.6090400@sun.com>
Message-ID: <47B49CE5.50608@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter J Braam wrote:
> Hmm ... here are my thoughts.
>
> 1. The word scalable is missing below.
That is implicit in any Lustre design :)
>
> 2. Any database that relates to file system policies and file system 
> objects (HSM?) should be a separate mechanism coupled to the file 
> system, so that you can pick up the server disks and the policies.
What I am trying to avoid is multiple mechanisms to reduce the number of 
database implementations we have to write/maintain.
>
> 3. I think all updates to the database should be made on the server, 
> and the use cases should be restricted (e.g. this is for relatively 
> small databases).
Maybe updates can only be made on the server, but the data needs to be 
readable from anywhere.
>
> 4. Imho pools belong in the configuration log.
Pool definitions can easily be put in the configuration logs - but pool 
policies can be complex ("all .mov files greater than 10GB go
to pool 7") and malleable - configuration logs are not easily 
accessible, not random access (config log records are arbitrary size, so 
we must walk the file from the beginning to find a record).  If they 
grow too big performance will suffer.
> 5. Fileset attributes belong with the file system (see 2) - either 
> these are implemented as special directory files and/or EA's (does the 
> design specify the purpose and items that need to be stored in 
> databases?).
Fileset membership is stored with the filesystem (EAs), but fileset 
policies may again be larger, complex entities that should probably be 
stored once in a central database, and looked up as needed.  For the 
10,000 fileset case, clearly we don't want to read in 10,000 fileset 
policies from the config log at startup; they should be loaded on-demand 
as needed.
>
> Hmm, so can we revisit why we need a new database mechanism?
>
> - Peter -
>
>
>
> Nathaniel Rutman wrote:
>> The design of various new features in Lustre call for global 
>> (filesystem wide) databases, accessible from
>> clients or other servers:
>> A. pools - pool descriptions (pool #1 = OSTs 1-10,30-60), pool 
>> policies (all .jpg files to pool #1)
>> B. filesets - fileset policies (log creates on fileset #1 to feed "foo")
>> C. HSM - (aureleien - what was the use case here?)
Space manager policies
>>
>> We've already implemented at least 2 of these:
>> D. Fid Location Database - (is this done?)
>> E. configuration parameters - stored in MGS llogs
>>
>> Rather than continue 1-off implementations, I think it's time we came 
>> up with a consistent,
>> global, generic database mechanism for A-C as well as other future uses.
>> Needs to be:
>> 1. Fast. We need to cache database entries locally, which also means 
>> having them under locks.
>>     a. local caching
>>     b. locks
>> 2. Generic.  Store any kind of data, not limited to 8k page 
>> boundaries, etc.
>> 3. Transactional.  Power loss doesn't lead to inconsistent state.
>> 4. Recoverable. Client changes are replayed if need be.
>> 5. Remotely accessible, from a client or other servers.
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>   
