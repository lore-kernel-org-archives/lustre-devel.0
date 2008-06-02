From: Peter Braam <Peter.Braam@Sun.COM>
Date: Mon, 02 Jun 2008 21:07:39 +0900
Subject: [Lustre-devel] Re-direction inodes
In-Reply-To: <18499.54632.983384.565997@gargle.gargle.HOWL>
Message-ID: <C46A119B.5683%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 6/2/08 8:11 PM, "Nikita Danilov" <Nikita.Danilov@Sun.COM> wrote:

> Peter Braam writes:
>> Hi Nikita -
>> 
>> I have a need in doing an architecture for a customer of a Lustre client
>> feature to have different data/page caches associated with an inode,
>> depending on the user that accesses it.    So when a file is read, user A
>> will read different data from user B (assume the same for writes, but I
>> think this is a read-only feature).
>> 
>> I remember that in the Coda file system we could easily re-direct I/O to
>> another inode using almost standard features in the VFS/page caches.  Is
>> this still the case?  Would this work for the purpose I describe above?
> 
> I am not sure how this can be done with the VFS mechanisms. Alex pointed
> out that some kind of stacked file system similar to smfs can be used
> for this purpose.

Thanks for replying so quickly. After I read your reply I began to realize
that what Coda does is too static to solve this problem.

I'm going to schedule some phone time with you to discuss this further -
because the customer I am talking to needs something and there are two
approaches, one is smfs the other is to re-do the pre-processing of the
files on the client when there are multiple different user views (neither is
all that nice).

Peter
> 
>> 
>> Thanks.
>> 
>> Peter
> 
> Nikita.
