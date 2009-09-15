From: Lee Ward <lee@sandia.gov>
Date: Mon, 14 Sep 2009 21:22:52 -0600
Subject: [Lustre-devel] Multithreaded liblustre
In-Reply-To: <FD1BE808-A4EE-4567-982F-17DCEF344DDC@swedisk.se>
References: <68880AC1-3DDB-4B20-AE49-55227D64F295@swedisk.se>
	<EBD3008A-44E8-4A1E-A642-4777F7D206C7@sun.com>
	<1252609385.3953.41.camel@wheel>
	<86344224-0630-481D-B40F-87ED6D18D408@Sun.COM>
	<FD1BE808-A4EE-4567-982F-17DCEF344DDC@swedisk.se>
Message-ID: <1252984972.3969.30.camel@wheel>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, 2009-09-10 at 13:59 -0600, Tuve Nordius wrote:
> I guess  what I am looking for is re-entrant.
> 
> The problem is if I try to do any operation (stat, readdir or  
> whatever) while occupied with a large read or write, liblustre does  
> not respond, causing mac fuse to unmount the filesystem. I can of  
> course make macfuse run in a single thread, but that is not what I want.

The SYSIO IO functions all have asynchronous counterparts, in all releases. If those
work, it sounds like you could deal with your issues, now.

However, SYSIO is dependent on the client driver supporting asynchronous IO and
last time I checked Lustre didn't. Maybe someone here can tell us if that is still true?

If Lustre can do it now, you will need to be careful not to allow more than one
thread into the SYSIO library at a time unless you use the current development head.
Then, look at the IO functions that start with 'i', all returning an ioid_t. You
should also look at iopoll and iowait, they are used to test for completion or wait
for completion and give you the return code. It's almost always a good idea to call
iopoll frequently.

		--Lee

> 
> //Tuve
> 
> 
> 10 sep 2009 kl. 21.06 skrev Oleg Drokin:
> 
> > Hello!
> >
> > On Sep 10, 2009, at 3:03 PM, Lee Ward wrote:
> >>> On Sep 10, 2009, at 8:52 AM, Tuve Nordius wrote:
> >>>> Does anyone know what need to be done/ the main obstacles  in  
> >>>> order to
> >>>> make liblustre multithreaded?
> >>> What sort of multi-threadness are you looking at?
> >>> Currently socklnd has separate threads if I remember right.
> >>> There are no callbacks and other async stuff happening, but that is
> >>> pretty much by design so would be hard to change.
> >> If you are talking about the API, the current head for SYSIO is
> >> thread-safe for all but initialization, mount, unmount, and shutdown.
> >> Don't think it works for liblustre at present, but  
> >> rklundt at sandia.gov is
> >> currently doing a port, maybe done already.
> >
> > Well, there are many sides to "multithreaded", that's why I am asking.
> > Good to know.
> >
> >> But... I thought SUN had dropped support for liblustre entirely?  
> >> Did I
> >> miss something?
> >
> > Liblustre is still a first class citizen, fully supported in HEAD  
> > (2.0)
> > codebase too, tested along with other stuff at scheduled intervals in
> > our testsuite.
> >
> > I don't even remember anybody proposing dropping liblustre support in
> > recent times.
> >
> > Bye,
> >    Oleg
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
