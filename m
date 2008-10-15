From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Wed, 15 Oct 2008 14:52:53 -0700
Subject: [Lustre-devel] "Simple" HSM straw man
In-Reply-To: <48F4F5DA.7090000@sun.com>
References: <48EE87A1.7000003@sun.com> <48F379B4.6040209@cea.fr>
	<48F4F5DA.7090000@sun.com>
Message-ID: <48F66635.3040006@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nathaniel Rutman wrote:
>
>>>     b. lov EA changes
>>>        i.  flags: file_is_purged "purged", copyout_begin, 
>>> file_in_HSM_is_out_of_date "hsm_dirty", copyout_complete.  The purged 
>>> flag is always manipulated under a write layout lock, the other flags 
>>> are not.
>>>        ii: "window" EA range of non-purged data (rev2)
>>>       
>> If you add a window EA (will be needed anyway for hsm v2), you do not 
>> need a purged flag:
>>
>> window.start ==window.end is comparable to a purged flag unset. (or 
>> window.end == 0)
>>     
> True, but I don't really see a large market for partially purged files, 
> so I don't really believe that it is worth the effort.  One of the 
> important points here is that we are deleting stripes off the OSTs, 
> freeing up space, and we won't necessarily restore to those same OSTs.  
> As soon as we have partially purged files that's no longer the case, and 
> I think complicates things too much.
>   
Ok, I've been told I'm dead wrong here, and this will absolutely be 
required for "complex" HSM (not "simple"), and so therefore we should at 
least think about the arch now.  Supposedly we need to keep X bytes at 
the beginning of the file for the unix "file" command, and supposedly 
icon/preview data, and Y bytes at the end of the file, not sure exactly 
why.
We would still plan on deleting the OST objects in the middle.  And 
clearly, a simple beginning/ending byte count is insufficient for the 
final "complex" requirement of enabling partial file reads while doing a 
copyin (where we would at a minimum need a per-object cursor). 
Anyhow, as I write this none of this sounds like something that can't be 
implemented at a later time, so I think we should stick with the 
simplest of the simple options for now.
