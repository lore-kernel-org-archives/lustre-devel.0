From: Eric Mei <Eric.Mei@Sun.COM>
Date: Thu, 05 Jun 2008 10:19:36 -0600
Subject: [Lustre-devel] security: MGS connection
In-Reply-To: <028801c8c678$922e1d50$0281a8c0@ebpc>
References: <C46C26CE.574E%peter.braam@sun.com> <4846C394.1020801@sun.com>
	<023e01c8c66b$0eabce80$0281a8c0@ebpc> <4846E11A.7010604@sun.com>
	<028801c8c678$922e1d50$0281a8c0@ebpc>
Message-ID: <48481218.9010703@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric Barton wrote:
> Comments inline
> 
>> -----Original Message-----
>> From: Eric.Mei at Sun.COM [mailto:Eric.Mei at Sun.COM] 
>> Sent: 04 June 2008 7:38 PM
>> To: Eric Barton
>> Cc: 'Lustre Development Mailing List'; 'Peter Braam'
>> Subject: Re: [Lustre-devel] security: MGS connection
>>
>> Eric Barton wrote:
>>>> Here is the user interface change according to previous discussion, 
>>>> please review:
>>>>
>>>> - The security flavor of MGS connection is determined by each node, not 
>>>>   controllable by MGS.
>>> Is this an unavoidable fact of life or a design decision?
>> I think it's not completely unavoidable. For example, MGC can do initial 
>> connect without protect, and tell MGS what kind of security mode it 
>> support, and MGS replay with its decision, and MGC reconnect with 
>> choosed flavor.
>>
>> This way will be much more complicated. And more importantly, what if 
>> someone hijack the initial non-protected connection? Things seem not 
>> getting any better...
> 
> I meant some way to ensure the MGS only allows connections with
> a certain level of security which might depend on who was connecting
> (of course "who" would have to be authenticated).  I would hope this
> could be configured outside of lustre?

MGS can easily enforce that. The "who" actually means "which node".

>>> I don't think it's acceptable to allow a previous mount to compromise
>>> the security of a later mount.
>> Indeed it looks not so good. But the fact of per-node shared MGS 
>> connection means only one flavor could be used. To avoid the confusion, 
>> to me the only way is don't allow the choice via mount option, instead 
>> to choose a "proper" one automatically somehow.
> 
> It's OK if the MGS will reject any connection attempt with insufficient
> security.  In that case, you could put the security in the mount option
> and it should probably be an error to specify different levels of security
> when talking to the same MGS.

I guess there's misunderstanding. The problem is not on MGS, it's on 
MGC. Each node have only one MGC, thus only one ptlrpc connection to 
MGS, which is shared by _all_ Lustre components live on this node. So in 
case of mounting 2 OSTs on a single node, only one security flavor could 
be used.

>>> XXX
>>>
>>> This raises the interesting question of whether servers (MGS included) can
>>> demand a minimim level of security from clients connecting to them.  Is this
>>> normally part of configuring security on a given node (e.g. to set the
>>> machine credentials you mentioned above)?
>> This is the root problem I guess: we can't assume there's security 
>> environment ready on each nodes.
> 
> If the site needs security, it must be set up correctly.  Whether this is
> done within lustre config or outside of it, or both is not the main point -
> it _has_ to be set up correctly.
> 
>> The procedure of setup gss/kerberos is not extremely easy: configure 
>> KDC, installing keytabs, configure gssapi, keyring, etc. And for most 
>> Luster clusters, strong security are not needed at all, so people most 
>> likely choose to skip that.
> 
> 1. Making lustre easy to deploy with a null security flavor is a requirement
> for sites that have no need for security.
> 
> 2. Making it hard to deploy lustre with non-obvious "holes" in its security is
> a requirement for sites that need security.
> 
> 3. Making it easy to test lustre with security enabled anywhere is a "nice to have"
> but not a requirement and it must certainly not be prioritised over (1) and (2).

OK I understand. But I didn't mean people should skip security setting 
if strong security is needed. I meant in most cases strong security is 
not needed, thus people _will_ skip security setting, and in any case a 
proper security to MGS should be chosen.

-- 
Eric
