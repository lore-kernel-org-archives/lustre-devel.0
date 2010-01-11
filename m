From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Mon, 11 Jan 2010 18:47:13 +0300
Subject: [Lustre-devel] SOM questions
In-Reply-To: <05A3FFE9-1549-4B97-A9C3-4B82113E56AE@Sun.COM>
References: <078f01ca8e31$22ff9f80$68fede80$@com>
	<05A3FFE9-1549-4B97-A9C3-4B82113E56AE@Sun.COM>
Message-ID: <4B4B4801.7070509@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I'd say we don't need DW at all.

it's OST who knows whether attributes are stable (no pw locks and
flush/commit is done, so i_blocks won't change till next open/write).

I think in general the procedure to refresh SOM attributes could
look like the following:

1) MDS gets GETATTR and finds the file hasn't been open for a period
    it set special flag in GETATTR reply - say, REFRESH_SOM
2) client does regular enqueue/glimpse to get attributes from OST
3) if OST finds inode is stable (VBR version >= last_committed)
    it set another special flag in reply - say, ATTR_STABLE
4) now, if client has REFRESH_SOME, ATTR_STABLE for all objects
    *and* locks granted, then it can send aggregated attributes to
    MDS to refresh SOM  attributes
5) if the file hasn't been open since that REFRESH SOM, attributes
    can be set

it looks quite simple and with very minimal changes to existing protocol
logic. I also think that following this we don't need dedicated IO epoch
notion and can use regular VBR version increasing on each open.

thanks, Alex


On 1/11/10 5:10 PM, Vitaly Fertman wrote:
> On Jan 5, 2010, at 9:01 PM, Eric Barton wrote:
>
>> Vitaly,
>>
>> 1. Clients must replay opens on the MDS if "done writing" is still
>>    pending to notify the new MDS that this file is volatile.  Does it
>>    matter whether the client already sent "close" to the previous MDS
>>    instance?  Does it have to send "close" again?
>
> the idea was to get rid of these long chains of requests on replay
> (open-close-DW-setattr), DW and setattr are replayed independently
> not requiring committed open to be replayed.
>
> due to 3633, we do not even replay committed open if close is already
> sent.
> requiring open to be replayed due to pending DW will bring this
> problem back.
>
> MDS in its turn just ignores DW and setattr for not re-opened files and
> relies on synchronisation with OSTs -- once file is closed, data are
> under extent lock and under control here. thus we can invalidate SOM
> attributes on MDS by llog record and the following SOM recovery will
> ensure in some way data are flushed and committed on OST (alternatively
> we can just ask the clients to flush and OST to commit before the
> synchronisation).
>
> SOM recovery may try to happen late enough so that data would be already
> committed on OST with some checks they are really committed; or will
> have
> to take conflicting extent lock and wait for commit by itself.
>
>> 2. I assume "done writing" is only sent after stripe updates have been
>>    committed, not just executed so that cached SOM attributes are not
>>    dependent on the client still being around to participate in
>>    recovery if an OST fails.  Is this correct?
>
>
> it is correct, DW can be postponed until commit.
>
> however, as we cannot get the proper attribute update (in particular
> i_blocks) right in DW, there was an idea to separate SOM invalidation
> from SOM revalidation mechanism, i.e. to not try to rebuild the SOM
> cache on MDS immediately once the file has been modified.
>
> In this case DW can just indicate that this client is not going to
> modify the file anymore and probably we do not have to wait until
> commit,
> the revalidation will occur late enough so that the commit would have
> occured (again with some checks it really occured).
>
> In the case of OST failure, while OST is down or not re-synchronised
> with
> MDS, SOM is disabled; the SOM re-validation will occur late enough after
> MDS-OST synchronisation completes...
>
> --
> Vitaly
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
