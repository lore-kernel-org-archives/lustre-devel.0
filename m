From: Peter Braam <Peter.Braam@Sun.COM>
Date: Fri, 11 Jul 2008 16:03:18 -0600
Subject: [Lustre-devel] How store HSM metadata in MDT ?
In-Reply-To: <48776F10.60008@cea.fr>
Message-ID: <C49D34C6.63DB%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 7/11/08 8:32 AM, "Jacques-Charles Lafoucriere" <jc.lafoucriere@cea.fr>
wrote:

> 
> 
> Peter Braam wrote:
>>  
>>>  
>>>>  
>>>> 3. how are multiple coordinators and agents utilized to distribute load so
>>>> that the HSM can keep up with massive small file creation?
>>>>       
>>>>  
>>>  
>>> One coordinator per MDT.
>>>     
>>>  
>>  
>> 
>> No - these must be independent considerations.  A coordinator may be much
>> slower than an MDS node in handling a single file.  I say this because this
>> has been the experience in the industry so far - with small files the HSM
>> can not at all keep up.
>>   
> 
> Why a coordinator should be on a slower node than a MDS ?
> Coordinator is a Lustre service  like other Lustre services so it will be on a
> right hardware
> 
I see no reason whatsoever to couple them to MDT?s.  Keeping them de-coupled
is more flexible and can scale better.  Am I missing issues here?

As for performance the following: a coordinator may have a lot of work to do
to track which files still need to be handled by agents and which are in
progress already and may have a fair amount of interaction with agents (not
with HSM to tape but when a coordinator is handling a re-striping migration
it will). But its interaction with the MDT?s is very limited.  So we could
degrade the performance of an MDS by placing this on the same node.  Let?s
keep this flexible please.

Peter
> 
> 
> Do you mean a coordinator is not part of the Lustre cluster ?
> 
> JC
> 

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080711/3f45bcee/attachment.htm>
