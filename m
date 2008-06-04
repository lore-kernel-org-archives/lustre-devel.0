From: Eric Mei <Eric.Mei@Sun.COM>
Date: Wed, 04 Jun 2008 13:07:36 -0600
Subject: [Lustre-devel] security: MGS connection
In-Reply-To: <76D8943F-4043-4421-B0BA-5E477C148F5E@sun.com>
References: <C46C26CE.574E%peter.braam@sun.com> <4846C394.1020801@sun.com>
	<023e01c8c66b$0eabce80$0281a8c0@ebpc>
	<76D8943F-4043-4421-B0BA-5E477C148F5E@sun.com>
Message-ID: <4846E7F8.6070206@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Spencer Shepler wrote:
> 
> On Jun 4, 2008, at 12:47 PM, Eric Barton wrote:
> 
>> Eric,
>>
>>> Here is the user interface change according to previous discussion,
>>> please review:
>>>
>>> - The security flavor of MGS connection is determined by each node, not
>>>   controllable by MGS.
>>
>> Is this an unavoidable fact of life or a design decision?  See below 
>> "XXX"
>>
>>> - By default there's no protection.
>>
>> See below "XXX"
>>
>>>
>>> - Given the GSS/Kerberos env is ready, mount option "mgssec=flavor"
>>> could be supplied. Pre-configured machine credential will be used, so no
>>> need to supply password or whatsoever.
>>>
>>> - For MDT/OST, the option "mgssec=flavor" could also be written on disk,
>>> like other parameters, but will be override if mount option supplied.
>>>
>>> - The flavor of MGS connection won't change until umount, no matter how
>>> rest of connection flavors change at runtime.
>>
>>> - MGC->MGS connection is one per node, so only one flavor could be used.
>>> For example, suppose 2 OSTs live in a single node, we do:
>>>    # mount -t lustre -o mgssec=krb5p /dev/sda1 /mnt/ost1
>>>    # mount -t lustre -o mgssec=null /dev/sda1 /mnt/ost2
>>> then only 'mgssec=krb5p' will take effect, the second 'mgssec=null' will
>>> be ignored.
>>
>> I don't think it's acceptable to allow a previous mount to compromise
>> the security of a later mount.
>>
>> XXX
>>
>> This raises the interesting question of whether servers (MGS included) 
>> can
>> demand a minimim level of security from clients connecting to them.  
>> Is this
>> normally part of configuring security on a given node (e.g. to set the
>> machine credentials you mentioned above)?
> 
> As an unsolicited opinion...
> 
> Conceptually, the MGS does have a choice about security configuration.
> It can refused to handle incoming requests if they don't meet a certain
> level of GSS security.  Given my understanding of the types of messages
> the MGS receives and the importance of those messages in the larger
> context of Lustre services, it would seem to be an imperative that
> all MGS contact be krb5p if Kerberos has been specified at all.
> 
> Given this assumption, there doesn't seem to be a need for mount time
> options.  The client can attempt to obtain kerberos machine creds
> and if available, they will be used for interaction with the MGS.
> If the client receives a GSS error, it can attempt non-GSS/non-kerb.
> If machine credentials exist, the client goes without and hopefully
> that is what the admin chose.

Maybe there's practical issues (not 100% sure though): If the env 
(especially keyring) is not correctly set, kernel may not be notified 
the exact reason of failure, it could be env problem on client node, 
transient network partition, server failure, or server rejection.

> Note that keytab distribution can be cumbersome for large installations
> but if the choice is security then there will be some burden.

Yes. And we probably will have tools to ease the procedure a little bit.

-- 
Eric
