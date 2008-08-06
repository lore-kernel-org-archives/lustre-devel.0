From: Eric Mei <Eric.Mei@Sun.COM>
Date: Wed, 06 Aug 2008 10:55:42 -0600
Subject: [Lustre-devel] security: rpc message vs bulk data
In-Reply-To: <C4BE6947.54D4%peter.braam@sun.com>
References: <C4BE6947.54D4%peter.braam@sun.com>
Message-ID: <4899D78E.4000404@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter,

Peter Braam wrote:
> Eric - can you add this detail to the presentation about the security
> architecture?

OK.

> On 8/5/08 12:12 PM, "Eric Mei" <Eric.Mei@Sun.COM> wrote:
> 
>> Hi,
>>
>> Currently we use different security transformation: on RPC message we
>> use gssapi/kerberos; on bulk data we use separate hash + cipher
>> mechanism. And to some extend the 2 parts can be configured
>> independently. For example, you can use "krb5p" on RPC message while use
>> some light-weight hash/cipher on bulk data for performance or whatever
>> reasons.
> 
> We should not use KRB/GSS for bulk data encryption, see below.
> 
>> Now we're thinking about using gssapi for both RPC and bulk data. But
>> this way we won't be able to configure them separately. What we're not
>> sure is: is it necessary to be able to set different security level for
>> RPC message and bulk data?
> 
> Yes two policies are good to have. Eventually file systems will store data
> encrypted. It would not be a good idea to have encrypt twice - we want to
> ask the client to encrypt the data, send it over the wire and store on disk
> without decrypting.

I see.

Suppose even if we use gss/krb5 for bulk i/o, we can still turn it off 
independently. That is to say: suppose we're using gssapi for RPC 
message, for bulk data we can choose either use same gssapi to do 
protection, or don't do protection at all. Is this approach sounds good 
compare to current using completely different policy?

I'm asking this because Darren and Jim pointed out the current bulk i/o 
policy is ad-hoc. There's 2 choices: 1) simply using standard mechanism 
(e.g. hmac+cipher, CCM/GCM, etc.), still keep it independent of RPC 
message policy; 2) suggested by Eric Barton, using the same gssapi for 
bulk data as well.

Thanks
-- 
Eric
