From: Peter J Braam <Peter.Braam@Sun.COM>
Date: Tue, 05 Feb 2008 06:43:48 -0700
Subject: [Lustre-devel] Feed API and Changelog HLD
In-Reply-To: <47A7B8C7.1040002@sun.com>
References: <47A38894.3020002@sun.com> <47A72C76.7000206@sun.com>
	<47A7B8C7.1040002@sun.com>
Message-ID: <47A86814.2000905@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



Nathaniel Rutman wrote:
> Peter J Braam wrote:
>> On page 10 of the changelog API: recursive behavior for directories 
>> in filesets must exclude directories that are mount point of other 
>> filesets (as implemented for the Path Forward a few years back).
>>
>> I didn't see where ABORT sizes are discussed, but as I mentioned 
>> before there are few cases where ditching records is possible.
>>   
> I don't know what you're talking about with ABORT - you mean e.g. HSM 
> should
> abort copying an old file if the file is modified after the copy 
> starts?  Or something else?
>
Hmm, this was my jetlagged head, sorry.  I meant when you want to force 
a truncation of the log (and throw records away), how you do handle 
this?  You need this mechanism, even though it will be used only rarely.

While I am writing this, I also realize that there are some logs that 
may require re-compacting.  This happens for the LRU logs (tracking most 
recent access to files for HSM migration management) I think.  The idea 
for these logs is to (1) append a new record when an object is accessed, 
and (2) cancel the previous record for that object using a pointer to 
that record in the object.  These records can be tiny (obj id / parent 
obj id), but the mechanisms causes llog files to be non-empty with holes.


>> The storage of the records should be discussed.  The llog headers may 
>> need changes and probably the API's for canceling records will change 
>> to indicate what consumer is canceling.
>>
>> It would be wise to discuss how disk full failures etc are handled in 
>> some detail.
>>   
> ok.  Does it seem to be on the right track in general now?
At a 10,000 feet level yes.  My concerns at this point are error 
handling and performance and multiple consumer management. That's not so 
clear yet.

- Peter -
