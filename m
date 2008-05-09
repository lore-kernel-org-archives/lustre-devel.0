From: Peter Braam <Peter.Braam@Sun.COM>
Date: Fri, 09 May 2008 09:08:05 -0600
Subject: [Lustre-devel] Wide area use of Lustre and client caches
In-Reply-To: <1210343110.23307.203.camel@pc.ilinx>
Message-ID: <C449C4F5.418F%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nono - striping should only be used to get more bandwidth from servers.  The
correct solution to the problem you point out is a lock conversion, planned
long ago, still far away maybe (Nikita?).

Peter


On 5/9/08 8:25 AM, "Brian J. Murrell" <Brian.Murrell@Sun.COM> wrote:

> On Thu, 2008-05-08 at 22:55 -0600, Peter Braam wrote:
>> 
>> His use pattern was interesting ? a number of Windows clients must be
>> browsing files stored in Lustre in this remote location.  It was
>> expected that the files would be fairly large, would be viewed by
>> multiple clients, and that few or no modifications would be made.
> 
> Even still it's useful during implementation to think of the use case of
> that remote client having read a file and caching and holding a read
> lock on that file, say 1GB in size, and then another client wanting to
> update say, 1KB in the middle of the file.  It would be beneficial for
> that 1GB file to have a small (but still practical) stripe size so that
> the amount of cache that needs to be thrown away to accommodate the
> write is relatively small.
> 
> b.
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
