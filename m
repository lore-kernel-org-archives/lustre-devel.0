From: Vitaly Fertman <Vitaly.Fertman@Sun.COM>
Date: Tue, 12 Jan 2010 00:59:49 +0300
Subject: [Lustre-devel] SOM questions
In-Reply-To: <4B4B4801.7070509@sun.com>
References: <078f01ca8e31$22ff9f80$68fede80$@com>
	<05A3FFE9-1549-4B97-A9C3-4B82113E56AE@Sun.COM>
	<4B4B4801.7070509@sun.com>
Message-ID: <AC682480-691F-46C8-906D-8818A1C8FC18@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 11, 2010, at 6:47 PM, Alex Zhuravlev wrote:

> I'd say we don't need DW at all.
>
> it's OST who knows whether attributes are stable (no pw locks and
> flush/commit is done, so i_blocks won't change till next open/write).

what do you mean stable? If you mean they are not going to change,
this is exactly what OST doesn't know because it doesn't know if file
is opened.

> I think in general the procedure to refresh SOM attributes could
> look like the following:
>
> 1) MDS gets GETATTR and finds the file hasn't been open for a period
>   it set special flag in GETATTR reply - say, REFRESH_SOM
> 2) client does regular enqueue/glimpse to get attributes from OST
> 3) if OST finds inode is stable (VBR version >= last_committed)
>   it set another special flag in reply - say, ATTR_STABLE
> 4) now, if client has REFRESH_SOME, ATTR_STABLE for all objects
>   *and* locks granted, then it can send aggregated attributes to
>   MDS to refresh SOM  attributes
> 5) if the file hasn't been open since that REFRESH SOM, attributes
>   can be set
>
> it looks quite simple and with very minimal changes to existing  
> protocol
> logic. I also think that following this we don't need dedicated IO  
> epoch
> notion and can use regular VBR version increasing on each open.

could you clarify how you can block IO from "lost" clients without
writing some id (VBR id?) to OST objects and not waiting for this
change to commit before updating MDS with new attributes?

--
Vitaly
