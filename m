From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 31 Jan 2011 14:35:01 -0700
Subject: [Lustre-devel] How can the name_to_handle() syscall benefit
	Lustre
In-Reply-To: <alpine.LFD.2.00.1101311645200.19399@casper.infradead.org>
References: <AANLkTikENzMTe_M=OPEUTKbHy+7FR=LP3sPUUDGKvWx+@mail.gmail.com>
	<6DF98AF0-95CC-4C5B-A40F-E5F3244CE18D@whamcloud.com>
	<alpine.LFD.2.00.1101311645200.19399@casper.infradead.org>
Message-ID: <E99BB0DE-BCF4-4B0D-82D1-FE6A19D487E2@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2011-01-31, at 09:52, James Simmons wrote:
> Andreas Dilger wrote:
>> This is something that I think would be very useful for Lustre in conjunction with the Lustre MPI ADIO driver. The MPI rank-0 node
>> could do the path traversal and generate a file handle via name_to_handle() and then MPI broadcast the file handle to all of the
>> other MPI processes, which can use it to open the shared file. This could save many thousands of MDS RPCs to do path traversal for
>> each client in a large MPI job. 
> 
> I thought the name_to_handle syscall idea was shot down? 

I don't think it was shot down, as much as it hasn't yet been accepted.  I've tried to support it in a form that would be useful to Lustre/MPI, and while it isn't quite where I'd like it to be, I think the flaws in the implementation are not insurmountable.

The current proposal is lacking a well-defined permanent filesystem identifier in each handle (i.e. a UUID as part of the public fh structure), but I think Lustre can still include the UUID as part of the private fh and have the userspace code map that back to a specific Lustre mountpoint, since it would be implemented as part of the Lustre ADIO layer.

>> On 2011-01-29, at 12:16, Vilobh Meshram <vilobh.meshram@gmail.com> wrote:
>> How can the name_to_handle() syscall benefit Lustre ?
>> 
>> Any insights will be helpful.
>> 
>> Thanks,
>> Vilobh
>> Graduate Research Associate
>> Department of Computer Science
>> The Ohio State University Columbus Ohio
>> 
>>      _______________________________________________
>>      Lustre-devel mailing list
>>      Lustre-devel at lists.lustre.org
>>      http://lists.lustre.org/mailman/listinfo/lustre-devel
>> 
>> 
>> 


Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.
