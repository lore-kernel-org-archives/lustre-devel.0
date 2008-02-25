From: Peter J Braam <Peter.Braam@Sun.COM>
Date: Mon, 25 Feb 2008 15:38:16 -0700
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <47BD980F.50201@cea.fr>
References: <47AAE307.9040305@cea.fr> <47BD980F.50201@cea.fr>
Message-ID: <47C34358.6050806@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



Aurelien Degremont wrote:
> Hello
>
> I've got several wondering about some specific point in HSM 
> implementation and I would like your opinion about them.
>
> Coordinator:
>
> This element will manage migration externally (HSM) and internally of 
> Lustre (space balancing?). Is the current API acceptable (specific calls 
> for external migration, and other ones for internal migration)?
I would like to see a parameter indicating what agent will be used and 
keep all other parameters the same.
>  The best 
> way could have been to have generic call for migration, but we must also 
> have generic objects to describe the migration sources and destinations 
> and those are not simples.
For migration to and from external sources, Lustre must already manage 
this data in an extended attribute (e.g. to describe the file on tape to 
which a Lustre file was migrated).  This data is opaque to Lustre and 
can be passed as a blob.
>  We finally conclude with the API presented in 
> the HLD document. Tell me if this is *really* a bad idea or if only 
> adjustments are needed.
>
>   
I have not yet looked at these.

> We presented two modes of migration, explicit and implicit migrations. 
> The first one result of an administrative request, the second one was 
> triggered automatically (cache miss by example). Is that ok? (See the 
> doc for all details).
>   
Yes, that seems ok.
> Agent:
>
> It seems, to support Lustre internal migration, you have planned to 
> implement specific Agents which will reside on OST.
To avoid many complications involving locks, we decided that even the 
agents used for internal migrations will layer on the file system.  The 
Lustre file system will be mounted on the OST's and it will use the 
"LOLND" to transport the data efficiently between the OST process and 
the client file system cache.  In the internal case source and 
destination lie in Lustre in the HSM case only one of them.

As a result I believe these two cases are closer together than you may 
think, and should be one "type".

The key aspect we/you need to design is what an agent has to make sure 
happens, for example in terms of locking file extents and in terms of 
avoiding triggering a recursive cache miss (open by fid with a flag?).

- Peter -

>  HSM will need 
> specific agent on clients. Do those two kinds of agent are acceptable ? 
> The current API only describe HSM-based agent. Maybe we should think of 
> a generic agent framework and add specialized implementations for 
> ost,hsm,etc ?
>
>   


>
>   
