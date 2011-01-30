From: Andreas Dilger <adilger@whamcloud.com>
Date: Sun, 30 Jan 2011 12:13:04 -0700
Subject: [Lustre-devel] How can the name_to_handle() syscall benefit
	Lustre
In-Reply-To: <AANLkTikENzMTe_M=OPEUTKbHy+7FR=LP3sPUUDGKvWx+@mail.gmail.com>
References: <AANLkTikENzMTe_M=OPEUTKbHy+7FR=LP3sPUUDGKvWx+@mail.gmail.com>
Message-ID: <6DF98AF0-95CC-4C5B-A40F-E5F3244CE18D@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This is something that I think would be very useful for Lustre in conjunction with the Lustre MPI ADIO driver. The MPI rank-0 node could do the path traversal and generate a file handle via name_to_handle() and then MPI broadcast the file handle to all of the other MPI processes, which can use it to open the shared file. This could save many thousands of MDS RPCs to do path traversal for each client in a large MPI job. 

Cheers, Andreas

On 2011-01-29, at 12:16, Vilobh Meshram <vilobh.meshram@gmail.com> wrote:

> Hi All,
> 
> How can the name_to_handle() syscall benefit Lustre ?
> 
> Any insights will be helpful.
> 
> Thanks,
> Vilobh
> Graduate Research Associate
> Department of Computer Science
> The Ohio State University Columbus Ohio
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110130/2d7eaa4a/attachment.htm>
