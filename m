From: Peter Braam <Peter.Braam@Sun.COM>
Date: Wed, 06 Aug 2008 16:48:39 -0600
Subject: [Lustre-devel] security: rpc message vs bulk data
In-Reply-To: <4899D78E.4000404@sun.com>
Message-ID: <C4BF8667.5519%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



...snip
>> We should not use KRB/GSS for bulk data encryption, see below.
>> 
>>> Now we're thinking about using gssapi for both RPC and bulk data. But
>>> this way we won't be able to configure them separately. What we're not
>>> sure is: is it necessary to be able to set different security level for
>>> RPC message and bulk data?
>> 
>> Yes two policies are good to have. Eventually file systems will store data
>> encrypted. It would not be a good idea to have encrypt twice - we want to
>> ask the client to encrypt the data, send it over the wire and store on disk
>> without decrypting.
> 
> I see.
> 
> Suppose even if we use gss/krb5 for bulk i/o, we can still turn it off
> independently. That is to say: suppose we're using gssapi for RPC
> message, for bulk data we can choose either use same gssapi to do
> protection, or don't do protection at all. Is this approach sounds good
> compare to current using completely different policy?

It doesn't sound so good.  What you want is authorization (which is included
in the capabilities), integrity (which should be the integrity of the
encrypted data stored on disk for the data, to avoid re-computing it) and
encryption (which should be the same encryption as what is used on the disk
to avoid re-encrypting).  GSS doesn't have the right keys and signatures.

> 
> I'm asking this because Darren and Jim pointed out the current bulk i/o
> policy is ad-hoc. There's 2 choices: 1) simply using standard mechanism
> (e.g. hmac+cipher, CCM/GCM, etc.), still keep it independent of RPC
> message policy; 2) suggested by Eric Barton, using the same gssapi for
> bulk data as well.

GSS is a protocol to set up communications with a certain level of security
based on authentication. It is explicitly not an authorization protocol.

I think this means that you can use it if you can authenticate the client to
the OSS server.  That however is hairy, as the identity you could use is the
identity of the "page cache" in the client, not really of any particular
user.

Combined with the above mismatch of the crypto and integrity, I don't
believe this is right.

Of course the CMU research about NASD concluded the same 10-15 years ago -
you need a different protocol here, calling it ad-hoc is not so positive,
calling it the NASD protocol sounds rather nice.

Peter



> 
> Thanks
